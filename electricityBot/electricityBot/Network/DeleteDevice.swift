//
//  DeleteDevice.swift
//  electricityBot
//
//  Created by Dana Litvak on 14.07.2025.
//

import Foundation

struct DeleteDevice {
    static func deleteUserDevice(deviceId: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        // server endpoint
        let urlString = "https://bot-1.electricity-bot.online/devices/\(deviceId)"
        guard let url = URL(string: urlString) else { return }
        print("Requesting URL:", urlString)

        // JSON GET request
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Auth Bareer Header
        if let accessToken = KeychainHelper.read(forKey: "access_token") {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let requestBody: [String: Any] = [
            "previous_owner_id": userId
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)


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
            
            //  message recieved
            do {
                let result = try JSONDecoder().decode(String.self, from: data)
                completion(.success(result))
                print(result)
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
