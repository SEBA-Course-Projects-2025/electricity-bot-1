//
//  GetStatistics.swift
//  electricityBot
//
//  Created by Dana Litvak on 21.06.2025.
//

import Foundation

struct GetStatistics {
    static func sendRequestToBackend(deviceID: String, days: Int, completion: @escaping (Result<PowerStatsRequest, Error>) -> Void) {
        // server endpoint
        let urlString = "https://bot-1.electricity-bot.online/statistics/\(days == 1 ? "day" : "week")/\(deviceID)"
        guard let url = URL(string: urlString) else { return }
        print("Requesting URL:", urlString)

        // JSON GET request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Auth Bearer Header
        if let accessToken = KeychainHelper.read(forKey: "access_token") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        // network request where data - actual data recieved, response - metadata, error - any errors
        URLSession.shared.dataTask(with: request) { data, response, error in
            //debugging
            if let data = data, let responseStr = String(data: data, encoding: .utf8) {
                print("Response data:", responseStr)
            }
            
            // status code
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP status code:", httpResponse.statusCode)
            }
            
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // if conenction is established but no data recieved
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }
            
            // "timestamp": "2025-06-21T13:50:44"
            do {
                let decoder = JSONDecoder()
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

                decoder.dateDecodingStrategy = .formatted(formatter)

                let result = try decoder.decode(PowerStatsRequest.self, from: data)
                completion(.success(result))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
