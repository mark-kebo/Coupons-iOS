//
//  ContentView.swift
//  Test
//
//  Created by Dmitry Vorozhbicki on 11/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    let stackSpacing: CGFloat = 16
    @State var email: String = ""
    @State var password: String = ""

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: stackSpacing) {
                    Text("Hello")
                        .padding()
                        .font(.title)
                    VStack {
                        PrimaryTextField(title: L10n.LoginSignUp.email, text: $email)
                        PrimaryTextField(title: L10n.LoginSignUp.password, isSecure: true, text: $password)
                    }
                    .padding(.bottom)
                    
                    PrimaryButton(title: L10n.LoginSignUp.Button.login, style: .fill) {
                        print("test")
                    }
                    PrimaryNavigationButton(title: L10n.LoginSignUp.Button.restPassword, style: .light, destination: AnyView(SignUpView()))
                    PrimaryNavigationButton(title: L10n.LoginSignUp.Button.signUp, style: .light, destination: AnyView(SignUpView()))
                }
                .padding()
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
