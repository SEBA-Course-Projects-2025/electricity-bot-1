from gi.repository import GLib
import dbus
from dbus.mainloop.glib import DBusGMainLoop

from bluetooth_agent import register_agent
from gatt_server import setup_gatt_server
from advertising import start_advertising

def main():
    DBusGMainLoop(set_as_default=True)
    bus = dbus.SystemBus()

    register_agent(bus)
    setup_gatt_server(bus)
    start_advertising(bus)

    print("Mainloop is running")
    GLib.MainLoop().run()

if __name__ == "__main__":
    main()
