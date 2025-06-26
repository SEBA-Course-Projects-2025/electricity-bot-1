//
//  BackNavigation.swift
//  electricityBot
//
//  Created by Dana Litvak on 21.06.2025.
//

import SwiftUI

struct BackNavigation: View {
    let action: () -> Void  // this will call `dismiss()`

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .medium))
                Text("Back")
                    .font(.custom("Poppins-Regular", size: 16))
            }
            .foregroundColor(.textColor)
        }
    }
}
