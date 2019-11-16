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
    @Binding var text: String

    var body: some View {
        Group {
            if isSecure {
                VStack {
                    SecureField(title, text: $text)
                        .padding(.horizontal)
                        .padding(.top)
                        .accentColor(Color.gray.opacity(0.7))
                    Divider()
                }
            } else {
                VStack {
                    TextField(title, text: $text)
                        .padding(.horizontal)
                        .padding(.top)
                        .accentColor(Color.gray.opacity(0.7))
                    Divider()
                }
            }
        }
    }
}
