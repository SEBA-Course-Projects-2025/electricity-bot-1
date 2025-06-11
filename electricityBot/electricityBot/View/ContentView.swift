import SwiftUI

extension Color {
    static let backgroundColor = Color(red: 0.9412, green: 0.96, blue: 1)
    static let yellowGlow = Color(red: 1, green: 0.98, blue: 0.42)
    static let textColor = Color(hue: 0.855, saturation: 0.1137, brightness: 0.0588)
    static let foregroundLow = Color(hue: 0.855, saturation: 0.0588, brightness: 0.2745)
}

struct ContentView: View {
    var animation: Namespace.ID
    
    var body: some View {
        NavigationStack {
            ZStack(){
                Color.backgroundColor
                    .ignoresSafeArea()
                // logo along with welcome message
                VStack(spacing: 20){
                    Text("💡")
                        .font(.system(size: 53))
                        .shadow(color: .yellowGlow.opacity(1), radius: 25, x: 0, y: 0)
                        .matchedGeometryEffect(id: "lightbulb", in: animation)
                    Text("Welcome to \nElectricity Bot")
                        .font(Font.custom("BerlinBold", size: 23))
                        .multilineTextAlignment(.center)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 200)
                
                // nav button to LoginView
                NavigationLink{
                    LoginView()
                } label: {
                    Text("Start")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(Color.textColor.opacity(0.72))
                        .frame(width: UIScreen.main.bounds.width - 270, height: 52)
                }
                .background(Color.white)
                .cornerRadius(8.0)
                .padding(.top, 32.0)
                .padding(.horizontal, 16.0)
                                    
                
                Spacer()
            }
        }
    }
}
