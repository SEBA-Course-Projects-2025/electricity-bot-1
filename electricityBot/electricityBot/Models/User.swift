//
//  User.swift
//  electricityBot
//
//  Created by Dana Litvak on 11.06.2025.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let fullName: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
            case id = "user_id"
            case fullName = "full_name"
            case email
        }
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullName) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return "N/A"
    }
}


extension User {
    static var MOCK_USER = User(id: NSUUID().uuidString, fullName: "John Smith", email: "john_smith@kse.org.ua")
}
