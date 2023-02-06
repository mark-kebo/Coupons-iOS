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

    func login(email: String, password: String, completion: @escaping (Error?) -> Void)
    func logout(completion: @escaping (String?) -> Void)
    func createUser(userInfo: UserInfo, email: String, password: String, completion: @escaping (Error?) -> Void)
    func resetPassword(email: String,completion: @escaping (Error?) -> Void)
    func setUserInfo(_ userInfo: UserInfo, completion: @escaping (Error?) -> Void)
    func getUserInfo(completion: @escaping (UserInfo?, Error?) -> Void)
    func getMyCoupons(completion: @escaping ([Coupon]?, Error?) -> Void)
    func getPairCoupons(completion: @escaping ([Coupon]?, Error?) -> Void)
    func updateCoupon(_ coupon: Coupon, data: Data?, completion: @escaping (Error?) -> Void)
    func deleteCoupon(_ coupon: Coupon, completion: @escaping (Error?) -> Void)
    func getPairEmail(completion: @escaping (String?, Error?) -> Void)
}

final class APIManager: APIManagerProtocol {
    var userUid: String? {
        auth.currentUser?.uid
    }
    
    private let database = Database.database().reference()
    private let storage = Storage.storage()
    private let serialQueue: DispatchQueue
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    private let error = NSError(domain:"", code: 401, userInfo:[ NSLocalizedDescriptionKey: L10n.apiDefaultError]) as Error
    private let errorFields = NSError(domain:"", code: 401, userInfo:[ NSLocalizedDescriptionKey: L10n.errorFields]) as Error
    private let errorCoupons = NSError(domain:"", code: 401, userInfo:[ NSLocalizedDescriptionKey: L10n.Alert.coupons]) as Error
    private let disconnectCoupons = NSError(domain:"", code: 500, userInfo:[ NSLocalizedDescriptionKey: L10n.noInternetConnection]) as Error
    private let auth: Auth
//    private var monitor: NWPathMonitor?

    init() {
        serialQueue = DispatchQueue(label: "queue")
        auth = Auth.auth()
    }
    
//    private func startConnectionMonitor(disconnectCompletion: @escaping (Error?) -> Void) {
//        monitor = NWPathMonitor()
//        let queue = DispatchQueue(label: "Monitor")
//        monitor?.start(queue: queue)
//        monitor?.pathUpdateHandler = { [weak self] path in
//            DispatchQueue.main.async {
//                self?.stopConnectionMonitoring()
//                if path.status != .satisfied {
//                    disconnectCompletion(self?.disconnectCoupons)
//                }
//            }
//        }
//    }
//
//    private func stopConnectionMonitoring() {
//        self.monitor = nil
//    }

