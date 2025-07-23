//
//  RegisterUserRequest.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.06.2025.
//

import Foundation

struct RegisterUserRequest: Codable {
    let email: String
    let device_id: String
    let first_name: String
    let last_name: String
}
