//
//  PairCouponsMailDataStore.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/02/2023.
//  Copyright © 2023 Dmitry Vorozhbicki. All rights reserved.
//

import Combine
import UIKit
import MessageUI

final class PairCouponsMailDataStore: ObservableObject {
    @Published var result: Result<MFMailComposeResult, Error>? = nil
    @Published var emailMessage: String = ""
    @Published var bodyMessage: String = ""
}
