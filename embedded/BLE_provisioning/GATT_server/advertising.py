import dbus
import dbus.service
from gi.repository import GLib

ADVERT_PATH = "/org/bluez/electricity_bot/advertisement0"

class Advertisement(dbus.service.Object):
    def __init__(self, bus):
        self.path = ADVERT_PATH
        self.bus = bus
        dbus.service.Object.__init__(self, bus, self.path)

    @dbus.service.method("org.freedesktop.DBus.Properties",
                         in_signature="s", out_signature="a{sv}")
    def GetAll(self, interface):
        if interface != "org.bluez.LEAdvertisement1":
            raise dbus.exceptions.DBusException("Invalid interface")
        return {
            "Type": dbus.String("peripheral"),
            "LocalName": dbus.String("Raspberry-Pi"),
            "ServiceUUIDs": dbus.Array(["a1ddeaf4-cfd8-4a7c-aa8d-ac18df3f8740"], signature="s"),
            "Discoverable": dbus.Boolean(True),
        }

    @dbus.service.method("org.bluez.LEAdvertisement1",
                         in_signature="", out_signature="")
    def Release(self):
        print("Advertisement released")

    def get_path(self):
        return dbus.ObjectPath(self.path)


def start_advertising(bus):
    adapter_path = "/org/bluez/hci0"
    ad_manager = dbus.Interface(bus.get_object("org.bluez", adapter_path), "org.bluez.LEAdvertisingManager1")
    advert = Advertisement(bus)

    ad_manager.RegisterAdvertisement(
        advert.get_path(), {},
        reply_handler=lambda: print("Advertising started"),
        error_handler=lambda e: print(f"Error during advertising: {e}")
    )
    