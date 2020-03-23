//
//  PrimaryNavigationButton.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 16/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct PrimaryNavigationButton: View {
    @State private var color: Color = Color("AppRed")
    @State private var spacing: CGFloat = 10

    var title: String
    var style: Style
    var destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(style == Style.fill ? .body : .callout)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(style == Style.fill ? spacing : 0)
                .foregroundColor(style == Style.fill ? .white : color)
                .background(style == Style.fill ? color : color.opacity(0))
                .cornerRadius(.infinity)
        }
    }
}
