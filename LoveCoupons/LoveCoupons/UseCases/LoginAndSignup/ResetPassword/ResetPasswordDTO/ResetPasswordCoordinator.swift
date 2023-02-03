//
//  ResetPasswordCoordinator.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import SwiftUI

protocol ResetPasswordCoordinatorProtocol: ErrorableCoordinatorProtocol, CoordinatorProtocol {
    func showSuccessMessage()
}

final class ResetPasswordCoordinator: ResetPasswordCoordinatorProtocol {
    weak var rootNavigationController: UINavigationController?
    
    deinit {
        NSLog("\(self) deinited")
    }
    
    init(rootNavigationController: UINavigationController?) {
        self.rootNavigationController = rootNavigationController
    }
    
    func start() {
        let viewModel = ResetPasswordViewModel(coordinator: self)
        let childView = ResetPasswordView(viewModel: viewModel)
        rootNavigationController?.pushViewController(UIHostingController(rootView: childView), animated: true)
    }
    
    func showSuccessMessage() {
        NSLog("Show success message")
        let alert = UIAlertController(title: L10n.Alert.Success.title,
                                      message: L10n.Alert.resetPassword,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: L10n.Alert.Button.cancel,
                                      style: UIAlertAction.Style.default, handler: nil))
        rootNavigationController?.present(alert, animated: true, completion: nil)
    }
}
