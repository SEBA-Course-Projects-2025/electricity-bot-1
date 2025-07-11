//
//  AuthService.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.07.2025.
//

import AuthenticationServices
import UIKit

import Foundation
import AuthenticationServices
import UIKit

class AuthContextProvider: NSObject, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

func startKeycloakLogin(completion: @escaping (Result<String, Error>) -> Void) {
    let clientID = "electricity-mobile-client" // keycloak client
    let redirectURI = "com.electricitybot://callback" // iOS scheme added to plist
    let realm = "electricity-bot"
    let keycloakBaseURL = "http://bot-1.electricity-bot.online"

    let authURLString = "\(keycloakBaseURL)/admin/realms/\(realm)/protocol/openid-connect/auth" +
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
    }

    let contextProvider = AuthContextProvider()
    session.presentationContextProvider = contextProvider
    session.prefersEphemeralWebBrowserSession = true // preventing session reuse
    session.start()
}

