//
//  PrimaryNavigationButton.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 16/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct PrimaryNavigationButton <Content: View>: View {
    @State private var color: Color = Color(Constants.redColor)
    @State private var spacing: CGFloat = 8

    var title: String
    var style: Style
    var destination: Content?

    var body: some View {
        NavigationLink(destination: destination) {
            Text(title)
                .font(.custom(Constants.textFont, size: 20))
                .font(style == Style.fill ? .body : .callout)
                .frame(minWidth: 0, maxWidth: .infinity)
                .padding(style == Style.fill ? spacing : 0)
                .foregroundColor(style == Style.fill ? .white : color)
                .background(style == Style.fill ? color : color.opacity(0))
                .cornerRadius(8)
        }
    }
}

struct PrimaryNavigationButton_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryNavigationButton<AnyView>(title: "Test", style: .fill, destination: nil)
    }
}
