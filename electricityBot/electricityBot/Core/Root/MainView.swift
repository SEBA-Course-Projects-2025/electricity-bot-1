//
//  MainView.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.07.2025.
//

import SwiftUI

enum TabBar: String, CaseIterable, CustomTabProtocol {
    case statistics = "Statistics"
    case main = "Main"
    case settings = "Settings"
    
    var symbolImage: String {
        switch self {
        case .statistics: "📊"
        case .main: "🏠"
        case .settings: "⚙️"
        }
    }
    var symbolName: String {
        switch self {
        case .statistics: "Statistics"
        case .main: "Main"
        case .settings: "Settings"
        }
    }
}
struct MainView: View {
    @State private var activeTab: TabBar = .main
    @Environment(\.dismiss) var dismiss
    var body: some View {
        CustomTabView(selection: $activeTab) { tab, tabBarHeight in
            switch tab {
            case .statistics: StatsView(deviceID: "d4dba214-e012-4dd2-b1a7-9256788a0b2a")
            case .main: Text("Main")
            case .settings: ProfileView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                BackNavigation { dismiss() }
            }
        }
    }
}

#Preview {
    MainView()
}
