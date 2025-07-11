from pydbus import SystemBus
from gi.repository import GLib
import time

bus = SystemBus()
adapter_path = "/org/bluez/hci0"
adapter = bus.get("org.bluez", adapter_path)

def setup_adapter():
    adapter.Powered = True
    time.sleep(1)

    adapter.Discoverable = True
    adapter.Pairable = True
    adapter.Alias = "Raspberry-Pi"

if __name__ == "__main__":
    setup_adapter()
