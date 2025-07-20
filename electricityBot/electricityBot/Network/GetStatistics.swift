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
        let urlString = "http://192.168.0.103:5050/api/statistics/\(days == 1 ? "day" : "week")/\(deviceID)"
        guard let url = URL(string: urlString) else { return }
        print("Requesting URL:", urlString)

        // JSON GET request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
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
            
            // "timestamp": "2025-06-21T13:50:44.072137Z"
            do {
                let decoder = JSONDecoder()
                
                // 072137Z (fractional seconds) are not handled by iso8601 by default
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                
                // use custom date decoder
                decoder.dateDecodingStrategy = .custom { decoder in
                    let container = try decoder.singleValueContainer()
                    let dateStr = try container.decode(String.self)
                    if let date = formatter.date(from: dateStr) {
                        return date
                    } else {
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateStr)")
                    }
                }

                let result = try decoder.decode(PowerStatsRequest.self, from: data)
                completion(.success(result))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
