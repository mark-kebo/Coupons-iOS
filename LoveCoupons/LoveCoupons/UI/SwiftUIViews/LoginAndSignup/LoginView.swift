//
//  ContentView.swift
//  Test
//
//  Created by Dmitry Vorozhbicki on 11/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import Firebase

struct LoginView: View {
    private let apiManager: APIManagerProtocol = APIManager.sharedInstance

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var alertString: String = ""
    @State private var showingAlert = false

    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: Constants.stackSpacing) {
                Text(L10n.LoginSignUp.title.uppercased())
                    .padding()
                    .font(.custom(Constants.titleFont, size: 33))
                VStack {
                    PrimaryTextField(title: L10n.LoginSignUp.email, keyType: .emailAddress, text: $email)
                    PrimaryTextField(title: L10n.LoginSignUp.password, isSecure: true, text: $password)
                }
                .padding(.bottom)
                Spacer()
                PrimaryButton(title: L10n.LoginSignUp.Button.login, style: .fill) {
                    self.apiManager.login(email: self.email, password: self.password) { error in
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
                PrimaryNavigationButton(title: L10n.LoginSignUp.Button.restPassword, style: .light, destination: AnyView(ResetPasswordView()))
                    .padding(.bottom)
                PrimaryNavigationButton(title: L10n.LoginSignUp.Button.signUp, style: .light, destination: AnyView(SignUpView()))
            }
            .padding()
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
