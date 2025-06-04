import SwiftUI

extension Color {
    static let backgroundColor = Color(red: 0.9412, green: 0.96, blue: 1)
    static let yellowGlow = Color(red: 1, green: 0.98, blue: 0.42)
}

struct ContentView: View {
    var animation: Namespace.ID
    
    var body: some View {
        ZStack(){
            Color.backgroundColor
                .ignoresSafeArea()
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
        }
    }
}



