//
//  TabView.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.07.2025.
//

import SwiftUI

protocol CustomTabProtocol {
    var symbolImage: String { get }
    var symbolName: String { get }
}

struct CustomTabView<Content: View, Value: CaseIterable & Hashable & CustomTabProtocol>: View where Value.AllCases: RandomAccessCollection {
    @Binding var selection: Value
    // returns height of tab bar
    var content: (Value, CGFloat) -> Content
    var config: TabBarConfiguration
    
    init(config: TabBarConfiguration = .init(), selection: Binding<Value>, @ViewBuilder content: @escaping (Value, CGFloat) -> Content) {
        self.config = config
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
            
            CustomTabBar(config: config, activeTab: $selection)
        }
    }
}

// tab bar config
struct TabBarConfiguration {
    var activeColor: Color = .blueAccentButton
    var activeBackgroundColor: Color = .blueAccentButton
    var inactiveColor: Color = .gray
    var backgroundColor: Color = .white
    var tabAnimation: Animation = .smooth(duration: 0.35, extraBounce: 0)
    var insetAmount: CGFloat = 6
    var isTranslucent: Bool = true
}


fileprivate struct CustomTabBar<Value: CaseIterable & Hashable & CustomTabProtocol>: View where Value.AllCases: RandomAccessCollection {
    
    var config: TabBarConfiguration
    @Binding var activeTab: Value
    
    // animation
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 48) {
            ForEach(Value.allCases, id: \.hashValue) { tab in
                let isActive = activeTab == tab
                
                VStack(alignment: .center, spacing: 4) {
                    Text(tab.symbolImage)
                        .font(.custom("Poppins", size: 24))
                        .scaleEffect(isActive ? 1.2 : 1.0)
                        .opacity(isActive ? 1.0 : 0.7)
                        .animation(.spring(response: 0.3, dampingFraction: 0.4), value: isActive)
                        .frame(maxWidth: 64, maxHeight: 32)
                        .contentShape(.rect)
                        .background {
                            if isActive {
                                Capsule(style: .continuous)
                                    .fill(config.activeBackgroundColor.opacity(0.2))
                                    .matchedGeometryEffect(id: "ACTIVETAB", in: animation )
                            }
                        }
                        .onTapGesture {
                            activeTab = tab
                        }
                
                    Text(tab.symbolName)
                        .font(.custom("Poppins-SemiBold", size: 11))
                        .offset(y: isActive ? 5 : 0)
                        .animation(.interpolatingSpring(stiffness: 120, damping: 5), value: isActive)

                }
            }
        }
        .padding(.horizontal, config.insetAmount)
        .frame(width: 350, height: 80)
        .background{
            ZStack {
                if config.isTranslucent {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                } else {
                    Rectangle()
                        .fill(.background)
                }
                
                Rectangle()
                    .fill(config.backgroundColor)
            }
        }
        .clipShape(.capsule(style: .continuous))
        .animation(config.tabAnimation, value: activeTab)
    }
}

#Preview {
    RootView()
}
