//
//  UserDevicesView.swift
//  electricityBot
//
//  Created by Dana Litvak on 12.07.2025.
//

import SwiftUI

struct UserDevicesView: View {
    @EnvironmentObject var userSession: UserSession
    @State private var userDevices: [Device] = []
    @State private var isLoading = true
    @State private var selectedDevice: Device? = nil
    
    var body: some View {
        NavigationStack {
            ZStack(){
                Color.backgroundColor
                    .ignoresSafeArea()
                
                if isLoading {
                    ProgressView("Loading Devices...")
                } else {
                    DevicesListView(userDevices: userDevices) { device in
                        userSession.currentDeviceID = device.id
                        selectedDevice = device
                    }
                }
            }
            .navigationTitle("Available Devices")
            .onAppear {
                guard let userId = userSession.user?.id else {
                    print("Cannot fetch user, failure.")
                    return
                }
                
                getDevices(userId: userId)
            }
            .navigationDestination(isPresented: Binding<Bool>(
                get: { selectedDevice != nil },
                set: { if !$0 { selectedDevice = nil } }
            )) {
                RootView()
            }
        }
    }
        
    func getDevices (userId: String) {
        GetDevices.getUserDevices(userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let devices):
                    print("All devices: \(devices)")
                    userDevices = devices
                    
                case .failure(let error):
                    print("OOpsie. Failed to fetch devices: \(error)")
                }
            }
        }
    }
}

#Preview {
    UserDevicesView()
        .environmentObject(UserSession())
}
