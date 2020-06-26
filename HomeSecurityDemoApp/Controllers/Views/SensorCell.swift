//
//  SensorCell.swift
//  HomeSecurityDemoApp
//
//  Created by Ilya Myakotin on 22/07/16.
//  Copyright © 2016 Ilya Myakotin. All rights reserved.
//

import Foundation
import UIKit

final class SensorCell: UITableViewCell {

    @IBOutlet weak var labelForType: UILabel!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var imageStatus: UIImageView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
