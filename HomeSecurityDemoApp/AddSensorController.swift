//
//  SecondScreenController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 13.07.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

class AddSensorController: UIViewController {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var identify: UITextField!
    @IBOutlet weak var buttonAdd: UIButton!
    @IBOutlet weak var bottomSpacing: NSLayoutConstraint!
    var didPressBack: () -> () = {}

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Back", style: .Plain, target: self, action: #selector(backButton))
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)

        if keyboardDismissTapGesture == nil {
            keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
            keyboardDismissTapGesture?.cancelsTouchesInView = false
            self.view.addGestureRecognizer(keyboardDismissTapGesture!)
        }
    }

    func backButton() {
        self.didPressBack()
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        super.viewWillDisappear(true)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }

    var keyboardDismissTapGesture: UIGestureRecognizer?

    func keyboardWillChange(notification: NSNotification) {
        let userInfo = notification.userInfo
        let keyboardEndSize: CGRect = (userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).CGRectValue()
        let keyboardBeginSize: CGRect = (userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue!).CGRectValue()
        let animationDurarion = userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSTimeInterval
        let a = keyboardBeginSize.origin.y
        let b = keyboardEndSize.origin.y
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(animationDurarion, animations: {
            self.bottomSpacing.constant += (b - a)
            self.view.layoutIfNeeded()
        })
    }

    @IBAction func addButton(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
