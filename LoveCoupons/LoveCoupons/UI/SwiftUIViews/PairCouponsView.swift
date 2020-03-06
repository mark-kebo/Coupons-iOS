//
//  PairCouponsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct PairCouponsView: View {
    var data: [String] = ["String1222", "String2222", "String3222", "String4222", "String5222"]

    var body: some View {
        VStack(alignment: .center, spacing: Constants.stackSpacing) {
            HStack {
                Text(L10n.PairCoupons.title)
                    .font(.title)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 64, alignment: .leading)
            }
            .padding()

            List {
                ForEach(data, id: \.self) {
                    Text($0)
                }
            }
        }
    }
}

struct PairCouponsView_Previews: PreviewProvider {
    static var previews: some View {
        PairCouponsView()
    }
}
