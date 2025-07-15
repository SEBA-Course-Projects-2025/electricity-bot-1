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
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let token = TokenHandler.getToken(forKey: "access_token") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw NetworkError.other(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        
        // handling error when token is expired
        if httpResponse.statusCode == 401 && retries > 0 {
            print("Token is expired. Trying to refresh it.")
            
            let refreshToken = await TokenHandler.refreshAccessToken()
            if refreshToken {
                return try await request(url: url, method: method, dateFormatter: dateFormatter, retries: retries - 1)
            } else {
                throw NetworkError.unauthorized
            }
        }
        
        // handling other statuses
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.other(NSError(domain: "Bad status: \(httpResponse.statusCode)", code: httpResponse.statusCode))
        }
        
        // default date formatter
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
