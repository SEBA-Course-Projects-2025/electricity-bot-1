//
//  LogOutView.swift
//  electricityBot
//
//  Created by Dana Litvak on 18.06.2025.
//

import SwiftUI
import GoogleSignIn

struct LogOutView: View {
    @EnvironmentObject var userSession: UserSession
    
    var body: some View {
        Button() {
            GoogleAuthService.handleLogout(userSession: userSession)
        } label: {
            Text("Log Out")
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(Color.foregroundLow)
        }
    }
}

#Preview {
    LogOutView()
}
