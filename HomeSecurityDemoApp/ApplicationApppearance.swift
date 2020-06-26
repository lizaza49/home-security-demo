//
//  NavigationBarAppearance.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 18.07.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

struct ApplicationApppearance {
    static func apply() -> () {
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
    }
}
