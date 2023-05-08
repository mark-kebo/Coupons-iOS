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
    var viewDataItemsPlaceholder: [Coupon] { get }
    
    func showSendEmailView(coupon: Coupon)
}

final class PairCouponsViewModel<Coordinator>: PairCouponsViewModelProtocol where Coordinator: PairCouponsCoordinatorProtocol {
    private let coordinator: Coordinator
    private let apiManager: APIManagerProtocol
    @Published var isShowLoading = false
    @Published var coupons: [Coupon] = []
    let viewDataItemsPlaceholder: [Coupon] = [Coupon.placeholder, Coupon.placeholder,
                                              Coupon.placeholder, Coupon.placeholder,
                                              Coupon.placeholder, Coupon.placeholder,
                                              Coupon.placeholder, Coupon.placeholder]
    @ObservedObject private var mailDataStore = PairCouponsMailDataStore()
    private var cancellables: Set<AnyCancellable> = []

    init(coordinator: Coordinator,
         apiManager: APIManagerProtocol = APIManager()
    ) {
        self.coordinator = coordinator
        self.apiManager = apiManager
        updateViewData()
    }

    deinit {
        cancellables.removeAll()
    }
    
    func showSendEmailView(coupon: Coupon) {
        if MFMailComposeViewController.canSendMail() {
            self.isShowLoading = true
            self.apiManager.getUserInfo()
                .sink { [weak self] completion in
                    switch completion {
                    case .finished: break
                    case .failure(let error):
                        self?.isShowLoading = false
                        self?.coordinator.showError(error.type.text)
                    }
                } receiveValue: { [weak self] userInfo in
                    guard let self else { return }
                    self.apiManager.getPairEmail(pairId: userInfo?.pairUniqId ?? "")
                        .sink { [weak self] completion in
                            switch completion {
                            case .finished: break
                            case .failure(let error):
                                self?.isShowLoading = false
                                self?.coordinator.showError(error.type.text)
                            }
                        } receiveValue: { [weak self] email in
                            guard let self else { return }
                            self.isShowLoading = false
                            if let email {
                                self.mailDataStore.emailMessage = email
                            }
                            self.mailDataStore.bodyMessage = coupon.description
                            self.coordinator.showSendMailPicker(result: self.$mailDataStore.result,
                                                                emailMessage: self.$mailDataStore.emailMessage,
                                                                bodyMessage: self.$mailDataStore.bodyMessage)
                        }
                        .store(in: &self.cancellables)
                }
                .store(in: &cancellables)
        } else {
            coordinator.showError(L10n.Alert.mail)
        }
    }
    
    private func updateViewData() {
        isShowLoading = true
        self.apiManager.getUserInfo()
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.isShowLoading = false
                    self?.coordinator.showError(error.type.text)
                }
            } receiveValue: { [weak self] userInfo in
                guard let self else { return }
                self.apiManager.getPairCoupons(pairUniqId: userInfo?.pairUniqId ?? "")
                    .sink { [weak self] completion in
                        switch completion {
                        case .finished: break
                        case .failure(let error):
                            self?.isShowLoading = false
                            self?.coordinator.showError(error.type.text)
                        }
                    } receiveValue: { [weak self] coupons in
                        self?.isShowLoading = false
                        self?.coupons = coupons?.sorted { $0.description < $1.description } ?? []
                    }
                    .store(in: &self.cancellables)
            }
            .store(in: &cancellables)
    }
}
