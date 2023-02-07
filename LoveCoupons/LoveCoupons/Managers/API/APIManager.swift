//
//  ApiManager.swift
//
//  Created by Dmitry Vorozhbicki on 25/10/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import Firebase
import Network

protocol APIManagerProtocol {
    var userUid: String? { get }
    var apiErrorPublisher: Published<String?>.Publisher { get }

    func login(email: String, password: String, completion: @escaping () -> Void)
    func logout(completion: @escaping () -> Void)
    func createUser(userInfo: UserInfo, email: String, password: String, completion: @escaping () -> Void)
    func resetPassword(email: String,completion: @escaping () -> Void)
    func setUserInfo(_ userInfo: UserInfo, completion: @escaping () -> Void)
    func getUserInfo(completion: @escaping (UserInfo?) -> Void)
    func getMyCoupons(completion: @escaping ([Coupon]?) -> Void)
    func getPairCoupons(completion: @escaping ([Coupon]?) -> Void)
    func updateCoupon(_ coupon: Coupon, data: Data?, completion: @escaping () -> Void)
    func deleteCoupon(_ coupon: Coupon, completion: @escaping () -> Void)
    func getPairEmail(completion: @escaping (String?) -> Void)
}

final class APIManager: APIManagerProtocol {
    
    private struct ApiErrorMessage {
        static let defaultMessage = L10n.apiDefaultError
        static let fields = L10n.errorFields
        static let couponsMessage = L10n.Alert.coupons
        static let disconnect = L10n.noInternetConnection
    }
    private let timeoutDelay: CGFloat = 10
    private let database = Database.database().reference()
    private let storage = Storage.storage()
    private let serialQueue: DispatchQueue
    private let session = URLSession(configuration: URLSessionConfiguration.default)

    private let auth: Auth
    
    private var timeoutDataTask: DispatchWorkItem?
    var apiErrorPublisher: Published<String?>.Publisher { $apiError }
    @Published var apiError: String?

    init() {
        serialQueue = DispatchQueue(label: "queue")
        auth = Auth.auth()
    }
    
    deinit {
        stopTimeoutHandler()
    }
    
