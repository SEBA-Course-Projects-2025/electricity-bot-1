//
//  Transition.swift
//  electricityBot
//
//  Created by Dana Litvak on 22.07.2025.
//

import SwiftUI

struct TransitionView: View {
    @EnvironmentObject var userSession: UserSession
    var animation: Namespace.ID
    @Namespace private var animation2
    @State private var isActive = false
     
    var body: some View {
        if isActive {
            ContentView(animation: animation2)
        } else {
            ZStack(){
                Color.backgroundColor
                    .ignoresSafeArea()
                // logo along with welcome message
                VStack(spacing: 20){
                    Text("💡")
                        .font(.system(size: 53))
                        .shadow(color: .yellowGlow.opacity(1), radius: 25, x: 0, y: 0)
                        .matchedGeometryEffect(id: "lightbulb", in: animation)
                    Text("Welcome to \nElectricity Bot")
                        .font(Font.custom("BerlinBold", size: 23))
                        .multilineTextAlignment(.center)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.top, 200)
                
                Spacer()
            }
            .onAppear{
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.smooth(extraBounce: 0.4)) {
                        self.isActive = true
                    }
                }
            }
        }
    }
}
