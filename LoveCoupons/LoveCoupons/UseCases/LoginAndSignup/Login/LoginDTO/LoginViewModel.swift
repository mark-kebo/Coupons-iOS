//
//  LoginViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation
import Combine

protocol LoginViewModelProtocol: ObservableObject {
    var isShowLoading: Bool { get set }
    func loginButtonPressed(userLogin: String,
                            userPass: String)
    func signUpButtonPressed()
    func restPasswordButtonPressed()
}

final class LoginViewModel<Coordinator>: LoginViewModelProtocol where Coordinator: LoginCoordinatorProtocol {
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
    
    func loginButtonPressed(userLogin: String,
                            userPass: String) {
        isShowLoading = true
        self.apiManager.login(email: userLogin, password: userPass)
            .sink { [weak self] completion in
                self?.isShowLoading = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.coordinator.showError(error.type.text)
                }
            } receiveValue: { [weak self] isLoggedIn in
                self?.isShowLoading = false
                self?.coordinator.navigateToTabs()
            }
            .store(in: &cancellables)
    }
    
    func signUpButtonPressed() {
        coordinator.navigateToSignUp()
    }
    
    func restPasswordButtonPressed() {
        coordinator.navigateToRestPassword()
    }
}
