//
//  CacheImages.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 18/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit

protocol CacheProtocol {
    func add(imageToCacheBy key: NSString, and object: UIImage)
    func check(imageInCacheBy key: NSString) -> UIImage?
}

class CacheImages: CacheProtocol {
    var dictionaryCache = [NSString: UIImage]()
    
    func add(imageToCacheBy key: NSString, and object: UIImage) {
        dictionaryCache[key] = object
    }
    
    func check(imageInCacheBy key: NSString) -> UIImage? {
        return dictionaryCache[key]
    }
}
