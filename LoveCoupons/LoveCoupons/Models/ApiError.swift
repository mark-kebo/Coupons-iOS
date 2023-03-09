//
//  ApiError.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 09/03/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation

enum ApiErrorType {
    case defaultMessage
    case fields
    case couponsMessage
    case disconnect
    
    var text: String {
        switch self {
        case .defaultMessage:
            return L10n.apiDefaultError
        case .fields:
            return L10n.errorFields
        case .couponsMessage:
            return L10n.Alert.coupons
        case .disconnect:
            return L10n.noInternetConnection
        }
    }
}

struct ApiError: Error {
    var type: ApiErrorType?
}
