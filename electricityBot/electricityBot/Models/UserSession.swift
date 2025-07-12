//
//  UserSession.swift
//  electricityBot
//
//  Created by Dana Litvak on 18.06.2025.
//

import Foundation
import Combine

class UserSession: ObservableObject {
    @Published var isLoggedIn = false
    @Published var user: User?
    @Published var currentDeviceID: String? = nil

    init() {
        self.isLoggedIn = TokenHandler.getToken(forKey: "access_token") != nil
    }

    func fetchCurrentUser() {
        APIService.getCurrentUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self?.user = user
                    self?.isLoggedIn = true
                    print(result)
                case .failure:
                    self?.logout() 
                }
            }
        }
    }

    func logout() {
        APIService.logout { [weak self] in
            DispatchQueue.main.async {
                self?.resetSession()
            }
        }
    }

    private func resetSession() {
        TokenHandler.clearAllTokens()
        self.user = nil
        self.currentDeviceID = nil
        self.isLoggedIn = false
    }
    
    func tryAutoLogin(completion: (() -> Void)? = nil) {
        TokenHandler.refreshAccessToken { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.isLoggedIn = true
                    self?.fetchCurrentUser()
                } else {
                    self?.logout()
                }
                completion?()
            }
        }
    }
    
    func login(with accessToken: String, refreshToken: String) {
        TokenHandler.saveToken(accessToken, forKey: "access_token")
        TokenHandler.saveToken(refreshToken, forKey: "refresh_token")
        self.isLoggedIn = true
        fetchCurrentUser ()
    }
}

