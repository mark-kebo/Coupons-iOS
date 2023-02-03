//
//  SignUpViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation

protocol SignUpViewModelProtocol {
    func createUserButtonPressed(name: String, email: String,
                                 pairUniqId: String, password: String)
}

final class SignUpViewModel: SignUpViewModelProtocol {
    private let coordinator: SignUpCoordinatorProtocol
    private let apiManager: APIManagerProtocol

    init(coordinator: SignUpCoordinatorProtocol,
         apiManager: APIManagerProtocol = APIManager()
    ) {
        self.coordinator = coordinator
        self.apiManager = apiManager
    }
    
    func createUserButtonPressed(name: String, email: String,
                                 pairUniqId: String, password: String) {
        let userInfoItem = UserInfo(name: name, email: email, pairUniqId: pairUniqId)
        self.apiManager.createUser(userInfo: userInfoItem, email: email, password: password) { [weak self] error in
            if let error = error?.localizedDescription {
                self?.coordinator.showError(error)
            } else {
                self?.coordinator.navigateToTabs()
            }
        }
    }
}
