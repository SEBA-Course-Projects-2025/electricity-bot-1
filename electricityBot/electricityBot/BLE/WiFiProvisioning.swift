//
//  WiFiProvisioning.swift
//  electricityBot
//
//  Created by Dana Litvak on 16.07.2025.
//

import SwiftUI

struct WiFiProvisioningView: View {
    @EnvironmentObject var userSession: UserSession
    @ObservedObject var bluetooth = BluetoothManager.shared
    @State private var selectedSSID: String = ""
    @State private var password: String = ""
    @State private var confirmChoice = false
    @State private var sending = false
    @State private var fetching = false
    @State private var chooseDevices = false
    @State private var navBack = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    Text("WiFi Setup")
                        .font(.custom("Poppins-Medium", size: 28))

                    // fields to enter wifi info
                    Group {
                        TextField("WiFi Network Name (SSID)", text: $selectedSSID)
                            .padding(17.0)
                            .font(.custom("Poppins-Regular", size: 14))
                            .background(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1))
                        
                        SecureField("Password", text: $password)
                            .padding(17.0)
                            .font(.custom("Poppins-Regular", size: 14))
                            .background(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1))
                    }

                    // response handling
                    if sending {
                        ProgressView("Sending credentials...")
                            .padding(.top, 8.0)
                            .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    } else {
                        SimpleButtonView(title: "Send Credentials", action: { confirmChoice = true }, size: 170)
                            .padding(.top, -32.0)
                            .frame(maxWidth: .infinity)
                    }
                   
                    if fetching {
                        ProgressView("Looking for Networks...")
                            .frame(maxWidth: .infinity)
                    } else {
                        Button {
                            fetching = true
                            bluetooth.fetchNetworks()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                fetching = false
                            }
                        } label: {
                            HStack {
                                Text("🔎 Get Available Networks")
                                    .font(.custom("Poppins-SemiBold", size: 16))
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        if !bluetooth.availableNetworks.isEmpty {
                            Text("Select WiFi network:")
                                .font(.custom("Poppins-SemiBold", size: 14))

                            Picker("Available Networks", selection: $selectedSSID) {
                                ForEach(bluetooth.availableNetworks, id: \.self) { network in
                                    Text(network).tag(network)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .padding(17.0)
                            .background(RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 1))
                        }
                    }

                    // status info
                    Divider()
                    
                    VStack {
                        if !bluetooth.statusMessage.isEmpty {
                            Text("Status: \(bluetooth.statusMessage)")
                                .font(.custom("Poppins", size: 12))
                                .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                        }
                        
                        if bluetooth.connectedPeripheral != nil {
                            Text("Connected to: \(bluetooth.connectedPeripheral?.name ?? "Unknown")")
                                .font(.custom("Poppins", size: 12))
                                .foregroundColor(.foregroundLow)
                            
                           // get device id
                        }
                    }
                    
                    // Spacer()
                }
                .padding()
            }
            .alert(isPresented: $confirmChoice) {
                Alert(
                    title: Text("Send WiFi Credentials"),
                    message: Text("You're about to send WiFi info to the device. Are you sure?"),
                    primaryButton: .default(Text("Yes, Send")) {
                        sending = true
                        bluetooth.send(ssid: selectedSSID, password: password)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            sending = false
                            chooseDevices = true
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onChange(of: bluetooth.deviceID) { previousID, currentID in
                if let id = currentID {
                    userSession.currentDeviceID = id
                    print("Set currentDeviceID to \(id)")
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $chooseDevices){
            RootView()
                .environmentObject(userSession)
        }
        .navigationDestination(isPresented: $navBack){
            BLEDevices()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackNavigation(navToContent: $navBack)
            }
        }
    }
}

#Preview {
    WiFiProvisioningView()
}
