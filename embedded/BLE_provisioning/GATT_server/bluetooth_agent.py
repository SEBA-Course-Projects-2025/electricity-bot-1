import dbus
import dbus.service

AGENT_PATH = "/org/bluez/electricity_bot/agent"

class Agent(dbus.service.Object):
    def __init__(self, bus):
        dbus.service.Object.__init__(self, bus, AGENT_PATH)
        print(f"Agent initialized at {AGENT_PATH}")

    @dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="")
    def RequestConfirmation(self, device):
        print(f"Auto-confirming pairing for {device}")
        return

    @dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="")
    def RequestAuthorization(self, device):
        print(f"Authorization requested for {device}")
        return

    @dbus.service.method("org.bluez.Agent1", in_signature="o", out_signature="")
    def AuthorizeService(self, device):
        print(f"Service authorized for {device}")
        return

    @dbus.service.method("org.bluez.Agent1", in_signature="ouq", out_signature="")
    def DisplayPasskey(self, device, passkey, entered):
        print(f"Display passkey for {device}: {passkey} (entered: {entered})")
        return

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Release(self):
        print("Agent released")

    @dbus.service.method("org.bluez.Agent1", in_signature="", out_signature="")
    def Cancel(self):
        print("Pairing request canceled")

def register_agent(bus):
    manager = dbus.Interface(bus.get_object("org.bluez", "/org/bluez"), "org.bluez.AgentManager1")
    agent = Agent(bus)
    manager.RegisterAgent(AGENT_PATH, "NoInputNoOutput")
    print("Agent registered as NoInputNoOutput")
    manager.RequestDefaultAgent(AGENT_PATH)
    print("Agent set as default")
