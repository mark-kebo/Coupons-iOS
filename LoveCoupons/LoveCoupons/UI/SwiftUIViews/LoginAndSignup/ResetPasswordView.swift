//
//  ResetPasswordView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 20/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct ResetPasswordView: View {
    private let apiManager = APIManager.sharedInstance

    @State private var email: String = ""
    @State private var alertTitle: String = ""
    @State private var alertString: String = ""
    @State private var showingAlert = false
    
    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: Constants.stackSpacing) {
                Text(L10n.LoginSignUp.Button.restPassword)
                    .padding()
                    .font(.title)
                
                PrimaryTextField(title: L10n.LoginSignUp.email, keyType: .emailAddress, text: $email)
                .padding(.bottom)
                
                PrimaryButton(title: L10n.LoginSignUp.Button.send, style: .fill) {
                    self.apiManager.resetPassword(email: self.email) { error in
                        if let error = error?.localizedDescription {
                            self.alertTitle = L10n.error
                            self.alertString = error
                            self.showingAlert.toggle()
                        } else {
                            self.alertTitle = L10n.Alert.Success.title
                            self.alertString = L10n.Alert.resetPassword
                            self.showingAlert.toggle()
                        }
                    }
                }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertString), dismissButton: .default(Text("OK"), action: {
                            self.mode.wrappedValue.dismiss()
                    }))
                }
            }
            .padding()
            Spacer()
        }
    }
}

struct ResetPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ResetPasswordView()
    }
}
