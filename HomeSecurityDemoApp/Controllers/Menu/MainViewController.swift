//
//  MainViewController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 27/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit
import HomeSecurityAPI
import RxSwift
import Refresher

class MainViewController: UIViewController, ErrorAlertConstructor, ErrorsHandler {
    var didPressSensorsList: () -> () = {}
    var didPressMembersList: () -> () = {}

    @IBOutlet private weak var widgetsContentScrollView: UIScrollView!
    @IBOutlet private weak var securedButtonContainer: UIView!
    @IBOutlet private weak var atHomeMembersContainer: UIView!
    @IBOutlet private weak var sensorsContainer: UIView!

    private let securedButtonView = SecuredModeHeader.instanceFromNib("SecuredModeHeader") as! SecuredModeHeader
    private let atHomeMembersWidget = WidgetView.instanceFromNib("WidgetView") as! WidgetView
    private let sensorsWidget = WidgetView.instanceFromNib("WidgetView") as! WidgetView
    private var currentSecureStatus = SecuredMode.Mode.Unsecured
    private let disposeBag = DisposeBag()
    private var timer: NSTimer!

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
        let revealVC = revealViewController()
        let pgr = revealVC.panGestureRecognizer()
        view.addGestureRecognizer(pgr)
        revealVC.tapGestureRecognizer()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "menu"), style: .Plain, target: revealVC, action: #selector(SWRevealViewController.revealToggle))
        navigationItem.title = "HOME"
        view.backgroundColor = UIColor.blueberryColor()
        atHomeMembersContainer.backgroundColor = UIColor.clearColor()
        atHomeMembersContainer.hidden = true
        sensorsContainer.hidden = true
        sensorsContainer.backgroundColor = UIColor.clearColor()
        securedButtonView.backgroundColor = UIColor.clearColor()
        atHomeMembersWidget.titleLabel.text = "At home"
        sensorsWidget.titleLabel.text = "Sensors activity"
        sensorsWidget.actionButton.rx_tap.subscribeNext { [unowned self] in self.didPressSensorsList() }.addDisposableTo(disposeBag)
        atHomeMembersWidget.actionButton.rx_tap.subscribeNext { [unowned self] in self.didPressMembersList() }.addDisposableTo(disposeBag)
        addSubview(securedButtonView, toView: securedButtonContainer)
        addSubview(atHomeMembersWidget, toView: atHomeMembersContainer, inset: UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8))
        addSubview(sensorsWidget, toView: sensorsContainer, inset: UIEdgeInsets(top: 5, left: 8, bottom: 5, right: 8))

        securedButtonView.didPressButton = { [unowned self] in
            let newstatus: SecuredMode.Mode
            if self.currentSecureStatus == SecuredMode.Mode.Unsecured {
                newstatus = SecuredMode.Mode.Secured
            } else {
                newstatus = SecuredMode.Mode.Unsecured
            }
            self.securedButtonView.assignWaitingMode()
            self.updateStatus(newstatus)
        }
        securedButtonView.didPressSensorsListButton = { [unowned self] in self.didPressSensorsList() }
        CospaceServices.sensorsService.getCurrentUserSensorsList().subscribe(onNext: { [unowned self] sensors in
            if sensors.count == 0 {
                self.handleError(ServiceError.NoSensors)
            }
        }, onError: { [unowned self] error in self.handleError(error) }).addDisposableTo(disposeBag)
    }

    func addSubview(subview: UIView, toView: UIView, inset: UIEdgeInsets = UIEdgeInsets()) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        toView.addSubview(subview)
        let leftConstraint = NSLayoutConstraint(item: subview, attribute: .Left, relatedBy: .Equal, toItem: toView, attribute: .Left, multiplier: 1, constant: inset.left)
        let rightConstraint = NSLayoutConstraint(item: subview, attribute: .Right, relatedBy: .Equal, toItem: toView, attribute: .Right, multiplier: 1, constant: -inset.right)
        let topConstraint = NSLayoutConstraint(item: subview, attribute: .Top, relatedBy: .Equal, toItem: toView, attribute: .Top, multiplier: 1, constant: inset.top)
        let bottomConstraint = NSLayoutConstraint(item: subview, attribute: .Bottom, relatedBy: .Equal, toItem: toView, attribute: .Bottom, multiplier: 1, constant: -inset.bottom)
        [NSLayoutConstraint.activateConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])]
    }

    func timerFired() {
        CospaceServices.securityService.getSecuredState().subscribe(onNext: { [unowned self] status in
            self.changeStatus(status)
        }, onError: { print($0) }).addDisposableTo(disposeBag)
        CospaceServices.familyService.getFamilyMembersList(withImages: true).subscribe(onNext: { [unowned self] members in
            self.atHomeMembersContainer.hidden = members.count == 0
            let avatars: [AvatarView] = members.map { member in
                let view = AvatarView.instanceFromNib("AvatarView") as! AvatarView
                view.configureWithFamilyMember(member)
                return view
            }
            self.atHomeMembersWidget.items = avatars
        }, onError: { print($0) }).addDisposableTo(disposeBag)
        CospaceServices.sensorsService.getCurrentUserSensorsList().subscribe(onNext: { [unowned self] sensors in
            self.sensorsContainer.hidden = sensors.count == 0
            let avatars: [AvatarView] = sensors.map { sensor in
                let view = AvatarView.instanceFromNib("AvatarView") as! AvatarView
                view.configureWithSensor(sensor)
                return view
            }
            self.sensorsWidget.items = avatars
        }, onError: { print($0) }).addDisposableTo(disposeBag)
    }

    override func viewDidAppear(animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }

    override func viewWillDisappear(animated: Bool) {
        timer.invalidate()
        timer = nil
    }

    func updateStatus(status: SecuredMode.Mode) {
        CospaceServices.securityService.updateSecuredState(status).flatMap {
            return CospaceServices.securityService.getSecuredState()
        }.catchError { [unowned self] error in
            self.handleError(error)
            return CospaceServices.securityService.getSecuredState()
        }.doOnNext { [unowned self] state in
            self.changeStatus(state)
        }.subscribe(onError: { [unowned self] error in self.handleError(error) }).addDisposableTo(disposeBag)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        securedButtonView.assignWaitingMode()
        CospaceServices.securityService.getSecuredState().subscribe(onNext: { [unowned self] status in
            self.changeStatus(status)
        }, onError: { [unowned self] error in self.handleError(error) }).addDisposableTo(disposeBag)
        CospaceServices.sensorsService.getCurrentUserSensorsList().subscribe(onNext: { [unowned self] sensors in
            self.sensorsContainer.hidden = sensors.count == 0
        }, onError: { [unowned self] error in self.handleError(error) }).addDisposableTo(disposeBag)
        CospaceServices.familyService.getFamilyMembersList().subscribe(onNext: { [unowned self] members in
            self.atHomeMembersContainer.hidden = members.count == 0
        }, onError: { [unowned self] error in self.handleError(error) }).addDisposableTo(disposeBag)
    }

    func changeStatus(status: SecuredMode) {
        currentSecureStatus = status.mode
        view.backgroundColor = status.mode == .Alert ? UIColor.rougeColor() : UIColor.blueberryColor()
        securedButtonView.assignSecuredMode(status)
        view.setNeedsLayout()
    }

    func alert(forError error: ErrorType) -> UIAlertController? {
        if let serviceError = error as? ServiceError {
            switch serviceError {
            case .NoSensors:
                let alert = UIAlertController.init(title: "", message: "You don't have any sensors yet. Do you want to add one?", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: { _ in self.didPressSensorsList() }))
                return alert
            case .NotAllSensorsClosed(_):
                let alert = UIAlertController(title: "Warning", message: serviceError.description, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                return alert
            default:
                let alert = UIAlertController(title: "Error", message: serviceError.description, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                return alert
            }
        } else if let error = error as? CustomStringConvertible {
            let alert = UIAlertController(title: "Error", message: error.description, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            return alert
        }
        return nil
    }
}
