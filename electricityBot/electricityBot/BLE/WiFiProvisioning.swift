//
//  WiFiProvisioning.swift
//  electricityBot
//
//  Created by Dana Litvak on 16.07.2025.
//

import SwiftUI

struct WiFiProvisioningView: View {
    @ObservedObject var bluetooth = BluetoothManager.shared
    @State private var selectedSSID: String = ""
    @State private var password: String = ""
    @State private var confirmChoice = false
    @State private var sending = false
    @State private var fetching = false
    
    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 24) {
                Text("WiFi Setup")
                    .font(.custom("Poppins-Medium", size: 28))


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
                            Image(systemName: "magnifyingglass.circle.fill")
                            Text("Get Available Networks")
                                .font(.custom("Poppins-SemiBold", size: 16))
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                Divider()
                
                VStack {
                    if !bluetooth.statusMessage.isEmpty {
                        Text("Status: \(bluetooth.statusMessage)")
                            .font(.custom("Poppins", size: 12))
                            .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    }
                    
                    if let peripheral = bluetooth.connectedPeripheral {
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
                    }
                },
                secondaryButton: .cancel()
            )
        }
    }
}

#Preview {
    WiFiProvisioningView()
}
