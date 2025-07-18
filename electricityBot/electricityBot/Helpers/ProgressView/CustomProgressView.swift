//
//  CustomProgressView.swift
//  electricityBot
//
//  Created by Dana Litvak on 17.07.2025.
//

import SwiftUI

struct CustomProgressView: View {
    @State private var currentIndex = 0
    let timer = Timer.publish(every: 0.4, on: .main, in: .common).autoconnect()
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(i == currentIndex ? Color.blueAccentButton : Color.gray.opacity(0.2))
                    .frame(width: 10, height: 10)
                    .scaleEffect(i == currentIndex ? 1.2 : 1)
                    .animation(.easeInOut, value: currentIndex)
            }
        }
        .onReceive(timer) { _ in
            currentIndex = (currentIndex + 1) % 3
        }
        
        Text(text)
            .font(.custom("Poppins", size: 18))
            .padding(6)
            .foregroundColor(.gray.opacity(0.8))
    }
}


#Preview {
    CustomProgressView(text: "Loading...")
}
