//
//  SignUpView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 16/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct SignUpView<ViewModel>: View where ViewModel: SignUpViewModelProtocol {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var name: String = ""
    @State private var id: String = ""
    
    private let viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

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
                viewModel.createUserButtonPressed(name: name, email: email,
                                                  pairUniqId: id, password: password)
            }
        }
        .padding()
        Spacer()
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView(viewModel: SignUpViewModel(coordinator: SignUpCoordinator(rootNavigationController: nil)))
            .previewDevice("iPod touch (7th generation)")
    }
}
