//
//  ErrorableCoordinatorProtocol.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 03/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit
import SwiftUI

protocol ErrorableCoordinatorProtocol: CoordinatorProtocol {
    func showError(_ error: String)
}

extension ErrorableCoordinatorProtocol {
    func showError(_ error: String) {
        NSLog("Show error: \(error)")
        DispatchQueue.main.async {
            let alert = UIAlertController(title: L10n.error,
                                          message: error,
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: L10n.Alert.Button.cancel,
                                          style: UIAlertAction.Style.default, handler: nil))
            self.rootNavigationController?.present(alert, animated: true, completion: nil)
        }
    }
}
