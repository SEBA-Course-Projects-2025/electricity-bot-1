//
//  PowerStats.swift
//  electricityBot
//
//  Created by Dana Litvak on 21.06.2025.
//

import Foundation

struct PowerStatsRequest: Codable {
    let deviceID: String
    let events: [PowerStats]
    let from: Date
    let to: Date
    
    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case events
        case from
        case to
    }
}

struct PowerStats: Identifiable, Codable, Hashable {
    let id = UUID()
    let outgateStatus: Bool
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case outgateStatus = "outgate_status"
        case timestamp
    }
    
}
