//
//  MyCouponsViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

protocol MyCouponsViewModelProtocol: ObservableObject {
    var isShowLoading: Bool { get set }
    var coupons: [Coupon] { get set }
    
    func deleteItems(at offsets: IndexSet)
    func getCoupons()
    func couponSelected(_ coupon: Coupon, id: Int)
    func addCouponButtonSelected()
}

final class MyCouponsViewModel: MyCouponsViewModelProtocol {
    private let coordinator: MyCouponsCoordinatorProtocol
    private let apiManager: APIManagerProtocol
    @Published var isShowLoading = false
    @Published var coupons: [Coupon] = []
    
    var userUid: String {
        apiManager.userUid ?? ""
    }
    
    init(coordinator: MyCouponsCoordinatorProtocol,
         apiManager: APIManagerProtocol = APIManager()
    ) {
        self.coordinator = coordinator
        self.apiManager = apiManager
    }
    
    func deleteItems(at offsets: IndexSet) {
        guard let first = offsets.first else { return }
        isShowLoading = true
        apiManager.deleteCoupon(coupons[first]) { [weak self] error in
            self?.isShowLoading = false
            if let error = error?.localizedDescription {
                self?.coordinator.showError(error)
            }
        }
    }
    
    func getCoupons() {
        isShowLoading = true
        coupons.removeAll()
        apiManager.getMyCoupons { [weak self] coupons, error in
            self?.isShowLoading = false
            if let error = error?.localizedDescription {
                self?.coordinator.showError(error)
            } else if let coupons = coupons {
                self?.coupons = coupons.sorted { $0.description < $1.description }
            }
        }
    }
    
    func couponSelected(_ coupon: Coupon, id: Int) {
        coordinator.navigateToDetails(coupon, id: id, state: .edit)
    }
    
    func addCouponButtonSelected() {
        coordinator.navigateToDetails(Coupon(), id: 0, state: .add)
    }
}
