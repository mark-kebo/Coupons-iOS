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
    let pairUniqId: String?
    
    init(data: [String : AnyObject]) {
        name = data["name"] as? String
        pairUniqId = data["pairUniqId"] as? String
    }
    
    init(name: String?, pairUniqId: String?) {
        self.name = name
        self.pairUniqId = pairUniqId
    }
    
    func toAnyObject() -> Any? {
        return [
            "name": name ?? "",
            "pairUniqId": pairUniqId ?? ""
        ]
    }
}
