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
        ScrollView {
            Spacer()
            VStack(alignment: .center, spacing: Constants.stackSpacing) {
                HStack {
                    Text(L10n.Settings.tab)
                        .font(.title)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    Spacer()
                    PrimaryButton(title: L10n.Settings.submit, style: .fill, maxWidth: .none) {
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
                    }
                }
                VStack {
                    PrimaryTextField(title: L10n.LoginSignUp.name, text: $name)
                    PrimaryTextField(title: L10n.LoginSignUp.id, text: $id)
                }
                .padding(.bottom)
                Spacer()
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
            }
            .alert(isPresented: $showingAlert) { () -> Alert in
                Alert(title: Text(alertTitle), message: Text(alertString))
            }
            .padding()
            Spacer()
        }
        .onAppear {
            self.setTextFields()
        }
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
