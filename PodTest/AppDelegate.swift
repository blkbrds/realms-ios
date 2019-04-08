//
//  AppDelegate.swift
//  PodTest
//
//  Created by DaoNV on 10/19/16.
//  Copyright © 2016 Apple Inc. All rights reserved.
//

import UIKit
import RealmS

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        RealmS.onError { (_, _, _) in
            //
        }
        return true
    }
}
