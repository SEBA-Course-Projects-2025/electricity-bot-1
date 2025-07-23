//
//  PowerStatus.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.07.2025.
//

import Foundation

struct PowerStatus: Codable {
    let deviceID: String
    let status: Bool
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case deviceID = "device_id"
        case status = "outgate_status"
        case timestamp
    }
}
