//
//  NetworkManager.swift
//  electricityBot
//
//  Created by Dana Litvak on 14.07.2025.
//

import Foundation

enum NetworkError: Error {
    case unauthorized
    case invalidURL
    case noData
    case decodingError(Error)
    case other(Error)
}

struct NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func request<T: Decodable>(url: URL,
                               method: String = "GET",
                               body: Data? = nil,
                               dateFormatter: DateFormatter? = nil,
                               retries: Int = 1) async throws -> T {
        
        func makeRequest(token: String?) async throws -> (Data, HTTPURLResponse) {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method
            urlRequest.httpBody = body
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            if let token = token, !token.isEmpty {
                urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                print("Using token: \(token)")
            } else {
                print("No token provided for Authorization header")
            }
            
            print("Requesting URL: \(urlRequest.url?.absoluteString ?? "") with method \(method)")
            
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.noData
            }
            print(data, httpResponse)
           
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Response body:\n\(jsonString)")
            } else {
                print("Could not decode response body to UTF-8")
            }


            return (data, httpResponse)
        }
        
        let token = TokenHandler.getToken(forKey: "access_token")
        var (data, response) = try await makeRequest(token: token)
        
        if response.statusCode == 401 && retries > 0 {
            print("Token is expired. Trying to refresh it.")
            
            let refreshSuccess = await TokenHandler.refreshAccessToken()
            if refreshSuccess {
                let newToken = TokenHandler.getToken(forKey: "access_token")
                (data, response) = try await makeRequest(token: newToken)
                print("Retrying with new token:", newToken ?? "")
            } else {
                throw NetworkError.unauthorized
            }
        }
        
        guard (200...299).contains(response.statusCode) else {
            throw NetworkError.other(NSError(domain: "Bad status: \(response.statusCode)", code: response.statusCode))
        }
        
        let decoder = JSONDecoder()
        if let formatter = dateFormatter {
            decoder.dateDecodingStrategy = .formatted(formatter)
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}
