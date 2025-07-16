//
//  PowerStatusViewModel.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.07.2025.
//

import Foundation
import Combine
import Algorithms

@MainActor
class PowerStatusViewModel: ObservableObject {
    @Published var status: Bool = false
    @Published var time: Date = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?

    func requestStatus(deviceID: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await GetStatus.sendRequestToBackend(deviceID: deviceID)
            self.status = response.status
            self.time = response.timestamp
            
            print(response)
        } catch {
            self.errorMessage = "Failed to load status: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    var currentStatusDuration: TimeInterval {
        return Date().timeIntervalSince(time)
    }
    
    var currentStatusDurationFormatted: String {
        let seconds = Int(currentStatusDuration)
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        
        return hours == 0 ? "\(minutes) minutes" : "\(hours) hours \(minutes) minutes"
    }
}

