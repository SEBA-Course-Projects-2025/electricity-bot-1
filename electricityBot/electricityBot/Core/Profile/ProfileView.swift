//
//  ProfileView.swift
//  electricityBot
//
//  Created by Dana Litvak on 11.06.2025.
//

import SwiftUI
import SafariServices

struct ProfileView: View {
    @EnvironmentObject var userSession: UserSession
    @Environment(\.dismiss) var dismiss
    @State private var navAfterLogOut = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading) {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    // hello message
                    Text("Hello, \(userSession.user?.fullName ?? "User")!")
                        .font(.custom("Poppins-Medium", size: 32))
                    
                    // account card + change user
                    HStack(spacing: 12) {
                        Text(userSession.user?.initials ?? "NA")
                            .font(.custom("Poppins-Medium", size: 21))
                            .frame(width: 40, height: 40)
                            .background(Color.foregroundLow.opacity(0.35))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        
                        VStack(alignment: .leading) {
                            Text(userSession.user?.email ?? "noname@gmail.com")
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
                        Text("Want to remove this device?")
                            .font(.custom("Poppins-Medium", size: 22))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        SimpleButtonView(title: "Reset", action: {
                            guard let deviceId = userSession.currentDeviceID else {
                                print("No device selected to delete.")
                                return
                            }
                            
                            guard let userId = userSession.user?.id else {
                                print("No user selected.")
                                return
                            }
                            
                            DeleteDevice.deleteUserDevice(deviceId: deviceId, userId: userId) { result in
                                switch result {
                                case .success(let message):
                                    print("Deleted successfully: \(message)")
                                case .failure(let error):
                                    print("Error deleting device: \(error.localizedDescription)")
                                }
                            }
                            
                            dismiss()
                        })
                            .padding(.top, -32)
                            .padding(.horizontal, -16)
                    }
                    .padding(.top, 75.0)
                    
                    Spacer()
                    
                    // logout
                    LogOutView {
                        userSession.logout()
                        navAfterLogOut = true
                    }
                    Spacer().frame(height: 80)
                }
                .padding(32)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            print("User in profile: \(userSession.user?.fullName ?? "nil")")
        }
        .navigationDestination(isPresented: $navAfterLogOut) {
            LoginView()
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserSession())
}
