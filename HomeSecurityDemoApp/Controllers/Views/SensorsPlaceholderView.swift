//
//  ViewForTableView.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 11.08.16.
//  Copyright © 2016 Ilya Myakotin. All rights reserved.
//

import Foundation
import UIKit

class SensorsPlaceholderView: UIView {

    @IBOutlet weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.paleGreyColor()
        titleLabel.textColor = UIColor.pinkishGreyColor()
    }
}
