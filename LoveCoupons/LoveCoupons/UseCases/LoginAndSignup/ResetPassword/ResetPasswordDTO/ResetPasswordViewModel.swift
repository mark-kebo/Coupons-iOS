//
//  ResetPasswordViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation
import Combine

protocol ResetPasswordViewModelProtocol: ObservableObject {
    var isShowLoading: Bool { get set }
    func sendButtonPressed(email: String)
}

final class ResetPasswordViewModel<Coordinator>: ResetPasswordViewModelProtocol where Coordinator: ResetPasswordCoordinatorProtocol {
    private let coordinator: Coordinator
    private let apiManager: APIManagerProtocol
    private var cancellables: Set<AnyCancellable> = []
    @Published var isShowLoading = false

    init(coordinator: Coordinator,
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
    
    func sendButtonPressed(email: String) {
        isShowLoading = true
        self.apiManager.resetPassword(email: email) { [weak self] in
            self?.isShowLoading = false
            self?.coordinator.showSuccessMessage()
        }
    }
}
