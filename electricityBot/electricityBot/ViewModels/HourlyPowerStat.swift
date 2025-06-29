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
        var hourStats: [Date: TimeInterval] = [:]
        let calendar = Calendar.current
        let now = Date()
    
        guard let toDate = calendar.dateInterval(of: .hour, for: now)?.start else {
                return []
            }
        let fromDate = calendar.date(byAdding: .hour, value: -23, to: toDate)!
        var sortedStats = stats.sorted(by: { $0.timestamp < $1.timestamp })

        // virtual start
        if let first = sortedStats.first, first.timestamp > fromDate {
            let virtualStart = PowerStats(outgateStatus: !first.outgateStatus, timestamp: fromDate)
            sortedStats.insert(virtualStart, at: 0)
        }

        // virtual end to the current hour
        if let last = sortedStats.last, last.timestamp < toDate {
            let virtualEnd = PowerStats(outgateStatus: last.outgateStatus, timestamp: toDate)
            sortedStats.append(virtualEnd)
        }

        // time per hour when power was on
        for (current, next) in sortedStats.adjacentPairs() {
            guard current.outgateStatus else { continue }

            var start = max(current.timestamp, fromDate)
            let end = min(next.timestamp, toDate)

            while start < end {
                guard let hourStart = calendar.dateInterval(of: .hour, for: start)?.start else { break }
                let nextHour = calendar.date(byAdding: .hour, value: 1, to: hourStart)!
                let segmentEnd = min(end, nextHour)
                let duration = segmentEnd.timeIntervalSince(start)

                hourStats[hourStart, default: 0] += duration
                start = segmentEnd
            }
        }

        // flip results
        var result: [HourlyPowerStat] = []
        for i in (0..<24).reversed() {
            let hourDate = calendar.date(byAdding: .hour, value: -i, to: toDate)!
            let hourStart = calendar.dateInterval(of: .hour, for: hourDate)!.start
            let hour = calendar.component(.hour, from: hourStart)

            let duration = hourStats[hourStart] ?? 0
            var fraction = min(max(duration / 3600.0, 0), 1)
            
            // edge case: if this is the event was up to f.e. 20:05 and outage status is true, the whole 8pm hour would be green
            if hourStart == toDate {
                if let lastBeforeToDate = sortedStats.last(where: { $0.timestamp <= toDate }) {
                    if lastBeforeToDate.outgateStatus == true {
                        fraction = 1.0
                    }
                }
            }

            result.append(HourlyPowerStat(hour: hour, powerOnFragment: fraction))
        }

        return result
    }

    var statsByHour: [HourlyPowerStat] {
        computeHourlyStats()
    }
}
