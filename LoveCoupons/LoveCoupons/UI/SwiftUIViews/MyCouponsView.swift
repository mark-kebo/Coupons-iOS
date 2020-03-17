//
//  MyCouponsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 04/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct MyCouponsView: View {
    var data: [String] = ["String1", "String2", "String3", "String4", "String5"]
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.stackSpacing) {
            HStack {
                Text(L10n.MyCoupons.title)
                    .font(.title)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 64, alignment: .leading)
                Spacer()
                PrimaryButton(title: L10n.Button.add, style: .fill, maxWidth: .none) {
                        
                }
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

struct MyCouponsView_Previews: PreviewProvider {
    static var previews: some View {
        MyCouponsView()
    }
}
