//
//  MainView.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.07.2025.
//

import SwiftUI

enum TabBar: String, CaseIterable {
    case statistics = "Statistics"
    case main = "Main"
    case settings = "Settings"
}
struct MainView: View {
    @State private var activeTab: TabBar = .main
    var body: some View {
        CustomTabView(selection: $activeTab) { tab, tabBarHeight in
            switch tab {
            case .statistics: Text("Statistics")
            case .main: Text("Main")
            case .settings: Text("Settings")
            }
        }
    }
}

#Preview {
    MainView()
}
