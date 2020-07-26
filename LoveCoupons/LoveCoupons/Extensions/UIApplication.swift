//
//  UIApplication.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 24/07/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
