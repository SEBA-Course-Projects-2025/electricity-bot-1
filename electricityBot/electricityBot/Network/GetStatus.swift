//
//  GetStatus.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.07.2025.
//

import Foundation

struct GetStatus {
    static func sendRequestToBackend(deviceID: String) async throws -> PowerStatus {
        guard let url = URL(string: "https://bot-1.electricity-bot.online/api/status/\(deviceID)") else {
            throw URLError(.badURL)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let response: PowerStatus = try await NetworkManager.shared.request(url: url, dateFormatter: formatter)
        return response
    }
}
