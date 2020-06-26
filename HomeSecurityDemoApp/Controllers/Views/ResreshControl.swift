//
//  ResreshControl.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 03.08.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit
import Refresher

class RefreshControl: UIView, PullToRefreshViewDelegate {

    @IBOutlet weak var refreshImageView: UIImageView!
    private var animation: CABasicAnimation!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.paleGreyColor()
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = -2 * M_PI
        animation.duration = 1.0
        animation.repeatCount = Float.infinity
        self.animation = animation
    }

    func pullToRefreshAnimationDidStart(view: PullToRefreshView) {
        self.refreshImageView.layer.addAnimation(self.animation, forKey: "spinAnimation")
    }

    func pullToRefreshAnimationDidEnd(view: PullToRefreshView) {
        self.refreshImageView.layer.removeAnimationForKey("spinAnimation")
    }

    func pullToRefresh(view: PullToRefreshView, progressDidChange progress: CGFloat) {}

    func pullToRefresh(view: PullToRefreshView, stateDidChange state: PullToRefreshViewState) {}
}
