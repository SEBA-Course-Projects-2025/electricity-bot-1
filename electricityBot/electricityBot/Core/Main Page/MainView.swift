//
//  MainView.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.07.2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel = PowerStatusViewModel()
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading) {
                // situation now
                Text("Situation now")
                    .font(.custom("Poppins-Medium", size: 32))
                    .padding(.bottom, 32)
                
                // device info
                Text("Device")
                    .font(.custom("Poppins-Medium", size: 20))
                Text("UUID: \(userSession.currentDeviceID ?? "unavailable")")
                    .font(.custom("Poppins-Regular", size: 16))
                    .padding(.bottom, 32)
                
                // graph
                if viewModel.isLoading {
                    VStack() {
                        Spacer()
                        CustomProgressView(text: "Loading info...")
                            .frame(maxWidth: .infinity)
                        Spacer()
                    }
                } else if let error = viewModel.errorMessage {
                    VStack {
                        Text("⚠️ Error")
                            .font(.title)
                            .padding(.bottom, 4)
                        Text(error)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                } else {
                    StatusView
                }
                
                Spacer()
                Spacer().frame(height: 80)
            }
            .padding(32)
            .onAppear {
                Task {
                    await loadStatus()
                }
            }
        }
    }
    
    private var StatusView: some View{
        HStack {
            // image
            Image(viewModel.status ? "PowerOn" : "PowerOff")
                .resizable()
                .frame(width: 99, height: 127)
                .cornerRadius(8.0)
                .padding(.vertical, 44)
                .padding(.leading, 26)
                .shadow(color: .black.opacity(0), radius: 19, x: 46, y: 51)
                .shadow(color: .black.opacity(0.01), radius: 18, x: 30, y: 32)
                .shadow(color: .black.opacity(0.04), radius: 15, x: 17, y: 18)
                .shadow(color: .black.opacity(0.07), radius: 11, x: 7, y: 8)
                .shadow(color: .black.opacity(0.08), radius: 6, x: 2, y: 2)
            
            // text
            VStack(alignment: .leading) {
                Text(viewModel.status ? "Power is on!" : "Power is off!")
                    .font(.custom("Poppins-Medium", size: 24))
                
                Text("Power is \(viewModel.status ? "on" : "off") for \(viewModel.currentStatusDurationFormatted).")
                    .font(.custom("Poppins-Regular", size: 12))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .background(Color.white)
        .cornerRadius(8.0)
        .frame(width: 330, height: 215)
        .shadow(color: .black.opacity(0.1), radius: 20)
    }
    
    @MainActor
    private func loadStatus() async {
        guard let deviceID = userSession.currentDeviceID else {
            print("No device id current.")
            return
        }
        await viewModel.requestStatus(deviceID: deviceID)
    }
}

#Preview {
    MainView()
        .environmentObject(UserSession())
}
