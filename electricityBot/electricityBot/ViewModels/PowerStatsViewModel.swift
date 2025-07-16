//
//  PowerStatsViewModel.swift
//  electricityBot
//
//  Created by Dana Litvak on 21.06.2025.
//

import Foundation
import Combine
import Algorithms

@MainActor
class PowerStatsViewModel: ObservableObject {
    @Published var stats: [PowerStats] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func requestStats(deviceID: String, days: Int = 1) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await GetStatistics.sendRequestToBackend(deviceID: deviceID, days: days)
            stats = response.events
            
            print(response)
        } catch {
            errorMessage = "Failed to load stats: \(error.localizedDescription)"
        }
        
        isLoading = false
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

