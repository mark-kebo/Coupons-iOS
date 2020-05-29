//
//  ApiManager.swift
//
//  Created by Dmitry Vorozhbicki on 25/10/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import Firebase

class APIManager {
    static let sharedInstance = APIManager()
    private let database = Database.database().reference()
    private let storage = Storage.storage()
    var userUid: String? {
        get {
            return Auth.auth().currentUser?.uid
        }
    }
    private var cache: CacheProtocol
    private let serialQueue: DispatchQueue
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    private let error = NSError(domain:"", code:401, userInfo:[ NSLocalizedDescriptionKey: L10n.apiDefaultError]) as Error
    private let errorFields = NSError(domain:"", code:401, userInfo:[ NSLocalizedDescriptionKey: L10n.errorFields]) as Error

    init() {
        cache = CacheImages()
        serialQueue = DispatchQueue(label: "queue")
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
}

extension APIManager {
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
                if let postDict = snapshot.value as? [String : AnyObject] {
                    DispatchQueue.main.async {
                        completion(UserInfo(data: postDict), nil)
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
                        if let coupon = $0.value as? [String : AnyObject] {
                            var newCoupon = Coupon(data: coupon)
                            newCoupon.key = $0.key
                            coupons.append(newCoupon)
                        }
                    }
                    DispatchQueue.main.async {
                        completion(coupons, nil)
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
                if let error = error {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                } else if let id = userInfo?.pairUniqId {
                    self?.database.child(id).child(Constants.couponsDirectory).observe(DataEventType.value, with: { snapshot in
                        if let dict = snapshot.value as? [String : AnyObject] {
                            var coupons: [Coupon] = []
                            dict.forEach {
                                if let coupon = $0.value as? [String : AnyObject] {
                                    var newCoupon = Coupon(data: coupon)
                                    newCoupon.key = $0.key
                                    coupons.append(Coupon(data: coupon))
                                }
                            }
                            DispatchQueue.main.async {
                                completion(coupons, nil)
                            }
                        }
                    }) { error in
                        DispatchQueue.main.async {
                            completion(nil, error)
                        }
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
        if data == nil, let desc = coupon.description, !desc.isEmpty, let image = coupon.image, !image.isEmpty {
            self.newDatabaseCoupon(coupon) { error in
                completion(error)
            }
            return
        }
        guard let data = data, let desc = coupon.description, !desc.isEmpty else {
            completion(errorFields)
            return
        }
        
        let riversRef = storage.reference().child("\(uid)/\(UUID()).jpg")
        serialQueue.async {
            riversRef.putData(data, metadata: nil) { (metadata, error) in
                riversRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(error)
                    }
                    if let downloadURL = url {
                        coupon.image = downloadURL.absoluteString
                        self.newDatabaseCoupon(coupon) { error in
                            completion(error)
                        }
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
        guard let image = coupon.image else {
            completion(error)
            return
        }
        if image.isEmpty {
            return
        }

        let storageRef = storage.reference(forURL: image)
        self.cache.delete(imageBy: image as NSString)
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

extension APIManager {
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
                }
            }
        }
    }
}
