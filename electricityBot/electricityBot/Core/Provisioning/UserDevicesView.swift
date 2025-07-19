//
//  UserDevicesView.swift
//  electricityBot
//
//  Created by Dana Litvak on 12.07.2025.
//

import SwiftUI

struct UserDevicesView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var userSession: UserSession
    @State private var userDevices: [Device] = []
    @State private var isLoading = true
    @State private var selectedDevice: Device? = nil
    @State private var findDevice = false
    @State private var navToRoot = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading){
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    // choose device
                    Text("Choose device")
                        .font(.custom("Poppins-Medium", size: 32))
                        .padding(.bottom, 32)
                    
                    if isLoading {
                        VStack() {
                            Spacer()
                            CustomProgressView(text: "Loading devices...")
                                .frame(maxWidth: .infinity)
                            Spacer()
                        }
                    } //else if let error =  {
                        
                    
                    else {
                        DevicesListView(userDevices: userDevices) { device in
                            userSession.currentDeviceID = device.id
                            selectedDevice = device
                            navToRoot = true
                        }
                    }
                    
                    Spacer()
                    SimpleButtonView(title: "Find Device 🔎", action: { findDevice = true }, size: 200)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .padding(.bottom)
                    //Spacer()
                    LogOutView {
                        userSession.logout()
                    }
                }
                .padding(32)
            }
            // .navigationTitle("Available Devices")
            .onAppear {
                Task {
                    guard let userId = userSession.user?.id else { return }
                    await getDevices(userId: userId)
                }
            }
            .navigationDestination(isPresented: $navToRoot) {
                RootView().environmentObject(userSession)
            }
            .navigationDestination(isPresented: Binding<Bool>(
                get: { selectedDevice != nil },
                set: { if !$0 { selectedDevice = nil } }
            )) {
                RootView().environmentObject(userSession)
            }
            .navigationDestination(isPresented: $findDevice) {
                BLEDevices()
            }
        }
    }
        
    @MainActor
    func getDevices (userId: String) async {
        isLoading = true
        
        do {
            let devices = try await GetDevices.getUserDevices(userID: userId)
            print("All devices: \(devices)")
            userDevices = devices
        } catch {
            print("Failed to fetch devices: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    UserDevicesView()
        .environmentObject(UserSession())
}
