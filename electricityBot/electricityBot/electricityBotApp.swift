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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var userSession = UserSession()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
                .preferredColorScheme(.light)
                .environmentObject(userSession)
                .onOpenURL { url in
                          GIDSignIn.sharedInstance.handle(url)
                        }
        }
    }
}
