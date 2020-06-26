//
//  NumberListController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 20.07.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import HomeSecurityAPI
import RxSwift
import RxCocoa
import UIKit
import RxDataSources

class NumberListController: UIViewController, UITableViewDelegate, ErrorAlertConstructor, ErrorsHandler {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    var didPressUpdate: (Phone) -> () = { _ in }
    var didPressAddNumber: (Phone.Priority) -> () = { _ in }

    private var segmentedControl: UISegmentedControl!
    private var viewModel = NumberListModel()
    private let reuseIdentifier = "ReusableNumberCellIdentifier"
    private let disposeBag = DisposeBag()
    private let priorities = [Phone.Priority.Primary, Phone.Priority.Secondary]
    private let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<String, Phone>>()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .Plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.rx_tap.subscribeNext {
            self.didPressAddNumber(self.priorities[self.segmentedControl.selectedSegmentIndex])
        }.addDisposableTo(disposeBag)
        tableView.tableFooterView = UIView()
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: self.reuseIdentifier)
        tableView.backgroundColor = UIColor.paleGreyColor()
        view.backgroundColor = UIColor.paleGreyColor()
        let segment: UISegmentedControl = UISegmentedControl(items: priorities.map { priority in
            return NSLocalizedString("phone.priority." + priority.rawValue, comment: "")
        })
        segment.sizeToFit()
        segment.selectedSegmentIndex = 0
        navigationItem.titleView = segment
        segmentedControl = segment

        dataSource.configureCell = { ds, tableView, indexPath, phone in
            let cell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath)
            cell.textLabel?.text = phone.name ?? "no name"
            cell.detailTextLabel?.text = phone.priority.rawValue
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            return cell
        }

        dataSource.canEditRowAtIndexPath = { _ in
            return true
        }

        let phoneDeletedRx = self.tableView.rx_itemDeleted.asObservable().flatMap { indexPath in
            return self.viewModel.deletePhone(forIndexPath: indexPath)
        }.map { _ in
            return self.priorities[self.segmentedControl.selectedSegmentIndex]
        }
        let segmentSelectedRx = self.segmentedControl.rx_value.asObservable().map { selectedSegment in
            return self.priorities[selectedSegment]
        }
        let viewWillAppearRx = rx_sentMessage(#selector(viewWillAppear))
            .map { _ in
            return self.priorities[self.segmentedControl.selectedSegmentIndex]
        }
        let indicatorTrigger = Observable.of(segmentSelectedRx, viewWillAppearRx).merge()
        indicatorTrigger.asDriver(onErrorJustReturn: .Primary).map { _ in return true }.drive(activityIndicator.rx_animating).addDisposableTo(disposeBag)
        indicatorTrigger.asDriver(onErrorJustReturn: .Primary).map { _ in return true }.drive(tableView.rx_hidden).addDisposableTo(disposeBag)

        let reloadTableTrigger = Observable.of(indicatorTrigger, phoneDeletedRx)
            .merge()
            .flatMapLatest { priority -> Observable<NumberListModel> in
            return self.viewModel.updateNumbers(priority).catchError { error in
                self.handleError(error)
                return Observable.just(self.viewModel)
            }
        }.doOn(onNext: { model in
            self.viewModel = model
        }).share()
        reloadTableTrigger.map { $0.sections }
            .bindTo(tableView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
        reloadTableTrigger.asDriver(onErrorJustReturn: viewModel).map { _ in return false }.drive(activityIndicator.rx_animating).addDisposableTo(disposeBag)
        reloadTableTrigger.asDriver(onErrorJustReturn: viewModel).map { _ in return false }.drive(tableView.rx_hidden).addDisposableTo(disposeBag)

        let phoneSelectedRx = self.tableView.rx_itemSelected.asObservable()
        phoneSelectedRx
            .map { indexPath -> Phone in
            return self.viewModel.phone(forIndexPath: indexPath)
        }.bindNext { phone in
            self.didPressUpdate(phone)
        }.addDisposableTo(disposeBag)
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}
