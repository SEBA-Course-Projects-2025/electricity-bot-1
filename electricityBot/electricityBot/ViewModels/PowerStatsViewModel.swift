//
//  PowerStatsViewModel.swift
//  electricityBot
//
//  Created by Dana Litvak on 21.06.2025.
//

import Foundation
import Combine

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
}


