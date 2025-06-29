//
//  ChartView.swift
//  electricityBot
//
//  Created by Dana Litvak on 21.06.2025.
//

import SwiftUI

struct StatsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PowerStatsViewModel()
    @State private var weeklyStats = false
    
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
                VStack {
                    TabView(selection: $weeklyStats) {
                        DayStatsView
                            .tag(false)

                        WeekStatsView
                            .tag(true)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .onChange(of: weeklyStats) {
                        loadStats()
                    }
                }
                .padding(.bottom)
            }

        }
        .onAppear(perform: loadStats)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackNavigation { dismiss() }
            }
        }
    }
    
    private var WeekStatsView: some View {
        // title
        VStack(alignment: .leading) {
            Text("Last 7 days\nStatistics")
                .font(.custom("Poppins-Medium", size: 32))
                .padding(.top, 50.0)
            
            // total time with power off
            VStack(alignment: .leading) {
                // text
                Text("The power was off for\n\(viewModel.powerOffDurationFormatted)")
                    .font(.custom("Poppins", size: 24))
                    .padding(.top, 30.0)
                
                // graph
                ScrollView(.horizontal) {
                    HStack(spacing: 15) {
                        ForEach(viewModel.statsByDay) { stat in
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
                                
                                Text(weekdayToString(for: stat.day))
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
            
            // button to toggle between weekly / daily stats
            Button {
                weeklyStats.toggle()
                loadStats()
            } label: {
                Text(weeklyStats ? "Show Daily Stats" : "Show Weekly Stats")
            }
            .padding(.top)
            
            Spacer()
        }
        .padding(32)
    }
    
    private func weekdayToString (for day: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter.shortWeekdaySymbols[(day - 1) % 7] // 1 is Sunday !!!!!
    }

    // stats view as distinct view
    private var DayStatsView: some View {
        VStack(alignment: .leading) {
            // title
            Text("Last 24h\nStatistics")
                .font(.custom("Poppins-Medium", size: 32))
                .padding(.top, 50.0)
            
            // total time off
            VStack(alignment: .leading) {
                Text("The power was off for\n\(viewModel.powerOffDurationFormatted)")
                    .font(.custom("Poppins", size: 24))
                    .padding(.top, 30.0)
                
                // graph
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
            
            // button to toggle between weekly / daily
            Button {
                weeklyStats.toggle()
                loadStats()
            } label: {
                Text(weeklyStats ? "Show Daily Stats" : "Show Weekly Stats")
            }
            .padding(.top)
            
            Spacer()
        }
        .padding(32)
    }

    private func loadStats() {
        let days = weeklyStats ? 7 : 1
        viewModel.requestStats(deviceID: deviceID, days: days)
    }
    
    @ViewBuilder
    private var StatsChoice: some View {
        if weeklyStats {
            WeekStatsView
        } else {
            DayStatsView
        }
    }
}

#Preview {
    StatsView(deviceID: "d4dba214-e012-4dd2-b1a7-9256788a0b2a")
}
