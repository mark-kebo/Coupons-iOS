//
//  SplashScreenViewController.swift
//
//  Created by Dmitry Vorozhbicki on 28/10/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import UIKit

class SplashScreenViewController: BaseViewController {
    private let entitiesManager = EntitiesManager.shared
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        setupRoot()
    }
}

//MARK: - Private
fileprivate extension SplashScreenViewController {
    func setupRoot() {
        appDelegate?.setupRootViewController()
    }
    
    func loadData() {
    }
}

