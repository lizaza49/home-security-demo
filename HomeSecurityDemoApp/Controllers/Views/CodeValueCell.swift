//
//  CodeValueCell.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 10.08.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation

class CodeValueCell: ValueCell {

    @IBOutlet weak var qrButton: UIButton!
    var qrScanPressed: () -> () = { _ in }

    override func awakeFromNib() {
        super.awakeFromNib()
        qrButton.layer.borderWidth = 2.0
        qrButton.layer.borderColor = UIColor.cornflowerColor().CGColor
        qrButton.layer.cornerRadius = 6.0
    }

    @IBAction func qrButtonPressed(sender: AnyObject) {
        self.qrScanPressed()
    }
}
