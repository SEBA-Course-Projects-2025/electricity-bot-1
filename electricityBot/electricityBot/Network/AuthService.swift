//
//  AuthService.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.07.2025.
//

import Foundation
import AuthenticationServices
import UIKit

class AuthContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        return scene?.windows.first(where: { $0.isKeyWindow }) ?? ASPresentationAnchor()
    }
}

func startKeycloakLogin(completion: @escaping (Result<(accessToken: String, refreshToken: String), Error>) -> Void) {
    let clientID = "electricity-mobile-client" // keycloak client
    let redirectURI = "com.electricitybot://callback" // iOS scheme added to plist
    let realm = "electricity-bot"
    let keycloakBaseURL = "https://bot-1.electricity-bot.online/admin"

    let authURLString = "\(keycloakBaseURL)/realms/\(realm)/protocol/openid-connect/auth" +
        "?client_id=\(clientID)" +
        "&redirect_uri=\(redirectURI)" +
        "&response_type=code" +
        "&scope=openid%20email%20profile"

    guard let authURL = URL(string: authURLString) else {
        completion(.failure(NSError(domain: "Invalid auth URL", code: -1)))
        return
    }

    let session = ASWebAuthenticationSession(
        url: authURL,
        callbackURLScheme: "com.electricitybot"
    ) { callbackURL, error in
        if let error = error {
            completion(.failure(error))
            return
        }

        guard let callbackURL = callbackURL,
              let urlComponents = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false),
              let code = urlComponents.queryItems?.first(where: { $0.name == "code" })?.value else {
            completion(.failure(NSError(domain: "Missing code in callback", code: -2)))
            return
        }

        print("Authorization code received: \(code)")
        // send token to backend ->
        sendTokenToBackend(token: code, completion: completion)
    }

    let contextProvider = AuthContextProvider()
    session.presentationContextProvider = contextProvider
    session.prefersEphemeralWebBrowserSession = true // preventing session reuse
    session.start()
}

func sendTokenToBackend(token: String, completion: @escaping (Result<(accessToken: String, refreshToken: String), Error>) -> Void) {
    let backendURL = URL(string: "https://bot-1.electricity-bot.online/api/auth/callback")!
    var request = URLRequest(url: backendURL)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let json: [String: Any] = [
        "code": token,
        "is_web": false,
        "is_custom_mobile": true
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: json)
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            completion(.failure(error))
            return
        }
        
        guard let data = data else {
            completion(.failure(NSError(domain: "No data from server", code: -1)))
            return
        }
        
        do {
            if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print(jsonResponse)
                guard let accessToken = jsonResponse["access_token"] as? String,
                    let refreshToken = jsonResponse["refresh_token"] as? String else {
                    completion(.failure(NSError(domain: "Missing tokens in response", code: -2)))
                    return
                }
                
                TokenHandler.saveToken(accessToken, forKey: "access_token")
                TokenHandler.saveToken(refreshToken, forKey: "refresh_token")
                
                completion(.success((accessToken: accessToken, refreshToken: refreshToken)))
                
                if let message = jsonResponse["message"] as? String {
                    print(message)
                }
            } else {
                let responseText = String(data: data, encoding: .utf8) ?? "nil"
                completion(.failure(NSError(domain: "Backend error: \(responseText)", code: -3)))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    task.resume()
}

