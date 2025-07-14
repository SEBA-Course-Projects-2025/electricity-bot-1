//
//  UserSession.swift
//  electricityBot
//
//  Created by Dana Litvak on 18.06.2025.
//

import Foundation
import Combine

class UserSession: ObservableObject {
    @Published var user: User?
    @Published var currentDeviceID: String? = nil

    var isLoggedIn: Bool {
        user != nil
    }

    init() {
        if TokenHandler.getToken(forKey: "access_token") != nil {
            fetchCurrentUser()
        }
    }

    func fetchCurrentUser(completion: (() -> Void)? = nil) {
        APIService.getCurrentUser { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.user = user
                case .failure:
                    self.logout()
                }
                completion?()
            }
        }
    }

    func login(with accessToken: String, refreshToken: String, completion: @escaping () -> Void = {}) {
        TokenHandler.saveToken(accessToken, forKey: "access_token")
        TokenHandler.saveToken(refreshToken, forKey: "refresh_token")
        fetchCurrentUser {
            completion()
        }
    }

    func logout() {
        APIService.logout {
            DispatchQueue.main.async {
                self.user = nil
                self.currentDeviceID = nil
                TokenHandler.clearAllTokens()
            }
        }
    }
}
