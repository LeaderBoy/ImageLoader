//
//  AppDelegate.swift
//  ImageLoader
//
//  Created by 杨志远 on 2020/1/14.
//  Copyright © 2020 BaQiWL. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ImageViewController()
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        self.window = window
        return true
    }


}

