//
//  GetDevices.swift
//  electricityBot
//
//  Created by Dana Litvak on 12.07.2025.
//

import Foundation

struct GetDevices {
    static func getUserDevices(userID: String) async throws -> [Device] {
        guard let url = URL(string: "https://bot-1.electricity-bot.online/users/\(userID)/devices") else {
            throw URLError(.badURL)
        }

        return try await NetworkManager.shared.request(url: url)
    }
}
