//
//  AppDelegate.swift
//  DeltaCamera
//
//  Created by Karsten Bruns on 23/11/15.
//  Copyright © 2015 bruns.me. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        let colorListViewController = ColorListViewController()
        let navigationController = UINavigationController(rootViewController: colorListViewController)
        
        let window = UIWindow()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window

        return true
    }


}

