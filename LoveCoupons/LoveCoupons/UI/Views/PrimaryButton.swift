//
//  PrimatyButton.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 12/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

enum Style {
    case fill
    case light
}

struct PrimaryButton: View {
    @State private var color: Color = Color("AppRed")
    @State private var spacing: CGFloat = 16

    var title: String
    var style: Style
    var maxWidth: CGFloat? = .infinity
    var tapped: (() -> Void)?

    var body: some View {
        Button(action: {
            self.tapped?()
        }){
            Text(title)
                .font(style == Style.fill ? .body : .callout)
                .frame(minWidth: 0, maxWidth: maxWidth)
                .padding(style == Style.fill ? spacing : 0)
                .foregroundColor(style == Style.fill ? .white : color)
                .background(style == Style.fill ? color : color.opacity(0))
                .cornerRadius(.infinity)
        }
    }
}