    private func startTimeoutHandler() {
        stopTimeoutHandler()
        timeoutDataTask = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.apiError = ApiErrorMessage.disconnect
        }
        if let task = timeoutDataTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeoutDelay, execute: task)
        }
    }
    
    private func stopTimeoutHandler() {
        timeoutDataTask?.cancel()
        timeoutDataTask = nil
    }
    
    var userUid: String? {
        auth.currentUser?.uid
    }
    
    func getPairEmail(completion: @escaping (String?) -> Void) {
        serialQueue.async {
            self.getUserInfo { [weak self] userInfo in
                guard let self else { return }
                if let id = userInfo?.pairUniqId {
                    self.database.child(id).child(Constants.userInfoDirectory).observe(DataEventType.value, with: { snapshot in
                        if let postDict = snapshot.value as? [String: Any] {
                            DispatchQueue.main.async {
                                completion(UserInfo(data: postDict).email)
                            }
                        } else {
                            self.apiError = ApiErrorMessage.defaultMessage
                        }
                    }) { error in
                        self.apiError = error.localizedDescription
                    }
                } else {
                    self.apiError = ApiErrorMessage.defaultMessage
                }
            }
        }
    }
    
    func login(email: String, password: String, completion: @escaping () -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            self.apiError = ApiErrorMessage.fields
            return
        }
        self.startTimeoutHandler()
        serialQueue.async {
            self.auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
                self?.stopTimeoutHandler()
                DispatchQueue.main.async {
                    if let error {
                        self?.apiError = error.localizedDescription
                    } else {
                        completion()
                    }
                }
            }
        }
    }
    
    func logout(completion: @escaping () -> Void) {
        do {
            try auth.signOut()
            DispatchQueue.main.async {
                completion()
            }
        } catch {
            self.apiError = ApiErrorMessage.defaultMessage
        }
    }
    
    func createUser(userInfo: UserInfo, email: String, password: String, completion: @escaping () -> Void) {
        guard !email.isEmpty, !password.isEmpty, !(userInfo.name?.isEmpty ?? true),
              !(userInfo.pairUniqId?.isEmpty ?? true) else {
            self.apiError = ApiErrorMessage.fields
            return
        }
        serialQueue.async {
            self.auth.createUser(withEmail: email, password: password) { authResult, error in
                if let error {
                    self.apiError = error.localizedDescription
                } else {
                    self.setUserInfo(userInfo, completion: completion)
                }
            }
        }
    }
    
    func resetPassword(email: String,completion:@escaping () -> Void) {
        guard !email.isEmpty else {
            self.apiError = ApiErrorMessage.fields
            return
        }
        self.startTimeoutHandler()
        serialQueue.async {
            self.auth.sendPasswordReset(withEmail: email) { [weak self] error in
                self?.stopTimeoutHandler()
                if let error {
                    self?.apiError = error.localizedDescription
                } else {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }

    func setUserInfo(_ userInfo: UserInfo, completion:@escaping () -> Void) {
        guard !(userInfo.name?.isEmpty ?? true),
              !(userInfo.pairUniqId?.isEmpty ?? true) else {
            self.apiError = ApiErrorMessage.fields
            return
        }
        guard let uid = userUid else {
            self.apiError = ApiErrorMessage.defaultMessage
            return
        }
        self.startTimeoutHandler()
        serialQueue.async {
            self.database.child(uid).child(Constants.userInfoDirectory).setValue(userInfo.toAnyObject()) { [weak self] (error, ref) in
                self?.stopTimeoutHandler()
                if let error {
                    self?.apiError = error.localizedDescription
                } else {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
    
    func getUserInfo(completion: @escaping (UserInfo?) -> Void) {
        guard let uid = userUid else {
            self.apiError = ApiErrorMessage.defaultMessage
            return
        }
        self.startTimeoutHandler()
        serialQueue.async {
            self.database.child(uid).child(Constants.userInfoDirectory).observe(DataEventType.value, with: { [weak self] snapshot in
                self?.stopTimeoutHandler()
                if let postDict = snapshot.value as? [String: Any] {
                    DispatchQueue.main.async {
                        completion(UserInfo(data: postDict))
                    }
                } else {
                    self?.apiError = ApiErrorMessage.defaultMessage
                }
            }) { [weak self] error in
                self?.stopTimeoutHandler()
                self?.apiError = error.localizedDescription
            }
        }
    }
    
    func getMyCoupons(completion:@escaping ([Coupon]?) -> Void) {
        guard let uid = userUid else {
            self.apiError = ApiErrorMessage.defaultMessage
            return
        }
        self.startTimeoutHandler()
        serialQueue.async {
            self.database.child(uid).child(Constants.couponsDirectory).observe(DataEventType.value, with: { [weak self] snapshot in
                self?.stopTimeoutHandler()
                if let dict = snapshot.value as? [String : AnyObject] {
                    var coupons: [Coupon] = []
                    dict.forEach {
                        if let coupon = $0.value as? [String : Any] {
                            var newCoupon = Coupon(data: coupon)
                            newCoupon.key = $0.key
                            coupons.append(newCoupon)
                        }
                    }
                    DispatchQueue.main.async {
                        completion(coupons)
                    }
                } else {
                    self?.apiError = ApiErrorMessage.couponsMessage
                }
            }) { [weak self] error in
                self?.stopTimeoutHandler()
                self?.apiError = error.localizedDescription
            }
        }
    }
    
    func getPairCoupons(completion: @escaping ([Coupon]?) -> Void) {
        serialQueue.async {
            self.getUserInfo { [weak self] userInfo in
                if let id = userInfo?.pairUniqId {
                    self?.database.child(id).child(Constants.couponsDirectory).observe(DataEventType.value, with: { snapshot in
                        if let dict = snapshot.value as? [String : AnyObject] {
                            var coupons: [Coupon] = []
                            dict.forEach {
                                if let coupon = $0.value as? [String : Any] {
                                    var newCoupon = Coupon(data: coupon)
                                    newCoupon.key = $0.key
                                    coupons.append(Coupon(data: coupon))
                                }
                            }
                            DispatchQueue.main.async {
                                completion(coupons)
                            }
                        } else {
                            self?.apiError = ApiErrorMessage.couponsMessage
                        }
                    }) { [weak self] error in
                        self?.apiError = error.localizedDescription
                    }
                }
            }
        }
    }
    
    func updateCoupon(_ coupon: Coupon, data: Data?, completion: @escaping () -> Void) {
        guard !coupon.description.isEmpty else {
            self.apiError = ApiErrorMessage.fields
            return
        }
        var coupon = coupon

        guard let uid = userUid else {
            self.apiError = ApiErrorMessage.defaultMessage
            return
        }
        if data == nil, !coupon.description.isEmpty, !coupon.image.isEmpty {
            self.newDatabaseCoupon(coupon, completion: completion)
            return
        }
        guard !coupon.description.isEmpty, let data = data else {
            self.apiError = ApiErrorMessage.fields
            return
        }
        
        self.startTimeoutHandler()
        let riversRef = storage.reference().child("\(uid)/\(UUID()).jpg")
        serialQueue.async {
            riversRef.putData(data, metadata: nil) { (metadata, error) in
                riversRef.downloadURL { [weak self] (url, error) in
                    self?.stopTimeoutHandler()
                    if let downloadURL = url {
                        coupon.image = downloadURL.absoluteString
                        self?.newDatabaseCoupon(coupon, completion: completion)
                    } else {
                        self?.apiError = error?.localizedDescription ?? ApiErrorMessage.defaultMessage
                    }
                }
            }
        }
    }
    
    func deleteCoupon(_ coupon: Coupon, completion: @escaping () -> Void) {
        guard let uid = userUid,
              let key = coupon.key else {
            self.apiError = ApiErrorMessage.defaultMessage
            return
        }
        self.database.child(uid).child(Constants.couponsDirectory).child(key).removeValue()
    }

    private func newDatabaseCoupon(_ coupon: Coupon, completion: @escaping () -> Void) {
        guard let uid = userUid else {
            self.apiError = ApiErrorMessage.defaultMessage
            return
        }

        let ref = Database.database().reference().child(uid).child(Constants.couponsDirectory).child(coupon.key ?? UUID().uuidString)

        guard let values = coupon.toAnyObject() as? [AnyHashable : Any] else {
            self.apiError = ApiErrorMessage.defaultMessage
            return
        }
        self.startTimeoutHandler()
        ref.updateChildValues(values) { [weak self] (error, reference) in
            self?.stopTimeoutHandler()
            if let error {
                self?.apiError = error.localizedDescription
            } else {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
    }
}
