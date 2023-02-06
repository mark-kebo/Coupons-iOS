//
//  MainTabBarCoordinator.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit

final class MainTabBarCoordinator: RootTabBarCoordinatorProtocol {
    var rootNavigationController: UINavigationController?
    var rootTabBarController: UITabBarController?
    
    init(rootNavigationController: UINavigationController?) {
        self.rootNavigationController = rootNavigationController
        self.rootNavigationController?.isNavigationBarHidden = true
    }
    
    deinit {
        NSLog("\(self) deinited")
    }
    
    func start() {
        rootTabBarController = UITabBarController()
        let pairCouponsNavigationController = UINavigationController()
        let pairCouponsItem = UITabBarItem(title: L10n.PairCoupons.title,
                                           image: UIImage(systemName: Constants.pairCouponsImage),
                                           selectedImage: nil)
        pairCouponsNavigationController.tabBarItem = pairCouponsItem
        
        let myCouponsNavigationController = UINavigationController()
        let myCouponsBarItem = UITabBarItem(title: L10n.MyCoupons.title,
                                            image: UIImage(systemName: Constants.myCouponsImage),
                                            selectedImage: nil)
        myCouponsNavigationController.tabBarItem = myCouponsBarItem
        
        let settingsNavigationController = UINavigationController()
        let settingsBarItem = UITabBarItem(title: L10n.Settings.tab,
                                           image: UIImage(systemName: Constants.settingsImage),
                                           selectedImage: nil)
        settingsNavigationController.tabBarItem = settingsBarItem
        
        rootTabBarController?.viewControllers = [pairCouponsNavigationController,
                                                 myCouponsNavigationController,
                                                 settingsNavigationController]
        
//        PairCouponsCoordinator(rootNavigationController: rootNavigationController,
//                               tabNavigationController: pairCouponsNavigationController).start()
        MyCouponsCoordinator(rootNavigationController: rootNavigationController,
                             tabNavigationController: myCouponsNavigationController).start()
        SettingsCoordinator(rootNavigationController: rootNavigationController,
                            tabNavigationController: settingsNavigationController).start()
        
        guard let rootTabBarController else { return }
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.init(name: Constants.textFont, size: 14) ?? UIFont.systemFont(ofSize: 14)], for: .normal)
        rootNavigationController?.setViewControllers([rootTabBarController], animated: true)
    }
}
