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

final class CouponEditViewModel: CouponEditViewModelProtocol {
    private let coordinator: CouponEditCoordinatorProtocol
    private let apiManager: APIManagerProtocol
    @Published var isShowLoading = false
    @Published var coupon: Coupon
    @Published var text: String = ""
    private var cancellables: Set<AnyCancellable> = []

    let id: Int
    let state: CouponEditState

    init(coordinator: CouponEditCoordinatorProtocol,
         apiManager: APIManagerProtocol = APIManager()
    ) {
        _coupon = Published(initialValue: coordinator.coupon)
        _text = Published(initialValue: coordinator.coupon.description)
        self.id = coordinator.id
        self.state = coordinator.state
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
    
    func sendButtonPressed(image: UIImage?) {
        isShowLoading = true
        coupon.description = self.text
        apiManager.updateCoupon(coupon, data: image != UIImage(asset: Asset.addImage) ? image?.jpegData(compressionQuality: 0.5) : nil) { [weak self] in
                self?.isShowLoading = false
                self?.coordinator.navigateBack()
            }
    }
    
    func updateImage(imageStore: CouponEditImageStore)  {
        isShowLoading = true
        MediaLoadingService.shared.getMediaData(coupon.image) { [weak self] result in
            self?.isShowLoading = false
            switch result {
            case .success(let image):
                imageStore.image = image
            case .failure(_):
                imageStore.image = UIImage(asset: Asset.addImage)
            }
        }
    }
    
    func changeImageButtonSelected(image: Binding<UIImage?>) {
        coordinator.showCaptureImageView(image: image)
    }
}
