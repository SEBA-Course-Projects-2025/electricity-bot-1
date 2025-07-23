//
//  DailyPowerStat.swift
//  electricityBot
//
//  Created by Dana Litvak on 29.06.2025.
//

import Foundation

struct DailyPowerStat: Identifiable {
    let id = UUID()
    let day: Int
    let powerOnFragment: Double // fraction when power was on
}

extension PowerStatsViewModel {
    func computeDailyStats() -> [DailyPowerStat] {
        var powerOnByDate: [Date: TimeInterval] = [:]

        let sortedStats = stats.sorted(by: { $0.timestamp < $1.timestamp })

        for (current, next) in sortedStats.adjacentPairs() {
            guard current.outgateStatus else { continue }
            let start = current.timestamp
            let end = next.timestamp

            let calendar = Calendar.current
            let startDate = calendar.startOfDay(for: start)
            let endDate = calendar.startOfDay(for: end)

            if startDate == endDate {
                powerOnByDate[startDate, default: 0] += end.timeIntervalSince(start)
            } else {
                // if the fragment, which is now being observed had no power f.e. from 11pm Monday to 2am Tuesday, make sure it count this interval as two separate
                var date = startDate
                while date <= endDate {
                    let nextDate = calendar.date(byAdding: .day, value: 1, to: date)!
                    let segmentStart = max(start, date)
                    let segmentEnd = min(end, nextDate)
                    let duration = segmentEnd.timeIntervalSince(segmentStart)
                    powerOnByDate[calendar.startOfDay(for: date), default: 0] += duration
                    date = nextDate
                }
            }
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let pastWeek = (0..<7).map { calendar.date(byAdding: .day, value: -$0, to: today)! }.reversed()

        return pastWeek.map { date in
            let duration = powerOnByDate[date] ?? 0
            let fraction = min(max(duration / 86400.0, 0), 1.0)
            let day = calendar.component(.weekday, from: date)
            return DailyPowerStat(day: day, powerOnFragment: fraction)
        }
    }

    var statsByDay: [DailyPowerStat] {
        computeDailyStats()
    }
}
