//
//  DeleteDevice.swift
//  electricityBot
//
//  Created by Dana Litvak on 14.07.2025.
//

import Foundation

struct DeleteDevice {
    struct DeleteResponse: Decodable {
        let message: String
        
        enum CodingKeys: String, CodingKey {
            case message = "msg"
        }
    }
    
    static func deleteUserDevice(deviceID: String) async throws -> String {
        guard let url = URL(string: "https://bot-1.electricity-bot.online/devices/\(deviceID)") else {
            throw URLError(.badURL)
        }

        let response: DeleteResponse =  try await NetworkManager.shared.request(url: url, method: "DELETE")
        return response.message
    }
}
