//
//  FamilyMemberCell.swift
//  HomeSecurityDemoApp
//
//  Created by Ilya Myakotin on 14/09/16.
//  Copyright © 2016 Ilya Myakotin. All rights reserved.
//

import Foundation

final class FamilyMemberCell: UICollectionViewCell {
    var avatar: AvatarView = AvatarView.instanceFromNib("AvatarView") as! AvatarView

    override init(frame: CGRect) {
        super.init(frame: frame)
        attachAvatarView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        attachAvatarView()
    }

    func attachAvatarView() {
        avatar.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(avatar)
        let leftConstraint = NSLayoutConstraint(item: avatar, attribute: .Left, relatedBy: .Equal, toItem: contentView, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: avatar, attribute: .Right, relatedBy: .Equal, toItem: contentView, attribute: .Right, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: avatar, attribute: .Top, relatedBy: .Equal, toItem: contentView, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: avatar, attribute: .Bottom, relatedBy: .Equal, toItem: contentView, attribute: .Bottom, multiplier: 1, constant: 0)
        [NSLayoutConstraint.activateConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])]
    }
}
