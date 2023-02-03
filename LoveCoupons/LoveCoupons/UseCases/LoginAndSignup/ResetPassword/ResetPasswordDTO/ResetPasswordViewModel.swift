//
//  ResetPasswordViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation

protocol ResetPasswordViewModelProtocol {
    func sendButtonPressed(email: String)
}

final class ResetPasswordViewModel: ResetPasswordViewModelProtocol {
    private let coordinator: ResetPasswordCoordinatorProtocol
    private let apiManager: APIManagerProtocol

    init(coordinator: ResetPasswordCoordinatorProtocol,
         apiManager: APIManagerProtocol = APIManager()
    ) {
        self.coordinator = coordinator
        self.apiManager = apiManager
    }
    
    func sendButtonPressed(email: String) {
        self.apiManager.resetPassword(email: email) { [weak self] error in
            if let error = error?.localizedDescription {
                self?.coordinator.showError(error)
            } else {
                self?.coordinator.showSuccessMessage()
            }
        }
    }
}
