//
//  SimpleButtonView.swift
//  electricityBot
//
//  Created by Dana Litvak on 29.06.2025.
//

import SwiftUI

struct SimpleButtonView: View {
    var title: String = "Example"
    var action: () -> Void
    var size: Int = 270
    
    var body: some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(Color.foregroundLow.opacity(0.72))
                .frame(width: UIScreen.main.bounds.width - CGFloat(size), height: 52)
        }
        .background(Color.white)
        .cornerRadius(8.0)
        .padding(.top, 32.0)
        .padding(.horizontal, 16.0)
        .shadow(color: .black.opacity(0), radius: 51, x: 145, y: 112)
        .shadow(color: .black.opacity(0), radius: 47, x: 93, y: 72)
        .shadow(color: .black.opacity(0.01), radius: 40, x: 52, y: 40)
        .shadow(color: .black.opacity(0.02), radius: 29, x: 23, y: 18)
        .shadow(color: .black.opacity(0.02), radius: 16, x: 6, y: 4)
    }
}

