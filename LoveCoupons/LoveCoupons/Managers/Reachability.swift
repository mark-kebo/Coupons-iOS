//
//  Reachability.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 25/07/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import Network
import UIKit

class Reachability {
    static let sharedInstance = Reachability()
    private let monitor = NWPathMonitor()

    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                let scene = UIApplication.shared.connectedScenes.first
                if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
                    if path.status == .satisfied {
                        print("We're connected!")
                        sd.setupRootVC()
                    } else {
                        print("No connection.")
                        sd.noInternetVC()
                    }
                }
            }
        }
    }
    
    func startMonitor() {
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }
    
}

