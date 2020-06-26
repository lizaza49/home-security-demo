//
//  SecondScreenController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 13.07.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit
import HomeSecurityAPI
import RxSwift
import RxDataSources
import RxCocoa
import Result

class AddSensorController: UIViewController, UITableViewDelegate, SelectionTableViewControllerDelegate, QRCaptureDelegate, ErrorAlertConstructor, ErrorsHandler {
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    private let disposeBag = DisposeBag()
    private let footer = TableFooter.instanceFromNib("TableFooter") as! TableFooter
    private let reuseTypeIdentifier = "ReusableTypeCellIdentifier"
    private let reuseCodeIdentifier = "ReusableCodeCellIdentifier"
    private let reuseNameIdentifier = "ReusableNameCellIdentifier"
    let pickerHeadlines = [NSLocalizedString("sensor.purpose." + Sensor.Purpose.Window.rawValue, comment: ""), NSLocalizedString("sensor.purpose." + Sensor.Purpose.Door.rawValue, comment: "")]
    let pickerPurposes = [Sensor.Purpose.Window, Sensor.Purpose.Door]

    // Action handlers
    var didTapSelectSensorType: (SelectionTableViewControllerDelegate, [String]) -> () = { _ in }
    var didSelectSensorType: () -> () = {}
    var didUpdateSensor: () -> () = {}
    var didPressQRCapture: (QRCaptureDelegate, Bool) -> () = { _ in }
    var didCompleteCapture: () -> () = {}
    var currentPath: NSIndexPath? {
        didSet {
            if let path = currentPath {
                tableView.scrollToRowAtIndexPath(path, atScrollPosition: .Middle, animated: true)
            }
        }
    }
    var viewModel = AddSensorViewModel()
    let dataSource = RxTableViewSectionedReloadDataSource<MultipleSensorAddingSectionModel>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.paleGreyColor()
        navigationController?.navigationBarHidden = false
        tableView.tableFooterView = self.footer
        tableView.backgroundColor = UIColor.paleGreyColor()
        setUpDataSource()
        let nibSelection = UINib(nibName: "SelectionCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(nibSelection, forCellReuseIdentifier: reuseTypeIdentifier)
        let nibCode = UINib(nibName: "CodeValueCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(nibCode, forCellReuseIdentifier: reuseCodeIdentifier)
        let nibValue = UINib(nibName: "ValueCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(nibValue, forCellReuseIdentifier: reuseNameIdentifier)

        let purposeTrigger = viewModel.purpose.asObservable()
            .flatMap { _ in
            return self.viewModel.makeCells()
        }
        let inputObservable = Observable.of(viewModel.name.asObservable(), viewModel.code.asObservable()).merge().flatMap { _ in
            return self.viewModel.makeCells()
        }
        Observable.of(purposeTrigger, inputObservable)
            .merge()
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)

        footer.button.rx_tap.asObservable()
            .doOnNext { _ in
            self.view.endEditing(true)
            self.view.userInteractionEnabled = false
        }.flatMap { _ in
            self.viewModel.doCurrentAction()
        }.doOnNext { result in
            switch result {
            case .Success(let sensor):
                self.actionIsDone(sensor)
                break
            case .Failure(let error):
                self.errorHappened(error)
                break
            }
        }.subscribe().addDisposableTo(disposeBag)

        footer.button.setTitle(viewModel.buttonText, forState: .Normal)
        navigationItem.title = viewModel.titleText

        if viewModel.sensor == nil {
            didPressQRCapture(self, false)
        }
    }

    func setUpDataSource() {
        dataSource.configureCell = { ds, tableView, indexPath, cellItem in
            switch ds.itemAtIndexPath(indexPath) {
            case .SelectionCellItem(let data):
                let typeCell = tableView.dequeueReusableCellWithIdentifier(self.reuseTypeIdentifier, forIndexPath: indexPath) as! SelectionCell
                typeCell.typeOfLabel.text = data.labelText
                typeCell.sensorsTypeLabel.text = data.labelTypeText
                typeCell.didTapCell = { [weak self] in
                    guard let weakSelf = self else { return }
                    weakSelf.didTapSelectSensorType(weakSelf, weakSelf.pickerHeadlines)
                }
                typeCell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                return typeCell

            case .CodeValueCellItem(let data):
                let codeCell = tableView.dequeueReusableCellWithIdentifier(self.reuseCodeIdentifier, forIndexPath: indexPath) as! CodeValueCell
                codeCell.label.text = data.labelText
                codeCell.textField.placeholder = data.placeholderText
                codeCell.textField.text = data.textFieldText
                codeCell.qrScanPressed = { [weak self] in
                    guard let weakSelf = self else { return }
                    weakSelf.didPressQRCapture(weakSelf, true) }
                codeCell.didChangeText = data.didChangeText
                codeCell.didEndEditing = data.didEndEditing
                return codeCell

            case .NameCellItem(let data):
                let nameCell = tableView.dequeueReusableCellWithIdentifier(self.reuseNameIdentifier, forIndexPath: indexPath) as! ValueCell
                nameCell.label.text = data.labelText
                nameCell.textField.placeholder = data.placeholderText
                nameCell.textField.text = data.textFieldText
                nameCell.didChangeText = data.didChangeText
                nameCell.didEndEditing = data.didEndEditing
                return nameCell
            }
        }
        dataSource.canEditRowAtIndexPath = { _ in
            return false
        }
    }

    func didSelect(path: NSIndexPath) -> () {
        didSelectSensorType()
        viewModel.purpose.value = pickerPurposes[path.row]
    }

    func didCapture(text: String) {
    func didCapture(text: String) {
        viewModel.code.value.text = text
        didCompleteCapture()
    }

    func didCancelCapture() {
        didCompleteCapture()
    }

    override func viewDidLayoutSubviews() {
        if let footerView = self.tableView.tableFooterView {
            let height = footerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            var footerFrame = footerView.frame
            if height != footerFrame.size.height {
                footerFrame.size.height = height
                footerView.frame = footerFrame
                tableView.tableFooterView = footerView
            }
        }
        super.viewDidLayoutSubviews()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        super.viewWillDisappear(true)
    }

    func actionIsDone(sensor: Sensor) {
        view.userInteractionEnabled = true
        didUpdateSensor()
    }

    func errorHappened(error: ErrorType) {
        handleError(error)
        view.userInteractionEnabled = true
    }

    func keyboardWillChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let keyboardBeginSizeValue = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue,
            let keyboardEndSizeValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval else { return }
        let end = keyboardEndSizeValue.CGRectValue().origin.y
        let begin = keyboardBeginSizeValue.CGRectValue().origin.y
        view.layoutIfNeeded()
        UIView.animateWithDuration(animationDurarion, animations: {
            self.tableView.contentInset.bottom -= (end - begin)
            self.tableView.scrollIndicatorInsets.bottom -= (end - begin)
            self.view.layoutIfNeeded()
        }, completion: { _ in
            if let path = self.currentPath {
                self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: .Middle, animated: true)
            }
        })
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        tableView.resignFirstResponder()
    }
}
