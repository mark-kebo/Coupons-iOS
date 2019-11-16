//
//  SignUpView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 16/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct SignUpView: View {
    let stackSpacing: CGFloat = 16
    @State var email: String = ""
    @State var password: String = ""
    @State var name: String = ""
    @State var id: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: stackSpacing) {
                Text(L10n.LoginSignUp.Button.signUp)
                    .font(.title)
                VStack {
                    PrimaryTextField(title: L10n.LoginSignUp.name, text: $name)
                    PrimaryTextField(title: L10n.LoginSignUp.id, text: $id)
                    PrimaryTextField(title: L10n.LoginSignUp.email, text: $email)
                    PrimaryTextField(title: L10n.LoginSignUp.password, text: $password)
                }
                .padding(.bottom)
                
                PrimaryButton(title: L10n.LoginSignUp.Button.create, style: .fill) {
                    print("test")
                }
            }
            .padding()
            Spacer()
        }

        .navigationBarHidden(true)
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
