//
//  UIButton.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 29/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    func setBackgroundImage(withColor color: UIColor, forUIControlState state: UIControlState) {
        self.setBackgroundImage(color.image(), forState: state)
    }
}
