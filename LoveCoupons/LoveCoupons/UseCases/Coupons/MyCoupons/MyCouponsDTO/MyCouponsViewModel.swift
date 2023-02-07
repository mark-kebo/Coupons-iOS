//
//  MyCouponsViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import Combine

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
    private var cancellables: Set<AnyCancellable> = []

    var userUid: String {
        apiManager.userUid ?? ""
    }
    
    init(coordinator: MyCouponsCoordinatorProtocol,
         apiManager: APIManagerProtocol = APIManager()
    ) {
        self.coordinator = coordinator
        self.apiManager = apiManager
        prepareErrorPublisher()
    }
    
    private func prepareErrorPublisher() {
        apiManager.apiErrorPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                guard let error = error?.description else { return }
                self?.isShowLoading = false
                self?.coordinator.showError(error)
            }.store(in: &cancellables)
    }

    deinit {
        cancellables.removeAll()
    }
    
    func deleteItems(at offsets: IndexSet) {
        guard let first = offsets.first else { return }
        isShowLoading = true
        apiManager.deleteCoupon(coupons[first]) { [weak self] in
            self?.isShowLoading = false
        }
    }
    
    func getCoupons() {
        isShowLoading = true
        coupons.removeAll()
        apiManager.getMyCoupons { [weak self] coupons in
            self?.isShowLoading = false
            if let coupons = coupons {
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
