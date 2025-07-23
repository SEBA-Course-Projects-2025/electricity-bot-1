//
//  GetStatistics.swift
//  electricityBot
//
//  Created by Dana Litvak on 21.06.2025.
//

import Foundation

struct GetStatistics {
    static func sendRequestToBackend(deviceID: String, days: Int) async throws -> PowerStatsRequest {
        let path = days == 1 ? "day" : "week"
        guard let url = URL(string: "https://bot-1.electricity-bot.online/api/statistics/\(path)/\(deviceID)") else {
            throw URLError(.badURL)
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let response: PowerStatsRequest = try await NetworkManager.shared.request(url: url, dateFormatter: formatter)
        return response
    }
}
