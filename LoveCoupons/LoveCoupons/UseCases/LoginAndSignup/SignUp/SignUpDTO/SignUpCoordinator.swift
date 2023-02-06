//
//  SignUpCoordinator.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import SwiftUI

protocol SignUpCoordinatorProtocol: ErrorableCoordinatorProtocol, CoordinatorProtocol {
    func navigateToTabs()
}

final class SignUpCoordinator: SignUpCoordinatorProtocol {
    weak var rootNavigationController: UINavigationController?
    
    deinit {
        NSLog("\(self) deinited")
    }
    
    init(rootNavigationController: UINavigationController?) {
        self.rootNavigationController = rootNavigationController
    }
    
    func start() {
        let viewModel = SignUpViewModel(coordinator: self)
        let childView = SignUpView(viewModel: viewModel)
        rootNavigationController?.pushViewController(UIHostingController(rootView: childView), animated: true)
    }
    
    func navigateToTabs() {
        NSLog("Navigate to tabs")
        RootCoordinator().start()
    }
}
