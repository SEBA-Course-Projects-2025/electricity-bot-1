import dbus
import dbus.service
import dbus.mainloop.glib
from gi.repository import GLib

AGENT_PATH = "/org/bluez/electricity_bot/agent"

class Agent(dbus.service.Object):
    def __init__(self, bus):
        super().__init__(bus, AGENT_PATH)
        print(f"Agent initialized at {AGENT_PATH}")

    @dbus.service.method("org.bluez.Agent1", in_signature="ou", out_signature="")
    def RequestConfirmation(self, device, passkey):
        print(f"RequestConfirmation for device {device}")
        return

    @dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="")
    def RequestAuthorization(self, device):
        print(f"RequestAuthorization for device {device}")
        return

    @dbus.service.method("org.bluez.Agent1", in_signature="os", out_signature="")
    def AuthorizeService(self, device, uuid):
        print(f"AuthorizeService for device {device}, service {uuid}")
        return

    @dbus.service.method("org.bluez.Agent1", in_signature="ouq", out_signature="")
    def DisplayPasskey(self, device, passkey, entered):
        print(f"DisplayPasskey for device {device}: {passkey:06d}, entered: {entered}")
        return

    @dbus.service.method("org.bluez.Agent1", in_signature="os", out_signature="")
    def DisplayPinCode(self, device, pincode):
        print(f"DisplayPinCode for device {device}: {pincode}")
        return

    @dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="u")
    def RequestPasskey(self, device):
        print(f"RequestPasskey for device {device} returning 0")
        return dbus.UInt32(0)

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Cancel(self):
        print("Pairing canceled by user")

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Release(self):
        print("Agent released")

def register_agent(bus):
    manager = dbus.Interface(bus.get_object("org.bluez", "/org/bluez"), "org.bluez.AgentManager1")
    agent = Agent(bus)
    manager.RegisterAgent(AGENT_PATH, "KeyboardDisplay")
    print("Agent registered as KeyboardDisplay")
    manager.RequestDefaultAgent(AGENT_PATH)
    print("Agent set as default")
    return agent
