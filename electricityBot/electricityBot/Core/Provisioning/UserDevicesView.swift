//
//  UserDevicesView.swift
//  electricityBot
//
//  Created by Dana Litvak on 12.07.2025.
//

import SwiftUI

struct UserDevicesView: View {
    @EnvironmentObject var userSession: UserSession
    @Namespace var animation
    @State private var userDevices: [Device] = []
    @State private var isLoading = true
    @State private var selectedDevice: Device? = nil
    @State private var navToFindDevice = false
    @State private var navToRoot = false
    @State private var navToContent = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .leading){
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
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
                    } else {
                        ZStack {
                            DevicesListView(userDevices: userDevices) { device in
                                userSession.currentDeviceID = device.id
                                selectedDevice = device
                                navToRoot = true
                            }
                            .padding(-32.0)
                            .padding(.bottom, 16)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer()
                    SimpleButtonView(title: "Find Device 🔎", action: { navToFindDevice = true }, size: 200)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                        .padding(.bottom)
                    LogOutView {
                        userSession.logout()
                    }
                }
                .padding(32)
            }
            .onAppear {
                Task {
                    guard let userId = userSession.user?.id else { return }
                    await getDevices(userId: userId)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: Binding<Bool>(
            get: { selectedDevice != nil },
            set: { if !$0 { selectedDevice = nil } }
        )) {
            RootView().environmentObject(userSession)
        }
        .navigationDestination(isPresented: $navToFindDevice) {
            BLEDevices()
        }
        .navigationDestination(isPresented: $navToRoot) {
            RootView().environmentObject(userSession)
        }
        .navigationDestination(isPresented: $navToContent) {
            ContentView(animation: animation).environmentObject(userSession)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackNavigation(navToContent: $navToContent)
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
