//
//  SettingsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 22/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    
    private let apiManager = APIManager.sharedInstance
    @State private var name: String = ""
    @State private var id: String = ""
    @State private var alertString: String = ""
    @State private var alertTitle: String = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    PrimaryTextField(title: L10n.LoginSignUp.name, text: $name)
                    PrimaryTextField(title: L10n.LoginSignUp.id, text: $id)
                    HStack {
                        Text(verbatim: L10n.Settings.yourId)
                            .font(.custom("DRAguScript-Book", size: 14))
                        SelectableText(apiManager.userUid ?? "", selectable: true, fontSize: 14, color: UIColor(asset: Asset.appRed))
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 64, alignment: .leading)
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                }
                .padding(.top, 16)
                PrimaryButton(title: L10n.Settings.logout, style: .light) {
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
                .frame(minWidth: 0, maxWidth: 60, minHeight: 64, alignment: .center)
                .navigationBarTitle(Text(""),displayMode: .inline)
                .navigationBarItems(leading: Text(L10n.Settings.tab.uppercased()).font(.custom("3dumb", size: 28)), trailing: PrimaryButton(title: L10n.Settings.submit, style: .fill, maxWidth: .none) {
                    self.apiManager.set(userInfo: UserInfo(name: self.name, pairUniqId: self.id)) { error in
                        if let error = error?.localizedDescription {
                            self.alertTitle = L10n.error
                            self.alertString = error
                            self.showingAlert.toggle()
                        } else {
                            self.alertTitle = L10n.Alert.Success.title
                            self.alertString = ""
                            self.showingAlert.toggle()
                        }
                    }
                })
            }
            .padding(.leading, 16)
            .padding(.trailing, 16)
            .alert(isPresented: $showingAlert) { () -> Alert in
                Alert(title: Text(alertTitle), message: Text(alertString))
            }
        }
        .onAppear(perform: setTextFields)
    }
    
    private func setTextFields() {
        apiManager.getUserInfo { userInfo, error in
            if let error = error?.localizedDescription {
                self.alertString = error
                self.showingAlert = true
            } else if let name = userInfo?.name, let id = userInfo?.pairUniqId {
                self.name = name
                self.id = id
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
