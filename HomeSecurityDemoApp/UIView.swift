//
//  Views.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 27/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    static func instanceFromNib(nibName: String, bundle: NSBundle? = nil) -> UIView? {
        guard let view = UINib(nibName: nibName, bundle: bundle).instantiateWithOwner(nil, options: nil)[0] as? UIView else { return nil }
        return view
    }
}
