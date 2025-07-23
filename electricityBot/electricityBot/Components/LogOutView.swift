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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Log Out")
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .font(.custom("Poppins-Regular", size: 16))
                .foregroundColor(Color.textColor)
        }
    }
}

