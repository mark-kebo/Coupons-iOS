//
//  TabRootView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 20/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import Firebase

struct TabRootView: View {
    
    @State private var selection = 0
    
    var body: some View {
        TabView(selection: $selection) {
            PairCouponsView()
                .tabItem {
                    Image(systemName: "person.2.square.stack")
                    Text(L10n.PairCoupons.title)
                }.tag(0)
            MyCouponsView()
                .tabItem {
                    Image(systemName: "person.crop.rectangle")
                    Text(L10n.MyCoupons.title)
                }.tag(1)
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text(L10n.Settings.tab)
                }.tag(2)
        }
    }
}

struct CouponsView_Previews: PreviewProvider {
    static var previews: some View {
        TabRootView()
    }
}
