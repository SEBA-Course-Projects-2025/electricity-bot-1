//
//  LoginView.swift
//  electricityBot
//
//  Created by Dana Litvak on 11.06.2025.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                // login message
                Text("Login to your account")
                    .font(Font.custom("Poppins-SemiBold", size: 28))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 208.0)
                    .padding(.horizontal)
                    
                
                // form fields: email & password
                
                VStack(spacing: 24) {
                    InputFieldView(text: $email, title: "Email", placeholder: "example@kse.org.ua")
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .autocorrectionDisabled()
                    
                    InputFieldView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                }
                .padding(.horizontal)
                .padding(.top, 32.0)
                
                // log in button
                
                Spacer()
                
                // sign up navigation
            }
            .background(Color.backgroundColor)
        }
    }
}

#Preview {
    LoginView()
}
