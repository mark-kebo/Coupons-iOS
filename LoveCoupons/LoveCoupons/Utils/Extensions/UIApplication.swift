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
    
    static var keyWindow: UIWindow? {
        self.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
            .first { $0.isKeyWindow }
    }
}
