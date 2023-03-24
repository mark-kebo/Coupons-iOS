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
    }

    deinit {
        cancellables.removeAll()
    }
    
    func sendButtonPressed(email: String) {
        isShowLoading = true
        self.apiManager.resetPassword(email: email)
            .sink { [weak self] completion in
                self?.isShowLoading = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.coordinator.showError(error.type.text)
                }
            } receiveValue: { [weak self] _ in
                self?.isShowLoading = false
                self?.coordinator.showSuccessMessage()
            }
            .store(in: &cancellables)
    }
}
