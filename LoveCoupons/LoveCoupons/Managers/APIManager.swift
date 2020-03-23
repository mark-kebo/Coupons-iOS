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
    var userUid: String? {
        get {
            return Auth.auth().currentUser?.uid
        }
    }
    private var cache: CacheProtocol
    private let serialQueue: DispatchQueue
    private let session = URLSession(configuration: URLSessionConfiguration.default)
    
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
        guard let uid = userUid else { return }
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
        guard let uid = userUid else { return }
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
        guard let uid = userUid else { return }
        serialQueue.async {
            self.database.child(uid).child(Constants.couponsDirectory).observe(DataEventType.value, with: { snapshot in
                if let dict = snapshot.value as? [String : AnyObject] {
                    var coupons: [Coupon] = []
                    dict.forEach {
                        if let coupon = $0.value as? [String : AnyObject] {
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
}

extension APIManager {
    func getImage(by url: String?, completion:@escaping (UIImage?, Error?) -> Void) {
        guard let urlString = url else {
            completion(nil, nil)
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
