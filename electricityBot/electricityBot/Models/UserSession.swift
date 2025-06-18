//
//  UserSession.swift
//  electricityBot
//
//  Created by Dana Litvak on 18.06.2025.
//

import Foundation
import Combine

class UserSession: ObservableObject {
    @Published var isLoggedIn = false
    @Published var user: User?
}

