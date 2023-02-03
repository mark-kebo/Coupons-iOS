//
//  MailView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 04/08/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import UIKit
import MessageUI

struct MailView: UIViewControllerRepresentable {

    @Environment(\.presentationMode) var presentation
    @Binding var result: Result<MFMailComposeResult, Error>?
    @Binding var email: String
    @Binding var body: String

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {

        @Binding var presentation: PresentationMode
        @Binding var result: Result<MFMailComposeResult, Error>?
        @Binding var email: String
        @Binding var body: String

        init(presentation: Binding<PresentationMode>,
             result: Binding<Result<MFMailComposeResult, Error>?>,
             email: Binding<String>,
             body: Binding<String>) {
            _email = email
            _body = body
            _presentation = presentation
            _result = result
        }

        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            defer {
                $presentation.wrappedValue.dismiss()
            }
            guard let error else {
                self.result = .success(result)
                return
            }
            self.result = .failure(error)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(presentation: presentation,
                           result: $result,
                           email: $email,
                           body: $body)
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<MailView>) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([email])
        vc.setSubject(L10n.Mail.subject)
        vc.setMessageBody("""
            <p>&nbsp;</p>
            <h3 style="text-align: center; color: #FF5023;">\(body)</h3>
            """, isHTML: true)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController,
                                context: UIViewControllerRepresentableContext<MailView>) {

    }
}
