//
//  MediaLoadingService.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit

final class MediaLoadingService {
    
    static let shared = MediaLoadingService()
    private init() {}
    
    private lazy var imageCache: NSCache<NSString, NSData> = {
        let cache = NSCache<NSString, NSData>()
        cache.totalCostLimit = 1024 * 1024 * 100
        return cache
    }()
    
    func getMediaData(_ urlString: String, closure: @escaping ((Result<UIImage, Error>) -> Void)) {
        if let cacheImageData = imageCache.object(forKey: urlString as NSString) as Data?,
           let image = UIImage(data: cacheImageData) {
            closure(.success(image))
            return
        }
        guard let url = URL(string: urlString) else {
            closure(.failure(NSError()))
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            
            guard let data = data , error == nil, let img = UIImage(data: data) else {
                let errorMessage = "Can't download image data: \(error?.localizedDescription ?? "")"
                NSLog(errorMessage)
                if let error {
                    closure(.failure(error))
                }
                return
            }
            self?.imageCache.setObject(data as NSData, forKey: url.absoluteString as NSString)
            DispatchQueue.main.async {
                closure(.success(img))
            }
        }.resume()
    }
}
