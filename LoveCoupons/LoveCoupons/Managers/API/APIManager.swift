//
//  ApiManager.swift
//
//  Created by Dmitry Vorozhbicki on 25/10/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import Firebase
import Network
import Combine

protocol APIManagerProtocol {
    var userUid: String? { get }
    
    func login(email: String, password: String) -> AnyPublisher<Bool, Error>
    func logout() -> AnyPublisher<Bool, Error>
    func createUser(userInfo: UserInfo, email: String, password: String) -> AnyPublisher<Bool, Error>
    func resetPassword(email: String) -> AnyPublisher<Bool, Error>
    func setUserInfo(_ userInfo: UserInfo) -> AnyPublisher<Bool, Error>
    func getUserInfo() -> AnyPublisher<UserInfo?, Error>
    func getMyCoupons() -> AnyPublisher<[Coupon]?, Error>
    func getPairCoupons(pairUniqId: String?) -> AnyPublisher<[Coupon]?, Error>
    func updateCoupon(_ coupon: Coupon, data: Data?) -> AnyPublisher<Bool, Error>
    func deleteCoupon(_ coupon: Coupon) -> AnyPublisher<Bool, Error>
}

final class APIManager: APIManagerProtocol {
    
    private let timeoutDelay: CGFloat = 10
    private let database = Database.database().reference()
    private let storage = Storage.storage()
    private let serialQueue: DispatchQueue
    private let session = URLSession(configuration: URLSessionConfiguration.default)

    private let auth: Auth
    
