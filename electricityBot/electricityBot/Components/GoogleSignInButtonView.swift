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

            sendTokenToBackend(idToken: idToken)
        }
    }
    
    func sendTokenToBackend(idToken: String) {
        // server endpoint
        guard let url = URL(string: "http://127.0.0.1:5000/api/auth/login") else { return }

        // JSON POST request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // packs the data in JSON format to send
        let body: [String: Any] = ["id_token": idToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        // sends request to server
        URLSession.shared.dataTask(with: request) { data, response, error in
            // handles errors
            if let error = error {
                print("Request failed:", error.localizedDescription)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("Backend response code:", httpResponse.statusCode)
            }

            guard let data = data else {
                print("No data in response")
                return
            }

            do {
                let json = try JSONDecoder().decode(User.self, from: data)
                        
                // create a current user profile
                DispatchQueue.main.async {
                    self.userSession.user = json
                    self.userSession.isLoggedIn = true
                }
            } catch {
                print("Failed to decode JSON:", error.localizedDescription)
            }
            
        }.resume()
    }

}

#Preview {
    GoogleSignInButtonView()
}
