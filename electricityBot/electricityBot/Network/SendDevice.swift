//
//  SendDevice.swift
//  electricityBot
//
//  Created by Dana Litvak on 19.07.2025.
//

import Foundation

struct SendDevice {
    struct DeviceRegistrationResponse: Codable {
        let device_id: String
        let user_id: String
        let message: String
    }
    
    static func sendDeviceToBackend(userID: String, deviceID: String) async throws -> DeviceRegistrationResponse {
            let deviceData = [
                "user_id": userID,
                "device_id": deviceID
            ]
            
            guard let url = URL(string: "https://bot-1.electricity-bot.online/api/devices") else {
                throw NetworkError.invalidURL
            }

            let jsonData = try JSONEncoder().encode(deviceData)

            let response: DeviceRegistrationResponse = try await NetworkManager.shared.request(
                url: url,
                method: "POST",
                body: jsonData
            )
            
            print("Device successfully sent to backend: \(response)")
            return response
        }
}
