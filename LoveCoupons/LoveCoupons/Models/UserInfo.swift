//
//  UserInfo.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 22/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation

struct UserInfo {
    let name: String?
    let email: String?
    let pairUniqId: String?
    
    init(data: [String : String]) {
        name = data["name"]
        email = data["email"]
        pairUniqId = data["pairUniqId"]
    }
    
    init(name: String?, email: String?, pairUniqId: String?) {
        self.name = name
        self.email = email
        self.pairUniqId = pairUniqId
    }
    
    func toAnyObject() -> Any? {
        return [
            "name": name ?? "",
            "email": email ?? "",
            "pairUniqId": pairUniqId ?? ""
        ]
    }
}
