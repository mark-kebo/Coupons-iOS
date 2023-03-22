//
//  MediaLoadingService.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import Combine

final class MediaLoadingService {
    
    static let shared = MediaLoadingService()
    private init() {}
    
    private lazy var imageCache: NSCache<NSString, NSData> = {
        let cache = NSCache<NSString, NSData>()
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()
    
    func getMediaData(_ urlString: String) -> AnyPublisher<UIImage?, Never> {
        if let cacheImageData = imageCache.object(forKey: urlString as NSString) as Data?,
           let image = UIImage(data: cacheImageData) {
            return Just(image)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        guard let url = URL(string: urlString) else {
            return Just(nil)
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
        }
        return
            URLSession.shared.dataTaskPublisher(for: url)
                .map {
                    self.imageCache.setObject($0.data as NSData, forKey: url.absoluteString as NSString)
                    return UIImage(data: $0.data)
                }
                .catch { error in Just(nil)}
                .receive(on: RunLoop.main)
                .eraseToAnyPublisher()
    }
}
