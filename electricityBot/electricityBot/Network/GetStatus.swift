//
//  GetStatus.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.07.2025.
//

import Foundation

struct GetStatus {
    static func sendRequestToBackend(deviceID: String) async throws -> PowerStatus {
        guard let url = URL(string: "https://bot-1.electricity-bot.online/status/\(deviceID)") else {
            throw URLError(.badURL)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return try await NetworkManager.shared.request(url: url, dateFormatter: formatter)
    }
}
