//
//  TabBarCoordinatorProtocols.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit

protocol RootTabBarCoordinatorProtocol: CoordinatorProtocol {
    var rootTabBarController: UITabBarController? { get }
}

protocol TabCoordinatorProtocol: CoordinatorProtocol {
    var tabNavigationController: UINavigationController? { get }
}
