//
//  TableFooter.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 28.07.16.
//  Copyright © 2016 Ilya Myakotin. All rights reserved.
//

import Foundation
import UIKit

class TableFooter: UIView {
    @IBOutlet weak var button: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.layer.cornerRadius = 6.0
        self.button.layer.masksToBounds = true
        self.button.setBackgroundImage(withColor: UIColor.cornflowerColor(), forUIControlState: .Normal)
    }
}
