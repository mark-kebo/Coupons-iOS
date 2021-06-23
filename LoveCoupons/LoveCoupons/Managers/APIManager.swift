//
//  ApiManager.swift
//
//  Created by Dmitry Vorozhbicki on 25/10/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import Firebase

protocol APIManagerProtocol {
    static var sharedInstance: APIManagerProtocol { get }
    var userUid: String? { get }

    func login(email: String, password: String, completion:@escaping (Error?) -> Void)
    func logout(completion:@escaping (String?) -> Void)
    func createUser(userInfo: UserInfo, email: String, password: String, completion:@escaping (Error?) -> Void)
    func resetPassword(email: String,completion:@escaping (Error?) -> Void)
    func set(userInfo: UserInfo, completion:@escaping (Error?) -> Void)
    func getUserInfo(completion:@escaping (UserInfo?, Error?) -> Void)
    func getMyCoupons(completion:@escaping ([Coupon]?, Error?) -> Void)
    func getPairCoupons(completion:@escaping ([Coupon]?, Error?) -> Void)
    func updateCoupon(_ coupon: Coupon, data: Data?, completion:@escaping (Error?) -> Void)
    func deleteCoupon(_ coupon: Coupon, completion:@escaping (Error?) -> Void)
    func getImage(by url: String?, completion:@escaping (UIImage?, Error?) -> Void)
    func getPairEmail(completion:@escaping (String?, Error?) -> Void)
}

class APIManager: APIManagerProtocol {
    static let sharedInstance: APIManagerProtocol = APIManager()
    var userUid: String? {
        get {
            return Auth.auth().currentUser?.uid
        }
    }
    
    private let database = Database.database().reference()
    private let storage = Storage.storage()
    private var cache: CacheProtocol
    private let serialQueue: DispatchQueue
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    private let error = NSError(domain:"", code:401, userInfo:[ NSLocalizedDescriptionKey: L10n.apiDefaultError]) as Error
    private let errorFields = NSError(domain:"", code:401, userInfo:[ NSLocalizedDescriptionKey: L10n.errorFields]) as Error
    private let errorCoupons = NSError(domain:"", code:401, userInfo:[ NSLocalizedDescriptionKey: L10n.Alert.coupons]) as Error

    init() {
        cache = CacheImages()
        serialQueue = DispatchQueue(label: "queue")
    }

    func getPairEmail(completion:@escaping (String?, Error?) -> Void) {
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
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
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
            try Auth.auth().signOut()
            completion(nil)
        } catch {
            completion(L10n.apiDefaultError)
        }
    }
    
    func createUser(userInfo: UserInfo, email: String, password: String, completion:@escaping (Error?) -> Void) {
        serialQueue.async {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                } else {
                    self.set(userInfo: userInfo) { error in
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
            Auth.auth().sendPasswordReset(withEmail: email) { error in
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

    func set(userInfo: UserInfo, completion:@escaping (Error?) -> Void) {
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
    
    func getPairCoupons(completion:@escaping ([Coupon]?, Error?) -> Void) {
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
                        self.deleteImage(coupon) { error in
                            completion(error)
                        }
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

        deleteImage(coupon) { error in
            completion(error)
        }
    }

    func getImage(by url: String?, completion:@escaping (UIImage?, Error?) -> Void) {
        guard let urlString = url else {
            completion(nil, error)
            return
        }
        serialQueue.async {
            if let image = self.cache.check(imageInCacheBy: urlString as NSString) {
                DispatchQueue.main.async {
                    completion(image, nil)
                }
            } else {
                if let url: URL = URL(string: urlString) {
                    URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                        guard let data = data , error == nil, let img = UIImage(data: data) else {
                            completion(nil, error)
                            return }
                        self?.serialQueue.async {
                            self?.cache.add(imageToCacheBy: urlString as NSString, and: img)
                            DispatchQueue.main.async {
                                completion(img, nil)
                            }
                        }
                    }.resume()
                } else {
                    completion(nil, self.error)
                }
            }
        }
    }
}

extension APIManager {
    private func newDatabaseCoupon(_ coupon: Coupon, completion:@escaping (Error?) -> Void) {
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
    
    private func deleteImage(_ coupon: Coupon, completion:@escaping (Error?) -> Void) {
        if coupon.image.isEmpty {
            return
        }

        let storageRef = storage.reference(forURL: coupon.image)
        self.cache.delete(imageBy: coupon.image as NSString)
        serialQueue.async {
            storageRef.delete { error in
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
}
