//
//  AppDelegate.swift
//  LiveView
//
//  Created by Lacy Rhoades on 7/6/17.
//  Copyright © 2017 Lacy Rhoades. All rights reserved.
//

import UIKit

let streamURL = URL(string: "http://192.168.2.3:8080/")!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = UINavigationController(rootViewController: ViewController())
        self.window?.makeKeyAndVisible()
        
        return true
    }

}

