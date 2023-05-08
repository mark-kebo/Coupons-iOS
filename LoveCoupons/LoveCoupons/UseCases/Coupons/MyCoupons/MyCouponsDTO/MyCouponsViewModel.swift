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
    var viewDataItemsPlaceholder: [Coupon] { get }

    func deleteItems(at offsets: IndexSet)
    func couponSelected(_ coupon: Coupon, id: Int)
    func addCouponButtonSelected()
}

final class MyCouponsViewModel<Coordinator>: MyCouponsViewModelProtocol where Coordinator: MyCouponsCoordinatorProtocol {
    private let coordinator: Coordinator
    private let apiManager: APIManagerProtocol
    @Published var isShowLoading = false
    @Published var coupons: [Coupon] = []
    let viewDataItemsPlaceholder: [Coupon] = [Coupon.placeholder, Coupon.placeholder,
                                              Coupon.placeholder, Coupon.placeholder,
                                              Coupon.placeholder, Coupon.placeholder,
                                              Coupon.placeholder, Coupon.placeholder]
    private var cancellables: Set<AnyCancellable> = []
    
    var userUid: String {
        apiManager.userUid ?? ""
    }
    
    init(coordinator: Coordinator,
         apiManager: APIManagerProtocol = APIManager()
    ) {
        self.coordinator = coordinator
        self.apiManager = apiManager
        getCoupons()
    }

    deinit {
        cancellables.removeAll()
    }
    
    func deleteItems(at offsets: IndexSet) {
        guard let first = offsets.first else { return }
        apiManager.deleteCoupon(coupons[first])
    }
    
    private func getCoupons() {
        isShowLoading = true
        apiManager.getMyCoupons()
            .print("debugging")
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.isShowLoading = false
                    self?.coordinator.showError(error.type.text)
                }
            } receiveValue: { [weak self] myCoupons in
                guard let self else { return }
                self.isShowLoading = false
                self.coupons = myCoupons?.sorted { $0.description < $1.description } ?? []
            }
            .store(in: &cancellables)
    }
    
    func couponSelected(_ coupon: Coupon, id: Int) {
        coordinator.navigateToDetails(coupon, id: id, state: .edit)
    }
    
    func addCouponButtonSelected() {
        coordinator.navigateToDetails(Coupon(), id: 0, state: .add)
    }
}
