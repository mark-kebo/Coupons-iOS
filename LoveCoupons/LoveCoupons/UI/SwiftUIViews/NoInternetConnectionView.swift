//
//  NoInternetConnectionView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 25/07/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct NoInternetConnectionView: View {
    var body: some View {
        Text(L10n.noInternetConnection)
            .font(.custom(Constants.textFont, size: 24))
            .padding()
            .multilineTextAlignment(.center)
    }
}

struct NoInternetConnectionView_Previews: PreviewProvider {
    static var previews: some View {
        NoInternetConnectionView()
    }
}
