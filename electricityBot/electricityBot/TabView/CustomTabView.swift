//
//  TabView.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.07.2025.
//

import SwiftUI

struct CustomTabView<Content: View, Value: CaseIterable & Hashable>: View where Value.AllCases: RandomAccessCollection {
    @Binding var selection: Value
    // returns height of tab bar
    var content: (Value, CGFloat) -> Content
    
    init(selection: Binding<Value>, @ViewBuilder content: @escaping (Value, CGFloat) -> Content) {
        self._selection = selection
        self.content = content
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selection) {
                ForEach(Value.allCases, id: \.hashValue) { tab in
                    content(tab, 0)
                        .tag(tab)
                        .toolbar(.hidden, for: .tabBar) 
                }
            }
        }
    }
}

// tab bar config
struct TabBarConfiguration {
    var activeColor: Color = .yellow
    var activeBackgroundColor: Color = .blue
    var inactiveColor: Color = .gray
    var backgroundColor: Color = .gray.opacity(0.1)
    var tabAnimation: Animation = .smooth(duration: 0.35, extraBounce: 0)
    var insetAmount: CGFloat = 6
    var isTranslucent: Bool = true
}

/*
fileprivate struct CustomTabBar: View {
    var body: some View {
        
    }
}
*/
