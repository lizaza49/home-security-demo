//
//  AddNumberController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 20.07.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit
import HomeSecurityAPI
import RxSwift
import RxCocoa
import RxDataSources

class AddNumberController: UIViewController, UITableViewDelegate, ErrorAlertConstructor, ErrorsHandler {

    @IBOutlet weak var tableView: UITableView!

    var didPressUpdate: () -> () = {}
    var viewModel = AddNumberModel()

    private let footer = TableFooter.instanceFromNib("TableFooter") as! TableFooter
    private var currentPath: NSIndexPath?
    private let reuseIdentifier = "ReusableCellIdentifier"
    private let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, ValueCellData>>()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = false
        tableView.backgroundColor = UIColor.paleGreyColor()
        view.backgroundColor = UIColor.paleGreyColor()
        tableView.tableFooterView = self.footer
        let nib = UINib(nibName: "ValueCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        footer.button.rx_tap.doOnNext {
            self.view.endEditing(true)
            self.view.userInteractionEnabled = false
        }.flatMap { _ in
            self.viewModel.doCurrentAction()
        }.doOnNext { result in
            switch result {
            case .Success(let phone):
                self.phoneAdded(phone)
                break
            case .Failure(let error):
                self.errorAddingPhone(error)
                break
            }
        }.subscribe().addDisposableTo(disposeBag)

        dataSource.configureCell = { ds, tableView, indexPath, item in
            let cell: ValueCell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! ValueCell
            cell.label.text = item.labelText
            cell.textField.text = item.textFieldText
            cell.textField.placeholder = item.placeholderText
            cell.didChangeText = item.didChangeText
            cell.didEndEditing = item.didEndEditing
            cell.textField.keyboardType = item.keyboardType
            cell.didBeginEditing = {
                self.currentPath = indexPath
            }
            return cell
        }

        dataSource.canEditRowAtIndexPath = { _ in
            return self.editing
        }
        let reloadTrigger = Observable.of(viewModel.name.asObservable(),
            viewModel.number.asObservable()).merge().flatMap { _ in
            self.viewModel.makeCells()
        }.share()
        reloadTrigger.bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)

        footer.button.setTitle(viewModel.buttonText, forState: .Normal)
        navigationItem.title = viewModel.titleText
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        super.viewWillDisappear(animated)
    }

    override func viewDidLayoutSubviews() {
        if let footerView = self.tableView.tableFooterView {
            let height = footerView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            var footerFrame = footerView.frame
            if height != footerFrame.size.height {
                footerFrame.size.height = height
                footerView.frame = footerFrame
                self.tableView.tableFooterView = footerView
            }
        }
        super.viewDidLayoutSubviews()
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
            self.tableView.contentInset.bottom -= (end - begin)
            self.tableView.scrollIndicatorInsets.bottom -= (end - begin)
            self.view.layoutIfNeeded()
        }, completion: { completed in
            if let path = self.currentPath where completed {
                self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: .Bottom, animated: true)
            }
        })
    }

    func phoneAdded(phone: Phone) {
        view.userInteractionEnabled = true
        didPressUpdate()
    }

    func errorAddingPhone(error: ErrorType) {
        view.userInteractionEnabled = true
        handleError(error)
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}
