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

final class LoginViewModel: LoginViewModelProtocol {
    private let coordinator: LoginCoordinatorProtocol
    private let apiManager: APIManagerProtocol
    private var cancellables: Set<AnyCancellable> = []
    @Published var isShowLoading = false

    init(coordinator: LoginCoordinatorProtocol,
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
    
    func loginButtonPressed(userLogin: String,
                            userPass: String) {
        isShowLoading = true
        self.apiManager.login(email: userLogin, password: userPass) { [weak self] in
            self?.isShowLoading = false
            self?.coordinator.navigateToTabs()
        }
    }
    
    func signUpButtonPressed() {
        coordinator.navigateToSignUp()
    }
    
    func restPasswordButtonPressed() {
        coordinator.navigateToRestPassword()
    }
}
