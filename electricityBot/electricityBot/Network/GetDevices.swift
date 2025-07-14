//
//  GetDevices.swift
//  electricityBot
//
//  Created by Dana Litvak on 12.07.2025.
//

import Foundation

struct GetDevices {
    static func getUserDevices(userId: String, completion: @escaping (Result<[Device], Error>) -> Void) {
        // server endpoint
        let urlString = "https://bot-1.electricity-bot.online/users/\(userId)/devices"
        guard let url = URL(string: urlString) else { return }
        print("Requesting URL:", urlString)

        // JSON GET request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // Auth Bareer Header
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
            
            //  {
            //  "device_id": d.device_id,
            //  "last_seen": d.last_seen.isoformat() if d.last_seen else None,
            // }
            // for d in devices
            do {
                let result = try JSONDecoder().decode([Device].self, from: data)
                completion(.success(result))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}
