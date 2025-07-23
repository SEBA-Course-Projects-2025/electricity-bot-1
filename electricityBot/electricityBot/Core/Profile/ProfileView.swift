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
    @State private var confirmChoice = false
    @State private var navToDevices = false

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
                            .background(Color.textColor.opacity(0.35))
                            .foregroundColor(.white)
                            .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
                        
                        VStack(alignment: .leading) {
                            Text(userSession.user?.email ?? "noname@gmail.com")
                                .font(.custom("Poppins-SemiBold", size: 15))
                                .foregroundColor(.textColor.opacity(0.75))
                            
                            Button {
                                userSession.logout()
                                navAfterLogOut = true
                            } label: {
                                Text("Change user")
                                    .font(.custom("Poppins-Regular", size: 15))
                                    .foregroundColor(.textColor.opacity(0.75))
                            }
                        }
                    }
                    // change device
                    VStack(alignment: .leading) {
                        Text("Current device: \(userSession.currentDeviceID ?? "Unknown")")
                            .font(.custom("Poppins", size: 16))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        SimpleButtonView(title: "Change Device", action: {
                            navToDevices = true
                        }, size: 100)
                            .padding(.top, -32)
                            .padding(.horizontal, -16)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top)
                    
                    Spacer()
                    // reset device
                    VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                        Text("Want to forget this device?")
                            .font(.custom("Poppins-Medium", size: 22))
                            .frame(maxWidth: .infinity)
                        
                        Button {
                            confirmChoice = true
                        } label: {
                            Text("Hard Reset")
                                .font(.custom("Poppins-Regular", size: 16))
                                .frame(maxWidth: .infinity)
                                .frame(width: UIScreen.main.bounds.width - 270)
                                .foregroundColor(.red)
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8.0)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        }
                        .padding(.bottom)
                    }
                            
                   // Spacer()
                    
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
        .navigationDestination(isPresented: $navToDevices) {
            UserDevicesView()
        }
        .alert(isPresented: $confirmChoice) {
            Alert(
                title: Text("Reset device"),
                message: Text("You are about to reset device. Are you sure?"),
                primaryButton: .default(Text("Yes, Reset")) {
                    guard let deviceId = userSession.currentDeviceID else {
                        print("No device selected to delete.")
                        return
                    }
                    Task {
                        do {
                            let msg = try await DeleteDevice.deleteUserDevice(deviceID: deviceId)
                            print("Delete success:", msg)
                        } catch {
                            print("Deletion failed: \(error)")
                        }
                    }
                    dismiss()
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(UserSession())
}
