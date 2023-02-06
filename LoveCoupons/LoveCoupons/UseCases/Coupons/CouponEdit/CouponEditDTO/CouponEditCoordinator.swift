//
//  CouponEditCoordinator.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import SwiftUI

protocol CouponEditCoordinatorProtocol: ErrorableCoordinatorProtocol, TabCoordinatorProtocol {
    var coupon: Coupon { get }
    var id: Int { get }
    var state: CouponEditState { get }
    
    func navigateBack()
    func showCaptureImageView(image: Binding<UIImage?>)
}

final class CouponEditCoordinator: NSObject, CouponEditCoordinatorProtocol {
    let coupon: Coupon
    let id: Int
    let state: CouponEditState
    
    weak var rootNavigationController: UINavigationController?
    weak var tabNavigationController: UINavigationController?

    deinit {
        NSLog("\(self) deinited")
    }
    
    init(rootNavigationController: UINavigationController?,
         tabNavigationController: UINavigationController?,
         coupon: Coupon,
         id: Int,
         state: CouponEditState) {
        self.rootNavigationController = rootNavigationController
        self.tabNavigationController = tabNavigationController
        self.coupon = coupon
        self.id = id
        self.state = state
    }
    
    func start() {
        let viewModel = CouponEditViewModel(coordinator: self)
        let childView = CouponEditView(viewModel: viewModel)
        tabNavigationController?.pushViewController(UIHostingController(rootView: childView), animated: true)
    }
    
    func navigateBack() {
        tabNavigationController?.popViewController(animated: true)
    }

    func showCaptureImageView(image: Binding<UIImage?>) {
        let imagePicker = ImagePicker(selectedImage: image)
        tabNavigationController?.present(UIHostingController(rootView: imagePicker), animated: true)
    }
}
