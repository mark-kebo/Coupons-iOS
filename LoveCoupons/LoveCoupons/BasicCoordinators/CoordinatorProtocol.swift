//
//  CoordinatorProtocol.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit

protocol CoordinatorProtocol {
    var rootNavigationController: UINavigationController? { get }
    func start()
}

extension CoordinatorProtocol {
    var topViewController: UIViewController? {
        let keyWindow = UIApplication.keyWindow
        guard let rootController = keyWindow?.rootViewController else { return nil }
        if let topPresentedViewController = rootController.presentedViewController {
            return topPresentedViewController
        }
        return rootController
    }
}
