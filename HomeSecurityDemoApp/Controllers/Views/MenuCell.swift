//
//  MenuCell.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 27/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

final class MenuCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.cornflowerColor()
    }
    func configureWithMenuItem(item: MenuItem) {
        self.title.text = item.title
        self.icon.image = item.image
    }
}
