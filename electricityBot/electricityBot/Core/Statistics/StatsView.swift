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
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                VStack() {
                    Spacer()
                    CustomProgressView(text: "Loading info...")
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            } else if let error = viewModel.errorMessage {
                VStack {
                    Spacer()
                    Text("⚠️ Error")
                        .font(.title)
                        .padding(.bottom, 4)
                    Text(error)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Spacer()
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
                        Task {
                            await loadStats()
                        }
                    }
                    Spacer().frame(height: 80)
                }
                //.padding(.bottom, 16)
            }

        }
        .onAppear {
            Task {
                await loadStats()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var WeekStatsView: some View {
        // title
        VStack(alignment: .leading) {
            Text("Last 7 days\nStatistics")
                .font(.custom("Poppins-Medium", size: 32))
                // .padding(.top, 50.0)
            
            // total time with power off
            VStack(alignment: .leading) {
                // text
                Text("The power was off for\n\(viewModel.powerOffDurationFormatted)")
                    .font(.custom("Poppins", size: 24))
                    .padding(.top, 30.0)
                    .fixedSize(horizontal: false, vertical: true)
                
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
            Spacer()
            
            // button to toggle between weekly / daily stats
            SimpleButtonView(title: weeklyStats ? "Show Daily Stats" : "Show Weekly Stats", action:  {
                withAnimation {
                    weeklyStats.toggle()
                }
                Task {
                    await loadStats()
                }
            }, size: 150)
            .frame(maxWidth: .infinity)
            .padding()
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
                // .padding(.top, 50.0)
            
            // total time off
            VStack(alignment: .leading) {
                Text("The power was off for\n\(viewModel.powerOffDurationFormatted)")
                    .font(.custom("Poppins", size: 24))
                    .padding(.top, 30.0)
                    .fixedSize(horizontal: false, vertical: true)
                
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
            
            Spacer()
            
            // button to toggle between weekly / daily stats
            SimpleButtonView(title: weeklyStats ? "Show Daily Stats" : "Show Weekly Stats", action:  {
                withAnimation {
                    weeklyStats.toggle()
                }
                Task {
                    await loadStats()
                }
            }, size: 150)
            .frame(maxWidth: .infinity)
            .padding()
        }
        .padding(32)
    }

    @MainActor
    private func loadStats() async {
        guard let deviceID = userSession.currentDeviceID else {
            print("Missing device ID")
            return
        }
        await viewModel.requestStats(deviceID: deviceID, days: weeklyStats ? 7 : 1)
    }
}

#Preview {
    StatsView()
        .environmentObject(UserSession())
}
