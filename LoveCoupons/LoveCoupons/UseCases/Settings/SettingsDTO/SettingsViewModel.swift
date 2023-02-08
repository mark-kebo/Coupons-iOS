//
//  SettingsViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import Combine

protocol SettingsViewModelProtocol: ObservableObject {
    var isShowLoading: Bool { get set }
    var name: String { get set }
    var email: String { get set }
    var id: String { get set }
    var userUid: String { get }
    
    func sendButtonPressed(email: String)
    func getUserInfo()
    func logoutButtonPressed()
    func submitButtonPressed()
}

final class SettingsViewModel<Coordinator>: SettingsViewModelProtocol where Coordinator: SettingsCoordinatorProtocol {
    private let coordinator: Coordinator
    private let apiManager: APIManagerProtocol
    @Published var isShowLoading = false
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var id: String = ""
    private var cancellables: Set<AnyCancellable> = []

    var userUid: String {
        apiManager.userUid ?? ""
    }
    
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
    
    func getUserInfo() {
        isShowLoading = true
        apiManager.getUserInfo { [weak self] userInfo in
            self?.isShowLoading = false
            self?.name = userInfo?.name ?? ""
            self?.id = userInfo?.pairUniqId ?? ""
            self?.email = userInfo?.email ?? ""
        }
    }
    
    func sendButtonPressed(email: String) {
        isShowLoading = true
        self.apiManager.resetPassword(email: email) { [weak self] in
            self?.isShowLoading = false
        }
    }
    
    func logoutButtonPressed() {
        isShowLoading = true
        self.apiManager.logout { [weak self] in
            self?.isShowLoading = false
            self?.coordinator.navigateToLogin()
        }
    }
    
    func submitButtonPressed() {
        isShowLoading = true
        let userInfoItem = UserInfo(name: self.name, email: self.email, pairUniqId: self.id)
        self.apiManager.setUserInfo(userInfoItem) { [weak self] in
            self?.isShowLoading = false
        }
    }
}
