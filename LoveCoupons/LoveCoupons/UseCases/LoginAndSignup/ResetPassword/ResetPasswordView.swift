//
//  ResetPasswordView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 20/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct ResetPasswordView<ViewModel>: View where ViewModel: ResetPasswordViewModelProtocol {
    @State private var email: String = ""
    
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: Constants.stackSpacing) {
            Text(L10n.LoginSignUp.Button.restPassword.uppercased())
                .multilineTextAlignment(.center)
                .padding()
                .font(.custom(Constants.titleFont, size: 33))
            PrimaryTextField(title: L10n.LoginSignUp.email, keyType: .emailAddress, text: $email)
                .padding(.bottom)
            Spacer()
            PrimaryButton(title: L10n.LoginSignUp.Button.send, style: .fill) {
                viewModel.sendButtonPressed(email: email)
            }
        }
        .padding()
        .redacted(reason: viewModel.isShowLoading ? .placeholder : [])
        .allowsHitTesting(!viewModel.isShowLoading)
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView(viewModel: ResetPasswordViewModel(coordinator: ResetPasswordCoordinator(rootNavigationController: nil)))
    }
}
