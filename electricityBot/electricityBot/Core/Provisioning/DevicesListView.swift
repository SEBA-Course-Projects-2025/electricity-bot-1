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
    
    var body: some View {
        VStack(spacing: 16) {
            ForEach(userDevices, id: \.id) { device in
                Button(action : {onDeviceTap(device)}) {
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading) {
                                Text("Device ID: \(device.id)")
                                    .font(.headline)
                                if let lastSeen = device.lastSeen {
                                    Text("Last seen: \(lastSeen)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 3)
                    }
            }
            
            Spacer()
            
            // find devices button
            
            // logout option
            LogOutView {
                userSession.logout()
                
            }
        }
        .padding()
    }
}


