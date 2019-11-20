//
//  CouponsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 20/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import Firebase

struct CouponsView: View {
    let apiManager = APIManager.sharedInstance
    
    @State var alertString: String = ""
    @State var showingAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: Constants.stackSpacing) {
                Text("Hello World!")
                PrimaryButton(title: "logout", style: .fill) {
                    self.apiManager.logout { error in
                        if let error = error {
                            self.alertString = error
                            self.showingAlert = true
                        } else {
                            let scene = UIApplication.shared.connectedScenes.first
                            if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                                sd.setupRootVC()
                            }
                        }
                    }
                }
                .alert(isPresented: $showingAlert) { () -> Alert in
                    Alert(title: Text(L10n.error), message: Text(alertString))
                }
            }
        }
    }
}

struct CouponsView_Previews: PreviewProvider {
    static var previews: some View {
        CouponsView()
    }
}
