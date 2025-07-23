//
//  GoogleSignInButtonView.swift
//  electricityBot
//
//  Created by Dana Litvak on 18.06.2025.
//

import SwiftUI
import GoogleSignIn

struct GoogleSignInButtonView: View {
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        Button {
            handleGoogleSignIn()
        } label: {
            HStack(alignment: .center, spacing: 8) {
                Image("GoogleSignIn")
                    .resizable()
                    .frame(width: 20, height: 20)
                    
                Text("Continue with Google")
                    .font(.custom("Poppins-SemiBold", size: 16))
                    .foregroundColor(Color.textColor.opacity(0.72))
            }
            .frame(width: UIScreen.main.bounds.width - 32, height: 52)
            .background(Color.blueAccentButton.opacity(0.21))
            .cornerRadius(8.0)
        }
        .padding(.horizontal, 16.0)
    }
    
    func handleGoogleSignIn() {
        // root controller to open Google Sign-In pop-up
        guard let rootVC = UIApplication.rootViewController else {
            print("No rootViewController available")
            return
        }

        print("Sign-in started")
        GIDSignIn.sharedInstance.signIn(withPresenting: rootVC) { signInResult, error in
            guard let result = signInResult else {
                print("Sign in failed or cancelled: \(error?.localizedDescription ?? "No error info")")
                return
            }

            // local debug
            print("User signed in: \(result.user.profile?.email ?? "no email")")
            
            // receive Google ID token and send it to the server
            guard let idToken = result.user.idToken?.tokenString else {
                print("No idToken found")
                return
            }

            GoogleAuthService.sendTokenToBackend(idToken: idToken) { result in
                switch result {
                    case .success(let user):
                        DispatchQueue.main.async {
                            self.userSession.user = user
                            self.userSession.isLoggedIn = true
                    }
                    case .failure(let error):
                        print("Backend auth failed:", error.localizedDescription)
                }
            }
        }
    }
}

#Preview {
    GoogleSignInButtonView()
}
