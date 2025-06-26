//
//  PowerStatsViewModel.swift
//  electricityBot
//
//  Created by Dana Litvak on 21.06.2025.
//

import Foundation
import Combine
import Algorithms

class PowerStatsViewModel: ObservableObject {
    @Published var stats: [PowerStats] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func requestStats(deviceID: String, days: Int = 1) {
        isLoading = true
        errorMessage = nil
        
        GetStatistics.sendRequestToBackend(deviceID: deviceID, days: days) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                    
                switch result {
                    case .success(let response):
                        self?.stats = response.events
                    case .failure(let error):
                        self?.errorMessage = "Failed to load stats: \(error.localizedDescription)"
                }
            }
        }
    }
    
    var powerOffDuration: TimeInterval {
        var duration: TimeInterval = 0
        let sortedStats = stats.sorted(by: { $0.timestamp < $1.timestamp })
        
        for (currentInterval, nextInterval) in sortedStats.adjacentPairs() {
            if currentInterval.outgateStatus == false{
                let durationInterval = nextInterval.timestamp.timeIntervalSince(currentInterval.timestamp)
                duration += durationInterval
            }
        }
        
        return duration
    }
    
    var powerOffDurationFormatted: String {
        let seconds = Int(powerOffDuration)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        return "\(hours) hours \(minutes) minutes"
    }
}

struct HourlyPowerStat: Identifiable {
    let id = UUID()
    let hour: Int
    let powerOnFragment: Double // minutes when power was on
}

extension PowerStatsViewModel {
    func computeHourlyStats() -> [HourlyPowerStat] {
        var hourStats = Array(repeating: 0.0, count: 24)
        
        let sortedStats = stats.sorted(by: { $0.timestamp < $1.timestamp })
        
        for (current, next) in sortedStats.adjacentPairs() {
            guard current.outgateStatus else { continue }
            
            var start = current.timestamp
            let end = next.timestamp
            
            while start < end {
                let calendar = Calendar.current
                let startHour = calendar.component(.hour, from: start)
                
                // Start of the next hour
                guard let nextHour = calendar.date(bySettingHour: startHour + 1, minute: 0, second: 0, of: start),
                      nextHour > start else { break }
                
                let segmentEnd = min(end, nextHour)
                let duration = segmentEnd.timeIntervalSince(start)
                hourStats[startHour % 24] += duration
                
                start = segmentEnd
            }
        }
        
        return (0..<24).map { hour in
            let fraction = min(hourStats[hour] / 3600.0, 1.0)
            return HourlyPowerStat(hour: hour, powerOnFragment: fraction)
        }
    }
    var statsByHour: [HourlyPowerStat] {
        computeHourlyStats()
    }
}
