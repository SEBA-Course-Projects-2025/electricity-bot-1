//
//  InputFieldView.swift
//  electricityBot
//
//  Created by Dana Litvak on 11.06.2025.
//

import SwiftUI

struct InputFieldView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.custom("Poppins-Regular", size: 16))
            if isSecureField {
                HStack {
                    SecureField(placeholder, text: $text)
                        .padding(.all, 17.0)
                        .font(.custom("Poppins-Regular", size: 14))
                        .focused($isFocused)
                    Image(systemName: "eye")
                        .padding(17)
                        .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                }
                .background(RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? Color.yellowGlow : Color.gray, lineWidth: 1))
            } else {
                TextField(placeholder, text: $text)
                    .padding(.all, 17.0)
                    .font(.custom("Poppins-Regular", size: 14))
                    .focused($isFocused)
                    .background(RoundedRectangle(cornerRadius: 8)
                        .stroke(isFocused ? Color.yellowGlow : Color.gray, lineWidth: 1))
            }
        }
    }
}

#Preview {
    InputFieldView(text: .constant(""), title: "Email", placeholder: "example@kse.org.ua")
}
