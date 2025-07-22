//
//  File.swift
//  electricityBot
//
//  Created by Dana Litvak on 22.07.2025.
//

import Foundation
import SwiftUI

enum LaunchScreen {
    case welcome
    case login
    case userDevices
}

extension ContentView {
    var welcomeView: some View {
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
            Button(action: {
                if userSession.isLoggedIn {
                    currentStage = .userDevices
                } else {
                    currentStage = .login
                }
            }) {
                Text("Start")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(Color.textColor.opacity(0.72))
                    .frame(width: UIScreen.main.bounds.width - 270, height: 52)
            }
            .background(Color.white)
            .cornerRadius(8.0)
            .padding(.top, 32.0)
            .padding(.horizontal, 16.0)
            .shadow(color: .black.opacity(0), radius: 51, x: 145, y: 112)
            .shadow(color: .black.opacity(0), radius: 47, x: 93, y: 72)
            .shadow(color: .black.opacity(0.01), radius: 40, x: 52, y: 40)
            .shadow(color: .black.opacity(0.02), radius: 29, x: 23, y: 18)
            .shadow(color: .black.opacity(0.02), radius: 16, x: 6, y: 4)
            
            Spacer()
        }
    }
}
