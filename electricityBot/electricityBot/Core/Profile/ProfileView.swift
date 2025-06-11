//
//  ProfileView.swift
//  electricityBot
//
//  Created by Dana Litvak on 11.06.2025.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            
            VStack(alignment: .leading) {
                // hello message
                Text("Hello, \(User.MOCK_USER.fullName)!")
                    .font(.custom("Poppins-Medium", size: 32))
                    .padding(.top, 50.0)
                
                // account card + change user
                HStack(spacing: 12) {
                    Text(User.MOCK_USER.initials)
                        .font(.custom("Poppins-Medium", size: 21))
                        .frame(width: 40, height: 40)
                        .background(Color.foregroundLow.opacity(0.35))
                        .foregroundColor(.white)
                        .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                    
                    VStack(alignment: .leading) {
                        Text(User.MOCK_USER.email)
                            .font(.custom("Poppins-SemiBold", size: 15))
                            .foregroundColor(.foregroundLow.opacity(0.75))
                        
                        NavigationLink {
                            LoginView()
                        } label: {
                            Text("Change user")
                                .font(.custom("Poppins-Regular", size: 15))
                                .foregroundColor(.foregroundLow.opacity(0.75))
                        }
                    }
                }
                
                // change device
                VStack(alignment: .leading) {
                    Text("Want to track\nanother device?")
                        .font(.custom("Poppins-Medium", size: 22))
                    
                    NavigationLink {
                        
                    } label: {
                        Text("Choose")
                            .font(.custom("Poppins-SemiBold", size: 16))
                            .foregroundColor(Color.textColor.opacity(0.72))
                            .frame(width: UIScreen.main.bounds.width - 270, height: 52)
                    }
                    .background(Color.white)
                    .cornerRadius(8.0)
                    .shadow(color: .black.opacity(0), radius: 51, x: 145, y: 112)
                    .shadow(color: .black.opacity(0), radius: 47, x: 93, y: 72)
                    .shadow(color: .black.opacity(0.01), radius: 40, x: 52, y: 40)
                    .shadow(color: .black.opacity(0.02), radius: 29, x: 23, y: 18)
                    .shadow(color: .black.opacity(0.02), radius: 16, x: 6, y: 4)
                    
                }
                .padding(.top, 75.0)
                
                Spacer()
                
                // logout
                NavigationLink() {
                    SplashScreenView()
                        .navigationBarBackButtonHidden(true)
                } label: {
                    Text("Log Out")
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(Color.foregroundLow)
                }
            }
            .padding(32)
            .background(Color.backgroundColor)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    ProfileView()
}
