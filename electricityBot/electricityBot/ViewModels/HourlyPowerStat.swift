//
//  HourlyPowerStat.swift
//  electricityBot
//
//  Created by Dana Litvak on 29.06.2025.
//

import Foundation

struct HourlyPowerStat: Identifiable {
    let id = UUID()
    let hour: Int
    let powerOnFragment: Double // fraction when power was on
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
