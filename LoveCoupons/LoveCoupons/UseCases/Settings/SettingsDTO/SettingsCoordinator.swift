//
//  SettingsCoordinator.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import SwiftUI

protocol SettingsCoordinatorProtocol: ErrorableCoordinatorProtocol, TabCoordinatorProtocol {
    func navigateToLogin()
}

final class SettingsCoordinator: SettingsCoordinatorProtocol {
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
        let viewModel = SettingsViewModel(coordinator: self)
        let childView = SettingsView(viewModel: viewModel)
        tabNavigationController?.pushViewController(UIHostingController(rootView: childView), animated: true)
    }
    
    func navigateToLogin() {
        NSLog("Navigate to tabs")
        let coordinator = RootCoordinator(rootNavigationController: rootNavigationController)
        coordinator.start()
    }
}
