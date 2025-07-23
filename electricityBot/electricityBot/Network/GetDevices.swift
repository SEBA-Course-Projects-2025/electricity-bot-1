//
//  GetDevices.swift
//  electricityBot
//
//  Created by Dana Litvak on 12.07.2025.
//

import Foundation

struct GetDevices {
    static func getUserDevices(userID: String) async throws -> [Device] {
        guard let url = URL(string: "https://bot-1.electricity-bot.online/api/users/\(userID)/devices") else {
            throw URLError(.badURL)
        }

        let response: [Device] = try await NetworkManager.shared.request(url: url)
        
        return response.map { device in
            return Device(deviceId: device.id, lastSeen: formatLastSeen(device.lastSeen))
        }
    }
    
    private static func formatLastSeen(_ lastSeen: String?) -> String? {
        guard let lastSeen else { return nil }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "h:mm a 'on' dd MMM yyyy"
        displayFormatter.locale = Locale.current
        displayFormatter.timeZone = TimeZone.current

        if let date = formatter.date(from: lastSeen) {
            return displayFormatter.string(from: date)
        } else {
            return nil
        }
    }
}
