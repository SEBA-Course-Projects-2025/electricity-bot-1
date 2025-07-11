import dbus
import dbus.exceptions
import dbus.service
from gi.repository import GLib

GATT_MANAGER_IFACE = "org.bluez.GattManager1"
LE_ADVERTISING_MANAGER_IFACE = "org.bluez.LEAdvertisingManager1"
BLUEZ_SERVICE_NAME = "org.bluez"

BASE_PATH = "/org/bluez/electricity_bot"

class Application(dbus.service.Object):
    def __init__(self, bus):
        self.path = BASE_PATH
        self.services = []
        dbus.service.Object.__init__(self, bus, self.path)

    def get_path(self):
        return dbus.ObjectPath(self.path)

    def add_service(self, service):
        self.services.append(service)

    @dbus.service.method("org.freedesktop.DBus.ObjectManager", out_signature="a{oa{sa{sv}}}")
    def GetManagedObjects(self):
        response = {}
        for service in self.services:
            response[service.get_path()] = {
                "org.bluez.GattService1": {
                    "UUID": dbus.String(service.uuid),
                    "Primary": dbus.Boolean(service.primary),
                    "Includes": dbus.Array([], signature='o'),
                }
            }

            for char in service.characteristics:
                response[char.get_path()] = {
                    "org.bluez.GattCharacteristic1": {
                        "UUID": dbus.String(char.uuid),
                        "Service": dbus.ObjectPath(service.get_path()),
                        "Flags": dbus.Array(char.flags, signature='s'),
                    }
                }

        return response


    def register(self, bus):
        manager = dbus.Interface(bus.get_object(BLUEZ_SERVICE_NAME, "/org/bluez/hci0"),
                                 GATT_MANAGER_IFACE)
        app_objects = [s.get_path() for s in self.services]
        for s in self.services:
            s.register(bus)
        manager.RegisterApplication(self.get_path(), {},
                                    reply_handler=lambda: print("GATT Application registered"),
                                    error_handler=lambda e: print(f"GATT registration failed: {e}"))

class Service(dbus.service.Object):
    def __init__(self, bus, index, uuid, primary=True):
        self.path = f"{BASE_PATH}/service{index}"
        self.uuid = uuid
        self.primary = primary
        self.characteristics = []
        dbus.service.Object.__init__(self, bus, self.path)

    def get_path(self):
        return dbus.ObjectPath(self.path)

    def add_characteristic(self, characteristic):
        self.characteristics.append(characteristic)

    def register(self, bus):
        for c in self.characteristics:
            c.register(bus)

class Characteristic(dbus.service.Object):
    def __init__(self, bus, index, uuid, flags, service):
        self.path = f"{service.path}/char{index}"
        self.uuid = uuid
        self.flags = flags
        self.service = service
        dbus.service.Object.__init__(self, bus, self.path)

    def get_path(self):
        return dbus.ObjectPath(self.path)

    def register(self, bus):
        pass

    @dbus.service.method("org.bluez.GattCharacteristic1", in_signature="a{sv}", out_signature="ay")
    def ReadValue(self, options):
        print(f"Read request on {self.uuid}")
        return dbus.Array([0x00], signature="y")

    @dbus.service.method("org.bluez.GattCharacteristic1", in_signature="aya{sv}", out_signature="")
    def WriteValue(self, value, options):
        print(f"Write request on {self.uuid}: {value}")

    @dbus.service.method("org.bluez.GattCharacteristic1")
    def StartNotify(self):
        print(f"StartNotify on {self.uuid} (default noop)")

    @dbus.service.method("org.bluez.GattCharacteristic1")
    def StopNotify(self):
        print(f"StopNotify on {self.uuid} (default noop)")

def setup_gatt_server(bus):
    from wifi_service import WiFiProvisioningService
    app = Application(bus)

    wifi_service = WiFiProvisioningService(bus, 0)
    app.add_service(wifi_service)

    gatt_manager = dbus.Interface(
        bus.get_object("org.bluez", "/org/bluez/hci0"),
        "org.bluez.GattManager1"
    )

    gatt_manager.RegisterApplication(
        app.get_path(), {},
        reply_handler=lambda: print("GATT service registred"),
        error_handler=lambda e: print(f"Error of registration: {e}")
    )
