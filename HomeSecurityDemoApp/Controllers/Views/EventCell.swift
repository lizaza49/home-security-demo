//
//  EventCell.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 02/08/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

final class EventCell: UITableViewCell {

    @IBOutlet weak var eventIcon: UIImageView!
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var eventTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        eventTime.textColor = UIColor.brownishGreyColor().colorWithAlphaComponent(0.6)
        eventTitle.textColor = UIColor.brownishGreyColor().colorWithAlphaComponent(0.6)
    }
}
