//
//  RegisterView.swift
//  electricityBot
//
//  Created by Dana Litvak on 11.06.2025.
//

import SwiftUI

struct RegisterView: View {
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                // sign up message
                Text("Create an account")
                    .font(Font.custom("Poppins-SemiBold", size: 28))
                    .multilineTextAlignment(.leading)
                    .padding(.top, 100)
                    .padding(.horizontal)
                
                
                // form fields: email & password
                
                VStack(spacing: 24) {
                    InputFieldView(text: $fullName, title: "Full Name", placeholder: "f.e. John Smith")
                    
                    InputFieldView(text: $email, title: "Email", placeholder: "example@kse.org.ua")
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                        .autocorrectionDisabled()
                    
                    InputFieldView(text: $password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                }
                .padding(.horizontal)
                .padding(.top, 32.0)
                
                // sign up button
                
                Button {
                    print("Sign user up...")
                } label: {
                    Text("Create account")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(Color.textColor.opacity(0.72))
                        .frame(width: UIScreen.main.bounds.width - 32, height: 52)
                }
                .background(Color.white)
                .cornerRadius(8.0)
                .padding(.top, 32.0)
                .padding(.horizontal, 16.0)
            }
            
            Spacer()
        }
        .background(Color.backgroundColor)
    }
}
#Preview {
    RegisterView()
}
