//
//  LoginCoordinator.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import SwiftUI

protocol LoginCoordinatorProtocol: ErrorableCoordinatorProtocol, CoordinatorProtocol {
    func navigateToTabs()
    func navigateToSignUp()
    func navigateToRestPassword()
}

final class LoginCoordinator: LoginCoordinatorProtocol {
    weak var rootNavigationController: UINavigationController?
    
    deinit {
        NSLog("\(self) deinited")
    }
    
    init(rootNavigationController: UINavigationController?) {
        self.rootNavigationController = rootNavigationController
    }
    
    func start() {
        let viewModel = LoginViewModel(coordinator: self)
        let childView = LoginView(viewModel: viewModel)
        rootNavigationController?.setViewControllers([UIHostingController(rootView: childView)], animated: true)
    }
    
    func navigateToTabs() {
        NSLog("Navigate to tabs")
        let coordinator = RootCoordinator(rootNavigationController: rootNavigationController)
        coordinator.start()
    }
    
    func navigateToSignUp() {
        NSLog("Navigate to Sign Up")
        let coordinator = SignUpCoordinator(rootNavigationController: rootNavigationController)
        coordinator.start()
    }
    
    func navigateToRestPassword() {
        NSLog("Navigate to Rest Password")
        let coordinator = ResetPasswordCoordinator(rootNavigationController: rootNavigationController)
        coordinator.start()
    }
}
