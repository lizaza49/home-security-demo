//
//  SecuredModeHeader.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 01/08/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit
import HomeSecurityAPI

final class SecuredModeHeader: UIView {

    var didPressButton: () -> () = {}
    var didPressSensorsListButton: () -> () = {}

    @IBOutlet weak var waitingImage: UIView!
    @IBOutlet weak var sensorsListButton: UIButton!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var back: UIImageView!

    private var animation: CABasicAnimation!
    private var currentMode: SecuredMode.Mode = .Unsecured

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clearColor()
        sensorsListButton.setBackgroundImage(UIColor.whiteColor()
            .colorWithAlphaComponent(0.27).image(), forState: .Normal)
        sensorsListButton.layer.masksToBounds = true
        sensorsListButton.layer.cornerRadius = sensorsListButton.frame.size.height / 2
        sensorsListButton.hidden = true
        waitingImage.hidden = true
        waitingImage.layer.cornerRadius = waitingImage.frame.size.width / 2
        waitingImage.layer.masksToBounds = true

        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.fromValue = 0.0
        animation.toValue = 2 * M_PI
        animation.duration = 4.0
        animation.repeatCount = Float.infinity
        self.animation = animation
    }

    func assignWaitingMode() {
        waitingImage.hidden = false
        actionButton.hidden = true
        statusLabel.text = "Waiting"
        waitingImage.backgroundColor = currentMode == .Alert ? UIColor.whiteColor().colorWithAlphaComponent(0.27) : UIColor.lightPeriwinkleColor()
        waitingImage.layer.removeAnimationForKey("spinAnimation")
        waitingImage.layer.addAnimation(self.animation, forKey: "spinAnimation")
    }

    func assignSecuredMode(state: SecuredMode) {
        waitingImage.hidden = true
        waitingImage.layer.removeAnimationForKey("spinAnimation")
        actionButton.hidden = false
        currentMode = state.mode
        statusLabel.text = state.description
        switch state.mode {
        case .Secured:
            sensorsListButton.hidden = true
            actionButton.setImage(UIImage(named: "bt_sec_enabled"), forState: .Normal)
            back.image = UIImage(named: "blue_shade")
        case .Alert:
            actionButton.setImage(UIImage(named: "bt_sec_disabled_alert"), forState: .Normal)
            back.image = UIImage(named: "red_shade")
            sensorsListButton.hidden = false
        case .Unsecured:
            sensorsListButton.hidden = true
            actionButton.setImage(UIImage(named: "bt_sec_disabled"), forState: .Normal)
            back.image = nil
        }
    }

    @IBAction func actionButtonPressed(sender: AnyObject) {
        didPressButton()
    }

    @IBAction func listButtonPressed(sender: AnyObject) {
        didPressSensorsListButton()
    }
}
