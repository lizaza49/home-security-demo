//
//  TypeOfSensorCell.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 28.07.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

class SelectionCell: UITableViewCell {

    @IBOutlet weak var typeOfLabel: UILabel!
    @IBOutlet weak var sensorsTypeLabel: UILabel!

    var didTapCell: () -> () = {}

    override func awakeFromNib() {
        super.awakeFromNib()

        let tgr = UITapGestureRecognizer.init(target: self, action: #selector(cellTapped))
        self.contentView.addGestureRecognizer(tgr)
    }

    func cellTapped() {
        self.didTapCell()
    }
}
