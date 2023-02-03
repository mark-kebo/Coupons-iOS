//
//  CacheImages.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 18/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit

protocol CacheImagesProtocol {
    func add(imageToCacheBy key: NSString, and object: UIImage)
    func check(imageInCacheBy key: NSString) -> UIImage?
    func delete(imageBy key: NSString)
}

final class CacheImages: CacheImagesProtocol {
    private var dictionaryCache = [NSString: UIImage]()
    
    func add(imageToCacheBy key: NSString, and object: UIImage) {
        dictionaryCache[key] = object
    }
    
    func check(imageInCacheBy key: NSString) -> UIImage? {
        dictionaryCache[key]
    }
    
    func delete(imageBy key: NSString) {
        dictionaryCache.removeValue(forKey: key)
    }
}
