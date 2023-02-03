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
    
    private enum CodingCases: String {
        case name
        case email
        case pairUniqId
    }
    
    init(data: [String: String]) {
        name = data[CodingCases.name.rawValue]
        email = data[CodingCases.email.rawValue]
        pairUniqId = data[CodingCases.pairUniqId.rawValue]
    }
    
    init(name: String?, email: String?, pairUniqId: String?) {
        self.name = name
        self.email = email
        self.pairUniqId = pairUniqId
    }
    
    func toAnyObject() -> Any? {
        [
            CodingCases.name.rawValue: name ?? "",
            CodingCases.email.rawValue: email ?? "",
            CodingCases.pairUniqId.rawValue: pairUniqId ?? ""
        ]
    }
}
