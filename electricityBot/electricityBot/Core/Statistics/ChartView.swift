//
//  ChartView.swift
//  electricityBot
//
//  Created by Dana Litvak on 21.06.2025.
//

import SwiftUI

struct ChartView: View {
    @StateObject private var viewModel = PowerStatsViewModel()

    let deviceID: String

    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView("Loading data...")
            } else if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        ForEach(viewModel.stats.sorted(by: { $0.timestamp < $1.timestamp })) { stat in
                            let hour = Calendar.current.component(.hour, from: stat.timestamp)
                            VStack(spacing: 4) {
                                Rectangle()
                                    .fill(stat.outgateStatus ? Color.green : Color.gray.opacity(0.3))
                                    .frame(width: 30, height: 80)
                                    .cornerRadius(6)
                                Text("\(hour) \(hour >= 12 ? "pm" : "am")")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 120)
            }
        }
        .padding()
        .onAppear {
            viewModel.requestStats(deviceID: deviceID, days: 1)
        }
    }
}


#Preview {
    ChartView(deviceID: "d4dba214-e012-4dd2-b1a7-9256788a0b2a")
}
