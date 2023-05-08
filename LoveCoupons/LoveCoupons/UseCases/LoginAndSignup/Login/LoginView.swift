//
//  LoginView.swift
//  Test
//
//  Created by Dmitry Vorozhbicki on 11/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import Firebase

struct LoginView<ViewModel>: View where ViewModel: LoginViewModelProtocol {
    @State private var email: String = ""
    @State private var password: String = ""
    
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
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
                viewModel.loginButtonPressed(userLogin: email, userPass: password)
            }
            PrimaryButton(title: L10n.LoginSignUp.Button.restPassword, style: .light) {
                viewModel.restPasswordButtonPressed()
            }
            .padding(.bottom)
            PrimaryButton(title: L10n.LoginSignUp.Button.signUp, style: .light) {
                viewModel.signUpButtonPressed()
            }
        }
        .padding()
        .redacted(reason: viewModel.isShowLoading ? .placeholder : [])
        .allowsHitTesting(!viewModel.isShowLoading)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel(coordinator: LoginCoordinator(rootNavigationController: nil)))
    }
}
