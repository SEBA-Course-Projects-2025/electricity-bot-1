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
                        }
                    }
                    
                    
                    Spacer()
                    LogOutView {
                        userSession.logout()
                    }
                }
                .padding(32)
            }
            // .navigationTitle("Available Devices")
            .onAppear {
                guard let userId = userSession.user?.id else {
                    print("Cannot fetch user, failure.")
                    return
                }
                Task {
                    await getDevices(userId: userId)
                }
            }
            .navigationDestination(isPresented: Binding<Bool>(
                get: { selectedDevice != nil },
                set: { if !$0 { selectedDevice = nil } }
            )) {
                RootView()
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
    let mockSession = UserSession()
    mockSession.user = User(id: "704e89bd-4fdc-48b6-b1ed-461dd7f312eb", fullName: "Test User", email: "test@example.com")
    TokenHandler.saveToken("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTc1Mjc1NjMzNCwianRpIjoiOWQ1MmQzNTItYmIwYi00ZGE2LTk2OGMtYmJlYzUzMDE1ZmIzIiwidHlwZSI6ImFjY2VzcyIsInN1YiI6IjcwNGU4OWJkLTRmZGMtNDhiNi1iMWVkLTQ2MWRkN2YzMTJlYiIsIm5iZiI6MTc1Mjc1NjMzNCwiY3NyZiI6ImMzOWNkNTFmLThmNzgtNGI0OC1iNjEzLTg2NmRmYTU2NzQ5MyIsImV4cCI6MTc1Mjc1NzIzNH0.ZT6r4nrRO9lHZhsbcu9gV6a20fd-XV3YlNv4olzCFjA", forKey: "access_token")
    
    return UserDevicesView()
        .environmentObject(mockSession)
}
