//
//  MyCouponsCoordinator.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import SwiftUI

protocol MyCouponsCoordinatorProtocol: ErrorableCoordinatorProtocol, TabCoordinatorProtocol {
    func navigateToDetails(_ coupon: Coupon, id: Int, state: CouponEditState)
}

final class MyCouponsCoordinator: MyCouponsCoordinatorProtocol {
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
        let viewModel = MyCouponsViewModel(coordinator: self)
        let childView = MyCouponsView(viewModel: viewModel)
        tabNavigationController?.pushViewController(UIHostingController(rootView: childView), animated: true)
    }
    
    func navigateToDetails(_ coupon: Coupon, id: Int, state: CouponEditState) {
        NSLog("Navigate to details")
        CouponEditCoordinator(rootNavigationController: rootNavigationController,
                              tabNavigationController: tabNavigationController,
                              coupon: coupon, id: id, state: state).start()
    }
}
