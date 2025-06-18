//
//  LoginView.swift
//  electricityBot
//
//  Created by Dana Litvak on 11.06.2025.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

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
                    .padding(.top, 100)
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
                
                Button {
                    print("Log user in...")
                    print(email, ": ", password)
                } label: {
                    Text("Login now")
                        .font(.custom("Poppins-SemiBold", size: 16))
                        .foregroundColor(Color.textColor.opacity(0.72))
                        .frame(width: UIScreen.main.bounds.width - 32, height: 52)
                }
                .background(Color.white)
                .cornerRadius(8.0)
                .padding(.top, 32.0)
                .padding(.horizontal, 16.0)
                
                GoogleSignInButtonView()
                
                // sign up navigation
                
                NavigationLink (){
                    RegisterView()
                } label:{
                    HStack {
                        Text("Don't Have An Account?")
                            .foregroundStyle(Color.foregroundLow)
                        Text("Sign Up")
                    }
                    .font(.custom("Poppins-Regular", size: 16))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                }
                .padding(.top, 24.0)
                
                Spacer()
            }
            .background(Color.backgroundColor)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    LoginView()
}
