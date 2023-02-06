//
//  PairCouponsViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import MessageUI

protocol PairCouponsViewModelProtocol: ObservableObject {
    var isShowLoading: Bool { get set }
    var coupons: [Coupon] { get set }
    
    func showSendEmailView(coupon: Coupon)
    func updateViewData()
}

final class PairCouponsViewModel: PairCouponsViewModelProtocol {
    private let coordinator: PairCouponsCoordinatorProtocol
    private let apiManager: APIManagerProtocol
    @Published var isShowLoading = false
    @Published var coupons: [Coupon] = []
    @ObservedObject private var mailDataStore = PairCouponsMailDataStore()
    
    init(coordinator: PairCouponsCoordinatorProtocol,
         apiManager: APIManagerProtocol = APIManager()
    ) {
        self.coordinator = coordinator
        self.apiManager = apiManager
    }
    
    func showSendEmailView(coupon: Coupon) {
        if MFMailComposeViewController.canSendMail() {
            self.isShowLoading = true
            self.apiManager.getPairEmail { [weak self] (email, error) in
                guard let self else { return }
                self.isShowLoading = false
                if let error = error?.localizedDescription {
                    self.coordinator.showError(error)
                } else if let email = email {
                    self.mailDataStore.emailMessage = email
                }
                self.mailDataStore.bodyMessage = coupon.description
                self.coordinator.showSendMailPicker(result: self.$mailDataStore.result,
                                                    emailMessage: self.$mailDataStore.emailMessage,
                                                    bodyMessage: self.$mailDataStore.bodyMessage)
            }
        } else {
            coordinator.showError(L10n.Alert.mail)
        }
    }
    
    func updateViewData() {
        coupons.removeAll()
        isShowLoading = true
        apiManager.getPairCoupons { [weak self] coupons, error in
            if let error = error?.localizedDescription {
                self?.coordinator.showError(error)
            } else if let coupons = coupons {
                self?.coupons = coupons.sorted { $0.description < $1.description }
            }
            self?.isShowLoading = false
        }
    }
}
