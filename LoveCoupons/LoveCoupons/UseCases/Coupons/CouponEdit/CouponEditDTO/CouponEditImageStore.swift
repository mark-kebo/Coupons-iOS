//
//  CouponEditImageStore.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import Combine
import UIKit

final class CouponEditImageStore: ObservableObject {
    @Published var image: UIImage? = UIImage(asset: Asset.addImage)
}
