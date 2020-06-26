//
//  DateSection.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 04.08.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

class DateSection: UIView {
    @IBOutlet weak var dateLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.paleGreyColor()
        self.dateLabel.textColor = UIColor.brownishGreyColor().colorWithAlphaComponent(0.6)
    }
}
