//
//  NavigationBarCustomizeProtocol.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 08.08.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation

protocol ControlsNavigationBarAppearance {
    var navigationBarTintColor: UIColor { get }
    var navigationItemTintColor: UIColor { get }
    var navigationBarStyle: UIBarStyle { get }
    var navigationTranslucent: Bool { get }
}

extension UIViewController: ControlsNavigationBarAppearance {
    var navigationBarTintColor: UIColor {
        return UIColor.cornflowerColor()
    }

    var navigationItemTintColor: UIColor {
        return UIColor.whiteColor()
    }

    var navigationBarStyle: UIBarStyle {
        return UIBarStyle.Black
    }

    var navigationTranslucent: Bool {
        return false
    }

    public override class func initialize() {
        struct Static {
            static var token: dispatch_once_t = 0
        }

        if self !== UIViewController.self {
            return
        }

        dispatch_once(&Static.token) {
            let originalSelector = #selector(UIViewController.viewWillAppear(_:))
            let swizzledSelector = #selector(UIViewController.sol_viewWillAppear(_:))

            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

            let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod)
            }
        }
    }

    func sol_viewWillAppear(animated: Bool) {
        self.sol_viewWillAppear(animated)
        self.configureNavBar()
    }

    func configureNavBar() -> () {
        if let navVC = self.navigationController {
            navVC.navigationBar.barTintColor = navigationBarTintColor
            navVC.navigationBar.tintColor = navigationItemTintColor
            navVC.navigationBar.barStyle = navigationBarStyle
            navVC.navigationBar.translucent = navigationTranslucent
        }
    }
}
