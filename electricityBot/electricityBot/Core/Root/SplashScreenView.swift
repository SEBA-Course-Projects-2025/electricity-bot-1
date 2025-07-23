//
//  SplashScreenView.swift
//  electricityBot
//
//  Created by Dana Litvak on 02.06.2025.
//

import SwiftUI

struct SplashScreenView: View {
    @Namespace private var animation
    @State private var isActive = false
    @State private var size = 0.95
    @State private var glowRadius: CGFloat = 0
    
    var body: some View {
        if isActive {
            ContentView(animation: animation)
        } else {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    VStack {
                        Spacer()
                        Text("💡")
                            .font(.system(size: 93))
                            .shadow(color: .yellowGlow.opacity(1), radius: glowRadius, x: 0, y: 0)
                            .matchedGeometryEffect(id: "lightbulb", in: animation)
                        Spacer()
                    }
                    .frame(maxHeight: .infinity)
                    .scaleEffect(size)
                    .onAppear{
                        withAnimation(.easeIn(duration: 1.8)){
                            self.size = 1.0
                            self.glowRadius = 30
                        }
                    }
                }
                .onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                        withAnimation() {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
}
