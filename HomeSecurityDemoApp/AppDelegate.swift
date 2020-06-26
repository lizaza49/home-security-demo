//
//  AppDelegate.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 20/06/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var appRoute: AppRoute?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        Fabric.with([Crashlytics.self()])
        self.window = UIWindow()
        ApplicationApppearance.apply()
        registerForPushNotifications(application)
        if let window = self.window {
            self.appRoute = AppRoute(window: window)
            self.appRoute?.showAuthController()
        }
        self.window?.makeKeyAndVisible()
        return true
    }

    func registerForPushNotifications(application: UIApplication) {
        let settings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(settings)
    }

    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .None {
            application.registerForRemoteNotifications()
        }
    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print(deviceToken)
    }
}
