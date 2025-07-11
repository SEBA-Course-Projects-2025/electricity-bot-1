//
//  LoginView.swift
//  electricityBot
//
//  Created by Dana Litvak on 11.06.2025.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var loginResult: Result<String, Error>? = nil
    
    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()
            VStack {
                Spacer() // Pushes content to the center vertically
                
                VStack(alignment: .center) {
                    Text("Ready to Dive In?")
                        .font(Font.custom("Poppins-SemiBold", size: 28))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                        .padding(.horizontal)

                    Text("Log in below and let the fun begin! 🚀")
                        .font(Font.custom("Poppins-Regular", size: 20))
                        .multilineTextAlignment(.center)
                        .padding(.top, 25)
                        .padding(.horizontal, 30)
                    
                    // log in button
                    
                    SimpleButtonView(title: "Login now", action:  {
                        startKeycloak()
                    }, size: 240)
                    
                    
                }
                .padding(.bottom, 20)
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private func startKeycloak() {
        startKeycloakLogin { result in
            switch result {
            case .success(let accessToken):
                print("Access Token: \(accessToken)")
                
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    LoginView()
}
