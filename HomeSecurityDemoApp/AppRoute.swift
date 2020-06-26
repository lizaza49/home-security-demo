//
//  AppRouteClass.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 15.07.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit
import HomeSecurityAPI
import RxSwift

protocol MenuActionDelegate: class {
    func menuItemPressed(itemType: MenuItemType)
}

final class AppRoute: MenuActionDelegate {
    let window: UIWindow
    let navigationController: UINavigationController
    let menuNavigationController: UINavigationController
    let disposeBag = DisposeBag()

    var sensorsListController: SensorListController {
        let sensorsListController = SensorListController()
        sensorsListController.didPressUpdate = showUpdateSensorController
        sensorsListController.didPressAdd = showAddSensorController
        return sensorsListController
    }

    var phonesListController: NumberListController {
        let numsListController = NumberListController()
        numsListController.didPressUpdate = showUpdateNumberController
        numsListController.didPressAddNumber = showAddNumberController
        return numsListController
    }

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        self.menuNavigationController = UINavigationController()
        window.rootViewController = self.navigationController
    }

    func menuItemPressed(itemType: MenuItemType) {
        switch itemType {
        case .SensorsList:
            showSensorsList()
        case .PhonesList:
            menuNavigationController.pushViewController(phonesListController, animated: true)
        case .FamilyList:
            showMembersList()
        case .EventsList:
            menuNavigationController.pushViewController(EventsHistoryController(), animated: true)
        case .LogOut:
            CospaceServices.authService.logout().subscribe(onNext: { LocationService.sharedService.stop() } ).addDisposableTo(disposeBag)
            navigationController.popToRootViewControllerAnimated(false)
        }
    }

    func showMainScreen() {
        let controller = MainViewController()
        controller.didPressSensorsList = showSensorsList
        controller.didPressMembersList = showMembersList
        let menu = MenuViewController()
        menu.menuActionDelegate = self
        menuNavigationController.pushViewController(controller, animated: false)
        let drawer = SWRevealViewController(rearViewController: menu, frontViewController: menuNavigationController)
        navigationController.pushViewController(drawer, animated: false)
    }

    func showSensorsList() {
        menuNavigationController.pushViewController(sensorsListController, animated: true)
    }

    func showMembersList() {
        menuNavigationController.pushViewController(FamilyMembersController(), animated: true)
    }

    func showAddSensorController() {
        let sensorVC = AddSensorController()
        sensorVC.didTapSelectSensorType = self.showValueSelectionController
        sensorVC.didSelectSensorType = self.dismissSelectionController
        sensorVC.didUpdateSensor = self.dismissSensorController
        sensorVC.didPressQRCapture = self.showQRCaptureController
        sensorVC.didCompleteCapture = self.dismissQRCaptureController
        self.menuNavigationController.pushViewController(sensorVC, animated: true)
    }

    func dismissSelectionController() {
        self.menuNavigationController.visibleViewController!.dismissViewControllerAnimated(true, completion: nil)
    }

    func showValueSelectionController(delegate: SelectionTableViewControllerDelegate, values: [String]) {
        let selectionVC = SelectionTableViewController()
        selectionVC.cellsValues = values
        selectionVC.selectionDelegate = delegate
        selectionVC.didTapClose = self.dismissSelectionController
        let navigation = UINavigationController.init(rootViewController: selectionVC)
        self.menuNavigationController.visibleViewController!.presentViewController(navigation, animated: true, completion: nil)
    }

    func showAddNumberController(priority: Phone.Priority) {
        let addNumberController = AddNumberController()
        addNumberController.didPressUpdate = self.dismissNumberController
        let viewModel = AddNumberModel()
        viewModel.priority = priority
        addNumberController.viewModel = viewModel
        self.menuNavigationController.pushViewController(addNumberController, animated: true)
    }

    func showAuthController() {
        let authView = AuthController()
        authView.didPressAuth = showMainScreen
        authView.didPressRegister = showRegistrationController
        self.navigationController.pushViewController(authView, animated: true)
    }

    func showRegistrationController() -> () {
        let regView = RegistrationViewController()
        regView.didRegister = showMainScreen
        navigationController.pushViewController(regView, animated: true)
    }

    func dismissSensorController() -> () {
        self.menuNavigationController.popViewControllerAnimated(true)
    }

    func dismissNumberController() {
        self.menuNavigationController.popViewControllerAnimated(true)
    }

    func showUpdateSensorController(sensor: Sensor) {
        let sensorVC = AddSensorController()
        sensorVC.viewModel.sensor = sensor
        sensorVC.didTapSelectSensorType = self.showValueSelectionController
        sensorVC.didSelectSensorType = self.dismissSelectionController
        sensorVC.didUpdateSensor = self.dismissSensorController
        sensorVC.didPressQRCapture = self.showQRCaptureController
        sensorVC.didCompleteCapture = self.dismissQRCaptureController
        self.menuNavigationController.pushViewController(sensorVC, animated: true)
    }

    func showUpdateNumberController(phoneNumber: Phone) {
        let phoneUpdate = AddNumberController()
        let viewModel = AddNumberModel()
        viewModel.phone = phoneNumber
        phoneUpdate.viewModel = viewModel
        phoneUpdate.didPressUpdate = self.dismissNumberController
        self.menuNavigationController.pushViewController(phoneUpdate, animated: true)
    }

    func showQRCaptureController(delegate: QRCaptureDelegate, needAnimation: Bool) {
        let captureController = QRCaptureViewController()
        captureController.delegate = delegate
        self.menuNavigationController.topViewController?.presentViewController(captureController, animated: needAnimation, completion: nil)
    }

    func dismissQRCaptureController() {
        self.menuNavigationController.topViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
