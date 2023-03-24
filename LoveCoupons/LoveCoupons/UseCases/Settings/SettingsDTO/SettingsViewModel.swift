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
    }

    deinit {
        cancellables.removeAll()
    }
    
    func getUserInfo() {
        isShowLoading = true
        
        apiManager.getUserInfo()
            .sink { [weak self] completion in
                self?.isShowLoading = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.coordinator.showError(error.type.text)
                }
            } receiveValue: { [weak self] userInfo in
                self?.isShowLoading = false
                self?.name = userInfo?.name ?? ""
                self?.id = userInfo?.pairUniqId ?? ""
                self?.email = userInfo?.email ?? ""
            }
            .store(in: &self.cancellables)
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
            }
            .store(in: &self.cancellables)
    }
    
    func logoutButtonPressed() {
        isShowLoading = true
        self.apiManager.logout()
            .sink { [weak self] completion in
                self?.isShowLoading = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.coordinator.showError(error.type.text)
                }
            } receiveValue: { [weak self] _ in
                self?.isShowLoading = false
                self?.coordinator.navigateToLogin()
            }
            .store(in: &self.cancellables)
    }
    
    func submitButtonPressed() {
        isShowLoading = true
        let userInfoItem = UserInfo(name: self.name, email: self.email, pairUniqId: self.id)
        self.apiManager.setUserInfo(userInfoItem)
            .sink { [weak self] completion in
                self?.isShowLoading = false
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.coordinator.showError(error.type.text)
                }
            } receiveValue: { [weak self] _ in
                self?.isShowLoading = false
            }
            .store(in: &self.cancellables)
    }
}
