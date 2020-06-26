//
//  AvatarView.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 30/08/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import HomeSecurityAPI
import UIKit

class AvatarView: UIView {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        avatarImage.backgroundColor = UIColor.whiteColor()
        avatarImage.image = nil
        avatarImage.layer.masksToBounds = true
        nameLabel.textColor = UIColor.greyishBrownColor()
    }

    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        avatarImage.layer.cornerRadius = avatarImage.frame.height / 2
    }
}

extension AvatarView {
    func configureWithFamilyMember(member: FamilyMember) {
        nameLabel.text = member.name
        avatarImage.image = member.image ?? UIImage(named: "photo_placeholder")
        avatarImage.contentMode = .ScaleToFill
        if member.isAtHome {
            avatarImage.layer.borderWidth = 3
            avatarImage.layer.borderColor = UIColor.lightSageColor().CGColor
        } else {
            avatarImage.layer.borderWidth = 0
        }
    }

    func configureWithSensor(sensor: Sensor) {
        nameLabel.text = sensor.description
        avatarImage.contentMode = .Center
        if let state = sensor.state {
            avatarImage.image = UIImage(named: state.isOpen ? "sensor_open" : "sensor_closed")
        } else {
            avatarImage.image = UIImage(named: "sensor_unknown")
        }
    }
}
