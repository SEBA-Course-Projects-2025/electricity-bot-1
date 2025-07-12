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
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Button() {
            userSession.logout()
            dismiss()
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
