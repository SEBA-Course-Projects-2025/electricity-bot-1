import SwiftUI

extension Color {
    static let backgroundColor = Color("BackgroundColor")
    static let yellowGlow = Color(red: 1, green: 0.98, blue: 0.42)
    static let textColor = Color(hue: 0.855, saturation: 0.1137, brightness: 0.0588)
    static let foregroundLow = Color(hue: 0.855, saturation: 0.0588, brightness: 0.2745)
    static let blueAccentButton = Color(red: 0.6863, green: 0.812, blue: 1)
}

struct ContentView: View {
    @EnvironmentObject var userSession: UserSession
    var animation: Namespace.ID
    @State var currentStage: LaunchScreen = .welcome

    var body: some View {
        switch currentStage {
        case .welcome:
            welcomeView
        case .login:
            LoginView()
        case .userDevices:
            UserDevicesView()
                .environmentObject(userSession)
        }
    }
}
