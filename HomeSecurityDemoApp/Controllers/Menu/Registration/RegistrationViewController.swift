//
//  RegistrationViewController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 08.08.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import HomeSecurityAPI
import RxSwift
import RxCocoa
import RxDataSources
import Result

class RegistrationViewController: UIViewController, UITextInputTraits, UITableViewDelegate, ErrorsHandler, ErrorAlertConstructor {

    @IBOutlet weak var tableView: UITableView!
    private let footer = TableFooter.instanceFromNib("TableFooter") as! TableFooter
    var currentPath: NSIndexPath? = nil
    var didRegister: () -> () = {}
    let reuseIdentifier = "ReusableCellIdentifier"
    let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, ValueCellData>>()
    var viewModel = RegistrationViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        self.navigationItem.setHidesBackButton(false, animated: true)
        self.view.backgroundColor = UIColor.paleGreyColor()
        self.tableView.backgroundColor = UIColor.paleGreyColor()
        self.tableView.tableFooterView = self.footer
        self.tableView.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        let nib = UINib(nibName: "ValueCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        dataSource.configureCell = { ds, tableView, indexPath, item in
            let cell: ValueCell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! ValueCell
            cell.label.text = item.labelText
            cell.textField.placeholder = item.placeholderText
            cell.textField.text = item.textFieldText
            cell.didChangeText = item.didChangeText
            cell.didEndEditing = item.didEndEditing
            cell.textField.keyboardType = item.keyboardType

            if indexPath.section == 2 {
                cell.textField.secureTextEntry = true
            }

            cell.didBeginEditing = {
                self.currentPath = indexPath
            }
            return cell
        }

        dataSource.canEditRowAtIndexPath = { _ in
            return self.editing
        }

        let reloadTrigger = Observable.of(viewModel.email.asObservable(),
            viewModel.username.asObservable(),
            viewModel.password.asObservable(),
            viewModel.firstname.asObservable(),
            viewModel.lastname.asObservable()).merge().flatMap { _ in
            self.viewModel.makeCells()
        }.share()
        reloadTrigger.bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        self.footer.button.setTitle("Register", forState: .Normal)

        footer.button.rx_tap.flatMap {
            self.viewModel.registrNewUser()
        }.doOnNext { result in
            switch result {
            case .Success():
                return self.didRegister()
            case .Failure(let error):
                return self.handleError(error)
            }
        }.subscribe().addDisposableTo(disposeBag)
    }

    override func viewDidDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
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

    override var navigationBarTintColor: UIColor {
        return UIColor.clearColor()
    }

    override var navigationItemTintColor: UIColor {
        return UIColor.cornflowerColor()
    }

    override var navigationTranslucent: Bool {
        return true
    }

    override var navigationBarStyle: UIBarStyle {
        return UIBarStyle.Default
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }

    override func viewWillDisappear(animated: Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        self.view.endEditing(true)
        super.viewWillDisappear(animated)
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
        }, completion: { _ in
            if let path = self.currentPath {
                self.tableView.scrollToRowAtIndexPath(path, atScrollPosition: .Middle, animated: true)
            }
        })
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}
