//
//  AuthController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 18.07.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit
import HomeSecurityAPI
import RxSwift
import Result

class AuthController: UIViewController, UIGestureRecognizerDelegate, ErrorAlertConstructor, ErrorsHandler, ValidationProtocol {
    @IBOutlet weak var bottomSp: NSLayoutConstraint!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginField: UITextField!
    @IBOutlet weak var authButton: UIButton!
    @IBOutlet weak var passwordContainer: UIView!
    @IBOutlet weak var loginContainer: UIView!
    @IBOutlet weak var regButton: UIButton!

    var didPressAuth: () -> () = {}
    var didPressRegister: () -> () = {}
    var keyboardDismissTapGesture: UIGestureRecognizer?
    let disposeBag = DisposeBag()
    var ignoreFields = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordContainer.layer.cornerRadius = 6.0
        self.loginContainer.layer.cornerRadius = 6.0
        self.authButton.layer.cornerRadius = 6.0
        self.authButton.layer.masksToBounds = true
        self.authButton.setBackgroundImage(withColor: UIColor.cornflowerColor(), forUIControlState: .Normal)
        self.view.backgroundColor = UIColor.paleGreyColor()
        self.navigationController?.navigationBarHidden = true
        self.regButton.layer.cornerRadius = 6.0
        self.regButton.layer.borderWidth = 2.0
        self.regButton.layer.borderColor = UIColor.cornflowerColor().CGColor
        self.keyboardDismissTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.keyboardDismissTapGesture?.delegate = self
        self.keyboardDismissTapGesture?.cancelsTouchesInView = false
        if let recognizer = self.keyboardDismissTapGesture {
            self.view.addGestureRecognizer(recognizer)
        }
        ignoreFields = [authButton, regButton]
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.bottomSp.constant = 0
        self.navigationController?.navigationBarHidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    @IBAction func authButtonPressed(sender: AnyObject) {
        let login = loginField.text ?? String()
        let password = passwordField.text ?? String()
        let fields = [InputFieldData(text: login, fieldName: "Username", validate: { text in
            try InputFieldValidationFunctions.notEmpty("Username", text)
        }), InputFieldData(text: password, fieldName: "Password", validate: { text in
            try InputFieldValidationFunctions.notEmpty("Password", text)
        })]

        validate(fields).map { _ in .Success() }.catchError { error in
            return Observable.just(.Failure(LoginError.ValidationError(error))) }.flatMap { (result: Result<Void, LoginError>) -> Observable<Result<AuthService.FamilyMemberStatus, LoginError>> in
            switch result {
            case .Success:
                return CospaceServices.authService.login(username: login, password: password).doOnNext { _ in LocationService.sharedService.start() }.map { .Success($0) }.catchError { Observable.just(.Failure(LoginError.APIError($0))) }
            case .Failure(let error):
                return Observable.just(.Failure(error))
            }
        }.subscribeNext { result in
            switch result {
            case .Success:
                self.didPressAuth()
            case .Failure(let error):
                self.handleError(error)
            }
        }.addDisposableTo(disposeBag)
    }

    @IBAction func registrationPressed(sender: AnyObject) {
        self.didPressRegister()
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
    }

    func dismissKeyboard() {
        self.view.endEditing(true)
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let touchView = touch.view where self.ignoreFields.containsObject(touchView) {
            return false
        }
        return true
    }

    func keyboardWillChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardBeginSizeValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue,
            let keyboardEndSizeValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval else { return }
        let end = keyboardEndSizeValue.CGRectValue().origin.y
        let begin = keyboardBeginSizeValue.CGRectValue().origin.y
        self.view.layoutIfNeeded()
        UIView.animateWithDuration(animationDurarion, animations: {
            self.bottomSp.constant -= end - begin
            self.view.layoutIfNeeded()
        })
    }
}

enum LoginError: ErrorType, CustomStringConvertible {
    case ValidationError(ErrorType)
    case APIError(ErrorType)

    var description: String {
        switch self {
        case .ValidationError(let error):
            guard let error = error as? CustomStringConvertible else { return "Unknown error" }
            return error.description
        case .APIError(let error):
            guard let error = error as? CustomStringConvertible else { return "Unknown error" }
            return error.description
        }
    }
}
