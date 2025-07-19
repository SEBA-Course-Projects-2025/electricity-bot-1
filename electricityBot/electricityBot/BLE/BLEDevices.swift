//
//  BLEDevices.swift
//  electricityBot
//
//  Created by Dana Litvak on 16.07.2025.
//

import SwiftUI

struct BLEDevices: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var bluetooth = BluetoothManager.shared
    @State private var navToProvision = false
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack(alignment: .leading) {
                    Text("Find device")
                        .font(.custom("Poppins-Medium", size: 32))
                    // .padding(.bottom, 32)
                    
                    // button for scan
                    SimpleButtonView(title: "Scan for Raspberry Pi", action: { bluetooth.scan() }, size: 120)
                        .frame(maxWidth: .infinity)
                        .padding(.top, -32)
                    
                    // status
                    statusMessage
                        .padding()
                        .frame(maxWidth: .infinity)
                    
                    // list with available networks
                    ScrollView {
                        ForEach(bluetooth.peripherals, id: \.identifier) { peripheral in
                            Button(action: {
                                bluetooth.connect(to: peripheral)
                                navToProvision = true
                            }) {
                                HStack {
                                    Image(systemName: "cpu")
                                        .foregroundColor(.blueAccentButton)
                                    VStack(alignment: .leading) {
                                        Text(peripheral.name ?? "Unnamed Device")
                                            .font(.custom("Poppins", size: 20))
                                        Text(peripheral.identifier.uuidString.prefix(8) + "…")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
                            }
                        }
                    }
                    
                }
                .padding(32)
            }
        }
        .onAppear {
            bluetooth.userID = userSession.user?.id
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $navToProvision) {
            WiFiProvisioningView()
        }
    }
    
    var statusMessage: some View {
        Group {
                switch bluetooth.status {
                case .scanning:
                    HStack(spacing: 8) {
                        ProgressView()
                        Text("Scanning...")
                    }
                    .foregroundColor(.gray)
                case .notFound:
                    Text("❌ No Raspberry Pi found nearby")
                        .foregroundColor(.red)
                case .bluetoothOff:
                    Text("❌ Bluetooth is turned off")
                        .foregroundColor(.red)
                case .connected:
                    Text("✅ Connected to Raspberry Pi")
                        .foregroundColor(.green)
                case .error(let message):
                    Text("❌ \(message)")
                        .foregroundColor(.red)
                case .idle:
                    EmptyView()
                }
            }
            .font(.subheadline)
            .transition(.opacity.combined(with: .slide))
            .animation(.easeInOut, value: bluetooth.status)
    }
}

#Preview {
    BLEDevices()
}
