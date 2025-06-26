//
//  ChartView.swift
//  electricityBot
//
//  Created by Dana Litvak on 21.06.2025.
//

import SwiftUI

struct DayStatsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PowerStatsViewModel()
    
    let deviceID: String
    
    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView("Loading data...")
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
                VStack(alignment: .leading) {
                    Text("Last 24h\nStatistics")
                        .font(.custom("Poppins-Medium", size: 32))
                        .padding(.top, 50.0)
                    
                    VStack(alignment: .leading) {
                        Text("The power was off for\n\(viewModel.powerOffDurationFormatted)")
                            .font(.custom("Poppins", size: 24))
                            .padding(.top, 30.0)
                        
                        ScrollView(.horizontal) {
                            HStack(spacing: 6) {
                                ForEach(viewModel.statsByHour) { stat in
                                    VStack(spacing: 4) {
                                        VStack(spacing: 0) {
                                            Rectangle()
                                                .fill(Color.foregroundLow.opacity(0.15))
                                                .frame(height: CGFloat(80 * (1 - stat.powerOnFragment)))
                                            
                                            Rectangle()
                                                .fill(Color.green.opacity(0.8))
                                                .frame(height: CGFloat(80 * stat.powerOnFragment))
                                        }
                                        .frame(width: 30)
                                        .cornerRadius(6)
                                        
                                        Text("\(stat.hour % 12 == 0 ? 12 : stat.hour % 12)\(stat.hour >= 12 ? "pm" : "am")")
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 130)
                        .background()
                        .cornerRadius(8.0)
                    }
                    
                    Spacer()
                }
                .padding(32)
            }
        }
        .onAppear {
            viewModel.requestStats(deviceID: deviceID, days: 1)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackNavigation { dismiss() }
            }
        }
    }
}


#Preview {
    DayStatsView(deviceID: "d4dba214-e012-4dd2-b1a7-9256788a0b2a")
}
