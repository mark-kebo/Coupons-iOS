//
//  Coupon.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 17/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation

struct Coupon: Identifiable, Hashable {
    var id = UUID()
    var key: String?
    var description: String
    var image: String
    
    init() {
        description = ""
        image = ""
    }
    
    init(data: [String : String]) {
        description = data["description"] ?? ""
        image = data["image"] ?? ""
    }
    
    init(description: String, image: String) {
        self.description = description
        self.image = image
    }
    
    func toAnyObject() -> Any? {
        return [
            "description": description,
            "image": image
        ]
    }
}
