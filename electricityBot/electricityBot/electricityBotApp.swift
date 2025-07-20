//
//  electricityBot.swift
//  electricityBot
//
//  Created by Dana Litvak on 22.05.2025.
//

import SwiftUI
import GoogleSignIn

@main
struct electricityBot: App {
    @StateObject private var userSession = UserSession()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(.light)
                .environmentObject(userSession)
        }
    }
}
