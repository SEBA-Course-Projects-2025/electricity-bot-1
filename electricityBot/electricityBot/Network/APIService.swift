//
//  APIService.swift
//  electricityBot
//
//  Created by Dana Litvak on 11.07.2025.
//

import Foundation

struct APIService {
    static let baseURL = "https://bot-1.electricity-bot.online"
    
    static func getCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let accessToken = TokenHandler.getToken(forKey: "access_token") else {
            completion(.failure(NSError(domain: "Missing token", code: 401)))
            return
        }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/api/user")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(.failure(NSError(domain: "No data", code: -1)))
                    return
                }

                do {
                    let user = try JSONDecoder().decode(User.self, from: data)
                    print(user)
                    completion(.success(user))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()

    }
    
    
    static func refreshAccessToken(refreshToken: String, completion: @escaping (Result<(accessToken: String, refreshToken: String), Error>) -> Void) {
        var request = URLRequest(url: URL(string: "\(baseURL)/api/auth/refresh")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = ["refresh_token": refreshToken, "is_web": false]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: -1)))
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let accessToken = json["access_token"] as? String,
                   let refreshToken = json["refresh_token"] as? String {
                    completion(.success((accessToken: accessToken, refreshToken: refreshToken)))
                } else {
                    completion(.failure(NSError(domain: "Invalid response", code: -2)))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    static func logout(completion: @escaping () -> Void) {
        guard let accessToken = TokenHandler.getToken(forKey: "access_token"),
              let refreshToken = TokenHandler.getToken(forKey: "refresh_token") else {
            completion()
            return
        }
        
        var request = URLRequest(url: URL(string: "\(baseURL)/api/auth/logout")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "refresh_token": refreshToken,
            "is_web": false
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in
            completion()
        }.resume()
    }
}
