//
//  Colors.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 27/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

// Color palette

extension UIColor {
    class func cornflowerColor() -> UIColor {
        return UIColor(red: 117.0 / 255.0, green: 142.0 / 255.0, blue: 247.0 / 255.0, alpha: 1.0)
    }

    class func lightSageColor() -> UIColor {
        return UIColor(red: 184.0 / 255.0, green: 233.0 / 255.0, blue: 134.0 / 255.0, alpha: 1.0)
    }

    class func rougeColor() -> UIColor {
        return UIColor(red: 169.0 / 255.0, green: 32.0 / 255.0, blue: 53.0 / 255.0, alpha: 1.0)
    }

    class func blueberryColor() -> UIColor {
        return UIColor(red: 58.0 / 255.0, green: 68.0 / 255.0, blue: 124.0 / 255.0, alpha: 1.0)
    }

    class func paleGreyColor() -> UIColor {
        return UIColor(red: 239.0 / 255.0, green: 239.0 / 255.0, blue: 244.0 / 255.0, alpha: 1.0)
    }

    class func carmineColor() -> UIColor {
        return UIColor(red: 159.0 / 255.0, green: 4.0 / 255.0, blue: 27.0 / 255.0, alpha: 1.0)
    }

    class func greyishBrownColor() -> UIColor {
        return UIColor(red: 74.0 / 255.0, green: 74.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
    }

    class func brownishGreyColor() -> UIColor {
        return UIColor(white: 102.0 / 255.0, alpha: 1.0)
    }

    class func lightPeriwinkleColor() -> UIColor {
        return UIColor(red: 182.0 / 255.0, green: 195.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    }

    class func pinkishGreyColor() -> UIColor {
        return UIColor(white: 186.0 / 255.0, alpha: 1.0)
    }
}

extension UIColor {
    func image() -> UIImage {
        let rect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()

        CGContextSetFillColorWithColor(context, self.CGColor)
        CGContextFillRect(context, rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}
