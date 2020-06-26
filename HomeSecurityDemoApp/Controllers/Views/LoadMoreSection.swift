//
//  LoadMoreSection.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 08/08/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

final class LoadMoreSection: UIView {

    var didPressMoreButton: () -> () = {}

    @IBOutlet weak var moreButton: UIButton!

    override func awakeFromNib() {
        backgroundColor = UIColor.paleGreyColor()
        moreButton.layer.cornerRadius = moreButton.frame.size.height / 2
        moreButton.layer.masksToBounds = true
        moreButton.setBackgroundImage(withColor: UIColor.lightPeriwinkleColor(), forUIControlState: .Normal)
    }

    @IBAction func moreButtonPressed(sender: AnyObject) {
        didPressMoreButton()
    }
}
