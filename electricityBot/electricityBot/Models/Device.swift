//
//  Device.swift
//  electricityBot
//
//  Created by Dana Litvak on 13.07.2025.
//

import Foundation

struct Device: Codable, Identifiable, Hashable, Equatable {
    var id: String { deviceId }
    let deviceId: String
    let lastSeen: String?
    
    enum CodingKeys: String, CodingKey {
        case deviceId = "device_id"
        case lastSeen = "last_seen"
    }
}

