//
//  LoginViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation

protocol LoginViewModelProtocol {
    func loginButtonPressed(userLogin: String,
                            userPass: String)
    func signUpButtonPressed()
    func restPasswordButtonPressed()
}

final class LoginViewModel: LoginViewModelProtocol {
    private let coordinator: LoginCoordinatorProtocol
    private let apiManager: APIManagerProtocol

    init(coordinator: LoginCoordinatorProtocol,
         apiManager: APIManagerProtocol = APIManager()
    ) {
        self.coordinator = coordinator
        self.apiManager = apiManager
    }
    
    func loginButtonPressed(userLogin: String,
                            userPass: String) {
        self.apiManager.login(email: userLogin, password: userPass) { [weak self] error in
            if let error = error?.localizedDescription {
                self?.coordinator.showError(error)
            } else {
                self?.coordinator.navigateToTabs()
            }
        }
    }
    
    func signUpButtonPressed() {
        coordinator.navigateToSignUp()
    }
    
    func restPasswordButtonPressed() {
        coordinator.navigateToRestPassword()
    }
}
