from gatt_server import Service, Characteristic
import dbus
from gi.repository import GLib
import subprocess
import time
from pathlib import Path
import threading
import textwrap

INTERNET_CONFIG_PATH = "/etc/wpa_supplicant/wpa_supplicant-wlan0.conf"
DEVICE_CONFIG_PATH = "/home/user/electricity_bot/device_config.txt"

class WiFiProvisioningService(Service):
    def __init__(self, bus, index):
        super().__init__(bus, index, "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8740")
        self.ssid = b""
        self.password = b""
        self.status = b"DISCONNECTED"

        self.add_characteristic(SSIDCharacteristic(bus, 0, self))
        self.add_characteristic(PasswordCharacteristic(bus, 1, self))
        self.status_characteristic = StatusCharacteristic(bus, 2, self)
        self.add_characteristic(self.status_characteristic)
        self.add_characteristic(ScannedNetworksCharacteristic(bus, 3, self))
        self.add_characteristic(DeviceIDCharacteristic(bus, 4, self))


class SSIDCharacteristic(Characteristic):
    def __init__(self, bus, index, service):
        super().__init__(bus, index, "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8741", ["write"], service)

    def WriteValue(self, value, options):
        self.service.ssid = bytes(value)
        print(f"Get SSID: {self.service.ssid.decode()}")

class PasswordCharacteristic(Characteristic):
    def __init__(self, bus, index, service):
        super().__init__(bus, index, "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8742", ["write"], service)

    def WriteValue(self, value, options):
        self.service.password = bytes(value)
        print(f"Get password: {self.service.password.decode()}")
        self.maybe_try_to_connect()

    def maybe_try_to_connect(self):
        if self.service.ssid and self.service.password:
            threading.Thread(target=self.try_to_connect, daemon=True).start()

    def try_to_connect(self):
        ssid = self.service.ssid.decode()
        password = self.service.password.decode()
        config = textwrap.dedent(f"""\
            country=UA
            ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
            update_config=1

            network={{
                ssid="{ssid}"
                psk="{password}"
            }}
        """)

        with open(INTERNET_CONFIG_PATH, "w") as f:
            f.write(config)
        subprocess.run(["sudo", "wpa_cli", "-i", "wlan0", "reconfigure"])
        time.sleep(5)
        subprocess.run(["sudo", "dhclient", "wlan0"])
        status_output = subprocess.check_output(["wpa_cli", "-i", "wlan0", "status"]).decode()
        if "wpa_state=COMPLETED" not in status_output:
            print("Invalid SSID or password")
            self.service.status_characteristic.update_status(b"INVALID_CREDENTIALS")
            return False
        try:
            subprocess.check_call(["ping", "-c", "1", "8.8.8.8"])
            self.service.status_characteristic.update_status(b"CONNECTED")
            return True
        except subprocess.CalledProcessError:
            print("No internet connection")
            self.service.status_characteristic.update_status(b"NO_INTERNET")
            return False


class StatusCharacteristic(Characteristic):
    def __init__(self, bus, index, service):
        super().__init__(bus, index, "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8743", ["notify", "read"], service)
        self.notifying = False

    def update_status(self, new_value):
        self.service.status = new_value
        if self.notifying:
            print(f"Status updated to: {self.service.status.decode()}")
            self.PropertiesChanged(
                "org.bluez.GattCharacteristic1",
                {"Value": dbus.ByteArray(self.service.status)},
                [],
            )
        return True

    def StartNotify(self):
        self.notifying = True
        print("Client start notify")

    def StopNotify(self):
        self.notifying = False
        print("Client stop notify")

    def ReadValue(self, options):
        return dbus.ByteArray(self.service.status)



class ScannedNetworksCharacteristic(Characteristic):
    def __init__(self, bus, index, service):
        super().__init__(bus, index, "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8744", ["read"], service)
        self.networks = []

    def ReadValue(self, options):
        self.networks = self.scan_wifi()
        ssid_string = ",".join(self.networks)
        print(f"Sending SSIDs: {ssid_string}")
        return dbus.ByteArray(ssid_string.encode("utf-8"))

    def scan_wifi(self):
        try:
            result = subprocess.run(["sudo", "iwlist", "wlan0", "scan"], capture_output=True, text=True, check=True)
            networks = []
            for line in result.stdout.split('\n'):
                line = line.strip()
                if line.startswith("ESSID:"):
                    ssid = line.split("ESSID:")[1].strip().strip('"')
                    if ssid:
                        networks.append(ssid)
            return networks

        except Exception as e:
            print(f"Wi-Fi scan failed: {e}")
            return []



class DeviceIDCharacteristic(Characteristic):
    def __init__(self, bus, index, service):
        super().__init__(bus, index, "a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8745", ["read"], service)
        self.config_path = Path(DEVICE_CONFIG_PATH)

    def ReadValue(self, options):
        if not self.config_path.exists():
            print("Device ID file not found.")
            device_id = "UNKNOWN"
        else:
            device_id = self.config_path.read_text().strip()

        print(f"Reading Device ID: {device_id}")
        return dbus.ByteArray(device_id.encode("utf-8"))