    private var timeoutDataTask: DispatchWorkItem?
    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        serialQueue = DispatchQueue(label: "queue")
        auth = Auth.auth()
    }
    
    deinit {
        stopTimeoutHandler()
    }

    private func stopTimeoutHandler() {
        timeoutDataTask?.cancel()
        timeoutDataTask = nil
    }

    private var timeoutHandler: AnyPublisher<ApiError, Never> {
        stopTimeoutHandler()
        return Future { [weak self] promise in
            self?.timeoutDataTask = DispatchWorkItem {
                promise(.success(ApiError(type: .disconnect)))
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
        if let task = timeoutDataTask {
            DispatchQueue.main.asyncAfter(deadline: .now() + timeoutDelay, execute: task)
        }
    }
    //            self?.timeoutHandler.sink(receiveCompletion: { error in
    //                if let error = error as? Error {
    //                    promise(.failure(error))
    //                }
    //            }, receiveValue: { apiError in
    //                promise(.failure(apiError))
    //            }).store(in: self?.&cancellableSet)

    
    var userUid: String? {
        auth.currentUser?.uid
    }
    
    func login(email: String, password: String) -> AnyPublisher<Bool, Error> {
        guard !email.isEmpty, !password.isEmpty else {
            return Fail(error: ApiError(type: .fields))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        return Future { [weak self] promise in
            self?.serialQueue.async {
                self?.auth.signIn(withEmail: email, password: password) { authResult, error in
                    if let error {
                        promise(.failure(error))
                    } else {
                        promise(.success(true))
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func logout() -> AnyPublisher<Bool, Error> {
        return Future { [weak self] promise in
            do {
                try self?.auth.signOut()
                promise(.success(true))
            } catch {
                promise(.failure(ApiError(type: .defaultMessage)))
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func createUser(userInfo: UserInfo, email: String, password: String) -> AnyPublisher<Bool, Error> {
        guard !email.isEmpty, !password.isEmpty, !(userInfo.name?.isEmpty ?? true),
              !(userInfo.pairUniqId?.isEmpty ?? true) else {
            return Fail(error: ApiError(type: .fields))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        return Future { [weak self] promise in
            self?.serialQueue.async {
                self?.auth.createUser(withEmail: email, password: password) { authResult, error in
                    if let error {
                        promise(.failure(error))
                    } else {
                        //setUserInfo
                        promise(.success(true))
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func setUserInfo(_ userInfo: UserInfo) -> AnyPublisher<Bool, Error> {
        guard !(userInfo.name?.isEmpty ?? true),
              !(userInfo.pairUniqId?.isEmpty ?? true) else {
            return Fail(error: ApiError(type: .fields))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        guard let uid = userUid else {
            return Fail(error: ApiError(type: .defaultMessage))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        return Future { [weak self] promise in
            self?.serialQueue.async {
                self?.database.child(uid).child(Constants.userInfoDirectory).setValue(userInfo.toAnyObject()) { (error, ref) in
                    if let error {
                        promise(.failure(error))
                    } else {
                        promise(.success(true))
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func resetPassword(email: String) -> AnyPublisher<Bool, Error> {
        guard !email.isEmpty else {
            return Fail(error: ApiError(type: .fields))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        return Future { [weak self] promise in
            self?.serialQueue.async {
                self?.auth.sendPasswordReset(withEmail: email) { error in
                    if let error {
                        promise(.failure(error))
                    } else {
                        promise(.success(true))
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    /// get user info
    /// - Returns: UserInfo contain PairEmail
    func getUserInfo() -> AnyPublisher<UserInfo?, Error> {
        guard let uid = userUid else {
            return Fail(error: ApiError(type: .defaultMessage))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        return Future { [weak self] promise in
            self?.serialQueue.async {
                self?.database.child(uid).child(Constants.userInfoDirectory).observe(DataEventType.value, with: { snapshot in
                    if let postDict = snapshot.value as? [String: Any] {
                        promise(.success(UserInfo(data: postDict)))
                    } else {
                        promise(.failure(ApiError(type: .defaultMessage)))
                    }
                }) { error in
                    promise(.failure(error))
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func getMyCoupons() -> AnyPublisher<[Coupon]?, Error> {
        guard let uid = userUid else {
            return Fail(error: ApiError(type: .defaultMessage))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        return Future { [weak self] promise in
            self?.serialQueue.async {
                self?.database.child(uid).child(Constants.couponsDirectory).observe(DataEventType.value, with: { snapshot in
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
                        promise(.success(coupons))
                    } else {
                        promise(.failure(ApiError(type: .defaultMessage)))
                    }
                }) { error in
                    promise(.failure(error))
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    /// getPairCoupons
    /// - Parameter pairUniqId: from getUserInfo()
    /// - Returns: coupons
    func getPairCoupons(pairUniqId: String?) -> AnyPublisher<[Coupon]?, Error> {
        guard let pairUniqId else {
            return Fail(error: ApiError(type: .defaultMessage))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        return Future { [weak self] promise in
            self?.database.child(pairUniqId).child(Constants.couponsDirectory).observe(DataEventType.value, with: { snapshot in
                if let dict = snapshot.value as? [String : AnyObject] {
                    var coupons: [Coupon] = []
                    dict.forEach {
                        if let coupon = $0.value as? [String : Any] {
                            var newCoupon = Coupon(data: coupon)
                            newCoupon.key = $0.key
                            coupons.append(Coupon(data: coupon))
                        }
                    }
                    promise(.success(coupons))
                } else {
                    promise(.failure(ApiError(type: .couponsMessage)))
                }
            }) { error in
                promise(.failure(error))
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func updateCoupon(_ coupon: Coupon, data: Data?) -> AnyPublisher<Bool, Error> {
        guard !coupon.description.isEmpty,
              !coupon.description.isEmpty, !coupon.image.isEmpty,
              let data else {
            return Fail(error: ApiError(type: .fields))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        var coupon = coupon
        guard let uid = userUid else {
            return Fail(error: ApiError(type: .defaultMessage))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        let riversRef = storage.reference().child("\(uid)/\(UUID()).jpg")
        let ref = Database.database().reference().child(uid).child(Constants.couponsDirectory).child(coupon.key ?? UUID().uuidString)
        return Future { [weak self] promise in
            self?.serialQueue.async {
                riversRef.putData(data, metadata: nil) { (metadata, error) in
                    riversRef.downloadURL { (url, error) in
                        if let downloadURL = url {
                            coupon.image = downloadURL.absoluteString
                            guard let values = coupon.toAnyObject() as? [AnyHashable : Any] else {
                                promise(.failure(ApiError(type: .defaultMessage)))
                                return
                            }
                            ref.updateChildValues(values) { (error, reference) in
                                if let error {
                                    promise(.failure(error))
                                } else {
                                    promise(.success(true))
                                }
                            }
                        } else {
                            promise(.failure(error ?? ApiError(type: .defaultMessage)))
                        }
                    }
                }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
    
    func deleteCoupon(_ coupon: Coupon) -> AnyPublisher<Bool, Error> {
        guard let uid = userUid,
              let key = coupon.key else {
            return Fail(error: ApiError(type: .defaultMessage))
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        self.database.child(uid).child(Constants.couponsDirectory).child(key).removeValue()
        return Future { $0(.success(true)) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
