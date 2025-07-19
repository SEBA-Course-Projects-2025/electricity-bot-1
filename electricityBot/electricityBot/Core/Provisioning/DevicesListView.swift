//
//  DevicesListView.swift
//  electricityBot
//
//  Created by Dana Litvak on 13.07.2025.
//

import SwiftUI

struct DevicesListView: View {
    @EnvironmentObject var userSession: UserSession
    let userDevices: [Device]
    let onDeviceTap: (Device) -> Void
    var size: CGFloat = 145

    var body: some View {
        ZStack {
            Color.backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    ForEach(userDevices, id: \.id) { device in
                        Button(action: { onDeviceTap(device) }) {
                            HStack {
                                Text("🔋")
                                    .font(.custom("Poppins", size: 57))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Device ID: \(device.id)")
                                        .font(.custom("Poppins-SemiBold", size: 16))
                                        .foregroundColor(.foregroundLow)
                                        .multilineTextAlignment(.leading)

                                    if let lastSeen = device.lastSeen {
                                        Text("Last seen: \(lastSeen)")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 8)
                            }
                            .padding()
                            .frame(height: size)
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.1), radius: 20)
                        }
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
                .padding(.top, 5)
            }
        }
    }
}
