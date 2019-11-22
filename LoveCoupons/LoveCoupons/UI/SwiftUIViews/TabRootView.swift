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
            Text("First View")
                .tabItem {
                    Image(systemName: "person.2.square.stack")
                    Text("First")
                }.tag(0)
            Text("First View")
                .tabItem {
                    Image(systemName: "person.crop.rectangle")
                    Text("First")
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
