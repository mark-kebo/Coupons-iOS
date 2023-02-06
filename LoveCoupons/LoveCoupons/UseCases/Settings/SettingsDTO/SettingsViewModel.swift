//
//  SettingsViewModel.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

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

final class SettingsViewModel: SettingsViewModelProtocol {
    private let coordinator: SettingsCoordinatorProtocol
    private let apiManager: APIManagerProtocol
    @Published var isShowLoading = false
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var id: String = ""
    
    var userUid: String {
        apiManager.userUid ?? ""
    }
    
    init(coordinator: SettingsCoordinatorProtocol,
         apiManager: APIManagerProtocol = APIManager()
    ) {
        self.coordinator = coordinator
        self.apiManager = apiManager
    }
    
    func getUserInfo() {
        isShowLoading = true
        apiManager.getUserInfo { [weak self] userInfo, error in
            self?.isShowLoading = false
            if let error = error?.localizedDescription {
                self?.coordinator.showError(error)
            } else {
                self?.name = userInfo?.name ?? ""
                self?.id = userInfo?.pairUniqId ?? ""
                self?.email = userInfo?.email ?? ""
            }
        }
    }
    
    func sendButtonPressed(email: String) {
        isShowLoading = true
        self.apiManager.resetPassword(email: email) { [weak self] error in
            self?.isShowLoading = false
            if let error = error?.localizedDescription {
                self?.coordinator.showError(error)
            }
        }
    }
    
    func logoutButtonPressed() {
        isShowLoading = true
        self.apiManager.logout { [weak self] error in
            self?.isShowLoading = false
            if let error {
                self?.coordinator.showError(error)
            } else {
                self?.coordinator.navigateToLogin()
            }
        }
    }
    
    func submitButtonPressed() {
        isShowLoading = true
        let userInfoItem = UserInfo(name: self.name, email: self.email, pairUniqId: self.id)
        self.apiManager.setUserInfo(userInfoItem) { [weak self] error in
            self?.isShowLoading = false
            if let error = error?.localizedDescription {
                self?.coordinator.showError(error)
            }
        }
    }
}
