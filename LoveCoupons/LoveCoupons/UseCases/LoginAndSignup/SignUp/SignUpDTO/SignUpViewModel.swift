//
//  SignUpViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation
import Combine

protocol SignUpViewModelProtocol: ObservableObject {
    var isShowLoading: Bool { get set }
    func createUserButtonPressed(name: String, email: String,
                                 pairUniqId: String, password: String)
}


final class SignUpViewModel<Coordinator>: SignUpViewModelProtocol where Coordinator: SignUpCoordinatorProtocol {
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
    
    func createUserButtonPressed(name: String, email: String,
                                 pairUniqId: String, password: String) {
        let userInfoItem = UserInfo(name: name, email: email, pairUniqId: pairUniqId)
        isShowLoading = true
        self.apiManager.createUser(userInfo: userInfoItem, email: email, password: password)
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
                self.coordinator.navigateToTabs()
            }
            .store(in: &self.cancellables)
    }
}
