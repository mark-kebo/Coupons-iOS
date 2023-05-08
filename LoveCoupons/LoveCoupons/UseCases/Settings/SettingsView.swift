//
//  SettingsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 22/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct SettingsView<ViewModel>: View where ViewModel: SettingsViewModelProtocol {
    private let padding: CGFloat = 16
    
    @ObservedObject private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack {
                PrimaryTextField(title: L10n.LoginSignUp.name, text: self.$viewModel.name)
                PrimaryTextField(title: L10n.LoginSignUp.email, keyType: .emailAddress, text: self.$viewModel.email)
                PrimaryTextField(title: L10n.LoginSignUp.id, text: self.$viewModel.id)
                HStack {
                    Text(verbatim: L10n.Settings.yourId)
                        .font(.custom(Constants.textFont, size: 14))
                    SelectableText(self.viewModel.userUid, selectable: true,
                                   fontSize: 14,
                                   color: UIColor(asset: Asset.appRed))
                    .frame(minWidth: 0, maxWidth: .infinity,
                           minHeight: 64, alignment: .leading)
                }
                .padding(.top, padding)
                .padding(.bottom, padding)
            }
            .redacted(reason: viewModel.isShowLoading ? .placeholder : [])
            .allowsHitTesting(!viewModel.isShowLoading)
            .padding(.top, padding)
            PrimaryButton(title: L10n.Settings.logout, style: .light) {
                viewModel.logoutButtonPressed()
            }
            .frame(minWidth: 0, maxWidth: 60, minHeight: 64, alignment: .center)
            .navigationBarTitle(Text(""),displayMode: .inline)
            .navigationBarItems(leading: Text(L10n.Settings.tab.uppercased()).font(.custom(Constants.titleFont, size: 28)), trailing: PrimaryButton(title: L10n.Settings.submit, style: .fill, maxWidth: .none) {
                viewModel.submitButtonPressed()
            })
        }
        .padding(.leading, padding)
        .padding(.trailing, padding)
        .onAppear(perform: self.onAppear)
    }
    
    private func onAppear() {
        viewModel.getUserInfo()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(viewModel: SettingsViewModel(coordinator: SettingsCoordinator(rootNavigationController: nil,
                                                                                   tabNavigationController: nil)))
    }
}
