//
//  CouponEditViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import Combine

enum CouponEditState {
    case edit
    case add
}

protocol CouponEditViewModelProtocol: ObservableObject {
    var isShowLoading: Bool { get set }
    var coupon: Coupon { get }
    var text: String { get set }

    var id: Int { get }
    var state: CouponEditState { get }
    
    func sendButtonPressed(image: UIImage?) 
    func updateImage(imageStore: CouponEditImageStore)
    func changeImageButtonSelected(image: Binding<UIImage?>)
}

final class CouponEditViewModel<Coordinator>: CouponEditViewModelProtocol where Coordinator: CouponEditCoordinatorProtocol {
    private let coordinator: Coordinator
    private let apiManager: APIManagerProtocol
    @Published var isShowLoading = false
    @Published var coupon: Coupon
    @Published var text: String = ""
    private var cancellables: Set<AnyCancellable> = []

    let id: Int
    let state: CouponEditState

    init(coordinator: Coordinator,
         apiManager: APIManagerProtocol = APIManager()
    ) {
        _coupon = Published(initialValue: coordinator.coupon)
        _text = Published(initialValue: coordinator.coupon.description)
        self.id = coordinator.id
        self.state = coordinator.state
        self.coordinator = coordinator
        self.apiManager = apiManager
    }
    
    deinit {
        cancellables.removeAll()
    }
    
    func sendButtonPressed(image: UIImage?) {
        isShowLoading = true
        coupon.description = self.text
        apiManager.updateCoupon(coupon, data: image != UIImage(asset: Asset.addImage) ? image?.jpegData(compressionQuality: 0.5) : nil)
            .timeout(.seconds(self.apiManager.timeoutDelay),
                     scheduler: DispatchQueue.main, options: nil,
                     customError: { return ApiError(type: .disconnect) })
            .sink { [weak self] completion in
                self?.isShowLoading = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.coordinator.showError(error.type.text)
                }
            } receiveValue: { [weak self] _ in
                guard let self else { return }
                self.isShowLoading = false
                self.coordinator.navigateBack()
            }
            .store(in: &self.cancellables)
    }
    
    func updateImage(imageStore: CouponEditImageStore)  {
        isShowLoading = true
        MediaLoadingService.shared.getMediaData(coupon.image)
            .sink(receiveValue: { [weak self] image in
                self?.isShowLoading = false
                imageStore.image = image ?? UIImage(asset: Asset.addImage)
            })
            .store(in: &self.cancellables)
    }
    
    func changeImageButtonSelected(image: Binding<UIImage?>) {
        coordinator.showCaptureImageView(image: image)
    }
}
