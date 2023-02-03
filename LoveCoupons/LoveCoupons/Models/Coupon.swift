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
    
    private enum CodingCases: String {
        case description
        case image
    }
    
    init(data: [String: String]) {
        description = data[CodingCases.description.rawValue] ?? ""
        image = data[CodingCases.image.rawValue] ?? ""
    }
    
    init(description: String, image: String) {
        self.description = description
        self.image = image
    }
    
    func toAnyObject() -> Any? {
        [
            CodingCases.description.rawValue: description,
            CodingCases.image.rawValue: image
        ]
    }
}
