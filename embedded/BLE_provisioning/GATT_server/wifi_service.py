from gatt_server import Service, Characteristic
import dbus
from gi.repository import GLib
import subprocess
import time

INTERNET_CONFIG_PATH = "/etc/wpa_supplicant/wpa_supplicant.conf"

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
        if self.service.ssid and self.service.password:
            self.try_connect()

    def try_to_connect(self):
        ssid = self.service.ssid.decode()
        password = self.service.password.decode()
        config = f"""
        country=UA
        ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
        update_config=1

        network={{
            ssid="{ssid}"
            psk="{password}"
            key_mgmt=SAE
        }}
        """
        with open(INTERNET_CONFIG_PATH, "w") as f:
            f.write(config.strip())
        subprocess.run(["sudo", "wpa_cli", "-i", "wlan0", "reconfigure"])
        time.sleep(5)
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
            result = subprocess.run(["nmcli", "-t", "-f", "SSID", "dev", "wifi"], capture_output=True, text=True, check=True)
            networks = result.stdout.strip().split('\n')
            ssids = []
            for ssid in networks:
                ssid = ssid.strip()
                if ssid:
                    ssids.append(ssid)
            return ssids

        except Exception as e:
            print(f"Wi-Fi scan failed: {e}")
            return []

