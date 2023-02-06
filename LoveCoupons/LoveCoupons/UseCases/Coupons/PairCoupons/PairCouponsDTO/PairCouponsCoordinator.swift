//
//  PairCouponsCoordinator.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import SwiftUI
import MessageUI

protocol PairCouponsCoordinatorProtocol: ErrorableCoordinatorProtocol, TabCoordinatorProtocol {
    func showSendMailPicker(result: Binding<Result<MFMailComposeResult, Error>?>,
                            emailMessage: Binding<String>,
                            bodyMessage: Binding<String>)
}

final class PairCouponsCoordinator: PairCouponsCoordinatorProtocol {
    weak var rootNavigationController: UINavigationController?
    weak var tabNavigationController: UINavigationController?

    deinit {
        NSLog("\(self) deinited")
    }
    
    init(rootNavigationController: UINavigationController?,
         tabNavigationController: UINavigationController?) {
        self.rootNavigationController = rootNavigationController
        self.tabNavigationController = tabNavigationController
    }
    
    func start() {
        let viewModel = PairCouponsViewModel(coordinator: self)
        let childView = PairCouponsView(viewModel: viewModel)
        tabNavigationController?.pushViewController(UIHostingController(rootView: childView), animated: true)
    }
    
    func showSendMailPicker(result: Binding<Result<MFMailComposeResult, Error>?>,
                            emailMessage: Binding<String>,
                            bodyMessage: Binding<String>) {
        NSLog("Show send mail picker")
        let mailView = MailView(result: result,
                                email: emailMessage,
                                body: bodyMessage)
        tabNavigationController?.present(UIHostingController(rootView: mailView), animated: true)
    }
}
