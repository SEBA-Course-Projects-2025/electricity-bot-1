//
//  PowerStats.swift
//  electricityBot
//
//  Created by Dana Litvak on 21.06.2025.
//

import Foundation

struct PowerStatsRequest: Decodable {
    let deviceId: String
    let events: [PowerStats]
    let from: Date
    let to: Date

    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case events, from, to
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.deviceId = try container.decode(String.self, forKey: .deviceId)
        self.events = try container.decode([PowerStats].self, forKey: .events)

        let dateStrFrom = try container.decode(String.self, forKey: .from)
        let dateStrTo = try container.decode(String.self, forKey: .to)

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let fromDate = isoFormatter.date(from: dateStrFrom),
              let toDate = isoFormatter.date(from: dateStrTo) else {
            throw DecodingError.dataCorruptedError(
                forKey: .from,
                in: container,
                debugDescription: "Failed to decode 'from' or 'to' date"
            )
        }

        self.from = fromDate
        self.to = toDate
    }
}

struct PowerStats: Codable, Hashable {
    let outgateStatus: Bool
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case outgateStatus = "outgate_status"
        case timestamp
    }
    
}
