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

    static func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = getToken(forKey: "refresh_token") else {
            completion(false)
            return
        }
        APIService.refreshAccessToken(refreshToken: refreshToken) { result in
            switch result {
            case .success(let tokens):
                saveToken(tokens.accessToken, forKey: "access_token")
                saveToken(tokens.refreshToken, forKey: "refresh_token")
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
}
