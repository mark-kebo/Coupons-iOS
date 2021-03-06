//
//  SignUpView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 16/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct SignUpView: View {
    private let apiManager: APIManagerProtocol = APIManager.sharedInstance

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var id: String = ""
    @State private var alertString: String = ""
    @State private var showingAlert = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    var body: some View {
        VStack(alignment: .center, spacing: Constants.stackSpacing) {
            Text(L10n.LoginSignUp.Button.signUp.uppercased())
                .font(.custom(Constants.titleFont, size: 33))
            VStack {
                PrimaryTextField(title: L10n.LoginSignUp.name, text: $name)
                PrimaryTextField(title: L10n.LoginSignUp.id, text: $id)
                PrimaryTextField(title: L10n.LoginSignUp.email, keyType: .emailAddress, text: $email)
                PrimaryTextField(title: L10n.LoginSignUp.password, isSecure: true, text: $password)
            }
            .padding(.bottom)
            Spacer()
            PrimaryButton(title: L10n.LoginSignUp.Button.create, style: .fill) {
                self.apiManager.createUser(userInfo: UserInfo(name: self.name, email: self.email, pairUniqId: self.id), email: self.email, password: self.password) { error in
                    if let error = error?.localizedDescription {
                        self.alertString = error
                        self.showingAlert.toggle()
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
        .padding()
        Spacer()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .previewDevice("iPod touch (7th generation)")
    }
}
