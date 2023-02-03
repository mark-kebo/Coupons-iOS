//
//  RootCoordinator.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import SwiftUI
import Firebase

final class RootCoordinator: CoordinatorProtocol {
    var rootNavigationController: UINavigationController?
    private let window: UIWindow?
    private let firebaseAuth = Auth.auth()
    
    deinit {
        NSLog("\(self) deinited")
    }
    
    init(window: UIWindow?) {
        self.window = window
    }
    
    init(rootNavigationController: UINavigationController?) {
        self.rootNavigationController = rootNavigationController
        self.window = nil
    }
    
    func start() {
        guard let window else {
            setupRootViewController()
            return
        }
        rootNavigationController = UINavigationController()
        window.rootViewController = rootNavigationController
        window.tintColor = UIColor(named: Constants.redColor)
        window.makeKeyAndVisible()
        setupRootViewController()
    }
    
    private func setupRootViewController() {
        if firebaseAuth.currentUser != nil {
            let coordinator = MainTabBarCoordinator(rootNavigationController: rootNavigationController)
            coordinator.start()
        } else {
            let coordinator = LoginCoordinator(rootNavigationController: rootNavigationController)
            coordinator.start()
        }
    }
}
