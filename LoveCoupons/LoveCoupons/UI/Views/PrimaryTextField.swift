//
//  PrimaryTextView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 12/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct PrimaryTextField: View {
    var title: String
    var isSecure: Bool = false
    var keyType = UIKeyboardType.default
    @Binding var text: String

    var body: some View {
        Group {
            VStack {
                Text(!text.isEmpty ? title : " ")
                    .fontWeight(Font.Weight.light)
                    .accentColor(Color.gray.opacity(0.7))
                    .font(.custom("DRAguScript-Book", size: 14))
                    .frame(minWidth: CGFloat(0), maxWidth: .infinity, alignment: .leading)
                if isSecure {
                    SecureField(title, text: $text)
                        .padding(.horizontal)
                        .accentColor(Color.gray.opacity(0.7))
                        .keyboardType(keyType)
                        .font(.custom("DRAguScript-Book", size: 18))
                } else {
                    TextField(title, text: $text)
                        .padding(.horizontal)
                        .accentColor(Color.gray.opacity(0.7))
                        .keyboardType(keyType)
                        .font(.custom("DRAguScript-Book", size: 20))
                }
                Divider()
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 64, alignment: .leading)
        }
    }
}

struct PrimaryTextField_Previews: PreviewProvider {

    static var previews: some View {
        PrimaryTextField(title: "test", text: .constant("text"))
    }
}
