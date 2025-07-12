//
//  LoginView.swift
//  electricityBot
//
//  Created by Dana Litvak on 11.06.2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var email = ""
    @State private var password = ""
    @State private var loginResult: Result<String, Error>? = nil
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                VStack {
                    Spacer() // Pushes content to the center vertically
                    
                    VStack(alignment: .center) {
                        Text("Let’s light things up ⚡️")
                            .font(Font.custom("Poppins-SemiBold", size: 28))
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                            .padding(.horizontal)

                        Text("Log in to keep an eye on your power status")
                            .font(Font.custom("Poppins-Regular", size: 20))
                            .multilineTextAlignment(.center)
                            .padding(.top, 20)
                            .padding(.horizontal, 30)
                        
                        // log in button
                        
                        SimpleButtonView(title: "Login now", action:  {
                            startKeycloak()
                        }, size: 240)
                        
                        NavigationLink(destination: RootView(), isActive: $userSession.isLoggedIn) {
                            EmptyView()
                        }
                        
                    }
                    .padding(.bottom, 20)
                    
                    Spacer()
                }
                .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private func startKeycloak() {
        startKeycloakLogin { result in
            switch result {
            case .success(let tokens):
                let accessToken = tokens.accessToken
                let refreshToken = tokens.refreshToken
                print("Access Token: \(accessToken)")
                self.userSession.login(with: accessToken, refreshToken: refreshToken)
                
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(UserSession())
}
