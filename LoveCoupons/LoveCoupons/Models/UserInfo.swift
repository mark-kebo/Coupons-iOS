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
    
    init(data: [String : String]) {
        name = data["name"]
        pairUniqId = data["pairUniqId"]
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
