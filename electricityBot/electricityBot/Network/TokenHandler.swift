//
//  TokenHandler.swift
//  electricityBot
//
//  Created by Dana Litvak on 11.07.2025.
//

import Foundation

struct TokenHandler {
    static func saveToken(_ token: String, forKey key: String) {
        KeychainHelper.save(token, forKey: key)
    }

    static func getToken(forKey key: String) -> String? {
        KeychainHelper.read(forKey: key)
    }
    
    static func clearAllTokens() {
        KeychainHelper.delete("access_token")
        KeychainHelper.delete("refresh_token")
    }

    static func refreshAccessToken() async -> Bool {
        guard let refreshToken = getToken(forKey: "refresh_token") else {
            return false
        }
        
        let url = URL(string: "https://bot-1.electricity-bot.online/api/auth/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["refresh_token": refreshToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let access = json["access_token"] as? String,
               let refresh = json["refresh_token"] as? String {
                print("New access:", access)
                print("New refresh:", refresh)

                saveToken(access, forKey: "access_token")
                saveToken(refresh, forKey: "refresh_token")
                return true
            }
        } catch {
            print("Token refresh failed.")
        }
        return false
    }
}
