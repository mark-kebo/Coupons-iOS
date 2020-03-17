//
//  ApiManager.swift
//
//  Created by Dmitry Vorozhbicki on 25/10/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation
import Alamofire
import Firebase

class APIManager {
    static let sharedInstance = APIManager()
    private let database = Database.database().reference()
    var userUid: String? {
        get {
            return Auth.auth().currentUser?.uid
        }
    }

    func login(email: String, password: String, completion:@escaping (Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
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
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(error)
            } else {
                self.set(userInfo: userInfo) { error in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func resetPassword(email: String,completion:@escaping (Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
}

extension APIManager {
    func set(userInfo: UserInfo, completion:@escaping (Error?) -> Void) {
        guard let uid = userUid else { return }
        self.database.child(uid).child(Constants.userInfoDirectory).setValue(userInfo.toAnyObject()) { (error, ref) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func getUserInfo(completion:@escaping (UserInfo?, Error?) -> Void) {
        guard let uid = userUid else { return }
        database.child(uid).child(Constants.userInfoDirectory).observe(DataEventType.value, with: { snapshot in
            if let postDict = snapshot.value as? [String : AnyObject] {
                completion(UserInfo(data: postDict), nil)
            }
        }) { error in
            completion(nil, error)
        }

    }
}