    func getPairEmail(completion: @escaping (String?, Error?) -> Void) {
        serialQueue.async {
            self.getUserInfo { [weak self] userInfo, error in
                if let id = userInfo?.pairUniqId {
                    self?.database.child(id).child(Constants.userInfoDirectory).observe(DataEventType.value, with: { snapshot in
                        if let postDict = snapshot.value as? [String : String] {
                            DispatchQueue.main.async {
                                completion(UserInfo(data: postDict).email, nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(nil, self?.error)
                            }
                        }
                    }) { error in
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    func login(email: String, password: String, completion:@escaping (Error?) -> Void) {
        serialQueue.async {
            self.auth.signIn(withEmail: email, password: password) { authResult, error in
                DispatchQueue.main.async {
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func logout(completion:@escaping (String?) -> Void) {
        do {
            try auth.signOut()
            completion(nil)
        } catch {
            completion(L10n.apiDefaultError)
        }
    }
    
    func createUser(userInfo: UserInfo, email: String, password: String, completion:@escaping (Error?) -> Void) {
        serialQueue.async {
            self.auth.createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                } else {
                    self.setUserInfo(userInfo) { error in
                        DispatchQueue.main.async {
                            if let error = error {
                                completion(error)
                            } else {
                                completion(nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func resetPassword(email: String,completion:@escaping (Error?) -> Void) {
        serialQueue.async {
            self.auth.sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }

    func setUserInfo(_ userInfo: UserInfo, completion:@escaping (Error?) -> Void) {
        guard let uid = userUid else {
            completion(error)
            return
        }
        serialQueue.async {
            self.database.child(uid).child(Constants.userInfoDirectory).setValue(userInfo.toAnyObject()) { (error, ref) in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func getUserInfo(completion:@escaping (UserInfo?, Error?) -> Void) {
        guard let uid = userUid else {
            completion(nil, error)
            return
        }
        serialQueue.async {
            self.database.child(uid).child(Constants.userInfoDirectory).observe(DataEventType.value, with: { snapshot in
                if let postDict = snapshot.value as? [String : String] {
                    DispatchQueue.main.async {
                        completion(UserInfo(data: postDict), nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, self.error)
                    }
                }
            }) { error in
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    func getMyCoupons(completion:@escaping ([Coupon]?, Error?) -> Void) {
        guard let uid = userUid else {
            completion(nil, error)
            return
        }
        serialQueue.async {
            self.database.child(uid).child(Constants.couponsDirectory).observe(DataEventType.value, with: { snapshot in
                if let dict = snapshot.value as? [String : AnyObject] {
                    var coupons: [Coupon] = []
                    dict.forEach {
                        if let coupon = $0.value as? [String : String] {
                            var newCoupon = Coupon(data: coupon)
                            newCoupon.key = $0.key
                            coupons.append(newCoupon)
                        }
                    }
                    DispatchQueue.main.async {
                        completion(coupons, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, self.error)
                    }
                }
            }) { error in
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
    }
    
    func getPairCoupons(completion: @escaping ([Coupon]?, Error?) -> Void) {
        serialQueue.async {
            self.getUserInfo { [weak self] userInfo, error in
                if let id = userInfo?.pairUniqId {
                    self?.database.child(id).child(Constants.couponsDirectory).observe(DataEventType.value, with: { snapshot in
                        if let dict = snapshot.value as? [String : AnyObject] {
                            var coupons: [Coupon] = []
                            dict.forEach {
                                if let coupon = $0.value as? [String : String] {
                                    var newCoupon = Coupon(data: coupon)
                                    newCoupon.key = $0.key
                                    coupons.append(Coupon(data: coupon))
                                }
                            }
                            DispatchQueue.main.async {
                                completion(coupons, nil)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(nil, self?.errorCoupons)
                            }
                        }
                    }) { error in
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
        }
    }
    
    func updateCoupon(_ coupon: Coupon, data: Data?, completion:@escaping (Error?) -> Void) {
        var coupon = coupon

        guard let uid = userUid else {
            completion(error)
            return
        }
        if data == nil, !coupon.description.isEmpty, !coupon.image.isEmpty {
            self.newDatabaseCoupon(coupon) { error in
                completion(error)
            }
            return
        }
        guard !coupon.description.isEmpty, let data = data else {
            completion(errorFields)
            return
        }
        
        let riversRef = storage.reference().child("\(uid)/\(UUID()).jpg")
        serialQueue.async {
            riversRef.putData(data, metadata: nil) { (metadata, error) in
                riversRef.downloadURL { (url, error) in
                    if let downloadURL = url {
                        coupon.image = downloadURL.absoluteString
                        self.newDatabaseCoupon(coupon) { error in
                            completion(error)
                        }
                    } else {
                        completion(error ?? self.error)
                    }
                }
            }
        }
    }
    
    func deleteCoupon(_ coupon: Coupon, completion:@escaping (Error?) -> Void) {
        guard let uid = userUid else {
            completion(error)
            return
        }
        guard let key = coupon.key else {
            completion(error)
            return
        }
        self.database.child(uid).child(Constants.couponsDirectory).child(key).removeValue()
    }

    private func newDatabaseCoupon(_ coupon: Coupon, completion: @escaping (Error?) -> Void) {
        guard let uid = userUid else {
            completion(error)
            return
        }

        let ref = Database.database().reference().child(uid).child(Constants.couponsDirectory).child(coupon.key ?? UUID().uuidString)

        guard let values = coupon.toAnyObject() as? [AnyHashable : Any] else {
            completion(error)
            return
        }
        ref.updateChildValues(values) { (error, reference) in
            if let error = error {
                DispatchQueue.main.async {
                    completion(error)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
