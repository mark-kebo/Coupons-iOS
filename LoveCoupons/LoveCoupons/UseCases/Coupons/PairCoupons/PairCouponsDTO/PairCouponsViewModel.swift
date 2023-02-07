//
//  PairCouponsViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import MessageUI
import Combine

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
    private var cancellables: Set<AnyCancellable> = []

    init(coordinator: PairCouponsCoordinatorProtocol,
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
    
    func showSendEmailView(coupon: Coupon) {
        if MFMailComposeViewController.canSendMail() {
            self.isShowLoading = true
            self.apiManager.getPairEmail { [weak self] email in
                guard let self else { return }
                self.isShowLoading = false
                if let email = email {
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
        apiManager.getPairCoupons { [weak self] coupons in
             if let coupons = coupons {
                self?.coupons = coupons.sorted { $0.description < $1.description }
            }
            self?.isShowLoading = false
        }
    }
}
