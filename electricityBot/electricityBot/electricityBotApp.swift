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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var userSession = UserSession()
    
    var body: some Scene {
        WindowGroup {
            SplashScreenView()
               // .preferredColorScheme(.light)
                .environmentObject(userSession)
                .onAppear {
                    if let deviceID = userSession.currentDeviceID {
                        UserDefaults.standard.set(deviceID, forKey: "currentDeviceID")
                    }
                }
                .onAppear {
                    if userSession.user == nil, TokenHandler.getToken(forKey: "access_token") != nil {
                        userSession.fetchCurrentUser()
                    }
                }
                .onChange(of: userSession.currentDeviceID) { newValue in
                    UserDefaults.standard.set(newValue, forKey: "currentDeviceID")
                }
        }
    }
}
