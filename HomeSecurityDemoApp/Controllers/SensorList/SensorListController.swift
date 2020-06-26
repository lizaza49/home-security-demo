//
//  TableViewController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 12.07.16.
//  Copyright © 2016 Admin. All rights reserved.
//
import UIKit
import Foundation
import HomeSecurityAPI
import Alamofire
import RxSwift
import Refresher
import RxCocoa
import RxDataSources

class SensorListController: UIViewController, UITableViewDelegate, ErrorAlertConstructor, ErrorsHandler {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var didSelectSensor: (String) -> () = { _ in }
    var didPressAdd: () -> () = {}
    var didPressUpdate: (Sensor) -> () = { _ in }

    private let editableDataSource = RxTableViewSectionedReloadDataSource<SectionOfCustomData>()
    private let reuseIdentifier = "ReusableCellIdentifier"
    private let disposeBag = DisposeBag()
    private lazy var placeholderView = { SensorsPlaceholderView.instanceFromNib("SensorsPlaceholderView") as! SensorsPlaceholderView }()
    private lazy var refreshLoadingView = { RefreshControl.instanceFromNib("RefreshControl") as! RefreshControl }()
    private var sensorViewModel = SensorListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "add"), style: .Plain, target: self, action: #selector(addKeyButtonPressed))
        let nib = UINib(nibName: "SensorCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        tableView.backgroundColor = UIColor.paleGreyColor()
        tableView.tableFooterView = UIView()
        view.backgroundColor = UIColor.paleGreyColor()
        placeholderView.frame = self.view.bounds
        placeholderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placeholderView)
        let leftConstraint = NSLayoutConstraint(item: placeholderView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: placeholderView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: placeholderView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: placeholderView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        [NSLayoutConstraint.activateConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])]
        placeholderView.hidden = true
        navigationItem.title = "Sensors"
        setUpDataSource(editableDataSource)
        let statusRx = sensorViewModel.networkStatusVariable.asObservable()
            .map { _ in
            return self.sensorViewModel.tableViewState
        }
        let sensorSelectedRx = tableView.rx_itemSelected
            .map { indexPath in
            return self.sensorViewModel.tableViewState.sensor(forIndexPath: indexPath)
        }.doOnNext { sensor in
            self.didPressUpdate(sensor)
        }
            .map { _ in
            return self.sensorViewModel.tableViewState
        }
        let sensorDeletedRx = self.tableView.rx_itemDeleted
            .flatMap { indexPath in
            return self.sensorViewModel.tableViewState.deleteSensor(forIndexPath: indexPath)
        }
        let viewWillAppearRx = rx_sentMessage(#selector(viewWillAppear))
            .map { _ in
            return self.sensorViewModel.tableViewState
        }
        let indicatorTrigger = viewWillAppearRx
        indicatorTrigger
            .asDriver(onErrorJustReturn: sensorViewModel.tableViewState)
            .map { _ in return true }
            .drive(activityIndicator.rx_animating)
            .addDisposableTo(disposeBag)

        indicatorTrigger
            .asDriver(onErrorJustReturn: sensorViewModel.tableViewState)
            .map { _ in return true }
            .drive(tableView.rx_hidden)
            .addDisposableTo(disposeBag)
        let refreshRx = tableView.rx_refresh(refreshLoadingView).map { return self.sensorViewModel.tableViewState }
        let reloadTableTrigger = Observable.of(refreshRx, indicatorTrigger, sensorDeletedRx, sensorSelectedRx, statusRx)
            .merge()
            .flatMapLatest { _ in
            return self.sensorViewModel.tableViewState.update().catchError { error in
                self.handleError(error)
                return Observable.just(self.sensorViewModel.tableViewState)
            }
        }.doOn(onNext: { state in
            self.sensorViewModel.tableViewState = state
            self.tableView.stopPullToRefresh()
        }).share()

        reloadTableTrigger
            .map { $0.sections }
            .bindTo(tableView.rx_itemsWithDataSource(editableDataSource))
            .addDisposableTo(disposeBag)

        reloadTableTrigger
            .asDriver(onErrorJustReturn: sensorViewModel.tableViewState)
            .map { _ in return false }
            .drive(activityIndicator.rx_animating)
            .addDisposableTo(disposeBag)

        reloadTableTrigger
            .asDriver(onErrorJustReturn: sensorViewModel.tableViewState)
            .map { state in
            let numberOfSensors = state.sections.reduce(0, combine: { $0 + $1.items.count })
            return numberOfSensors == 0
        }
            .drive(tableView.rx_hidden)
            .addDisposableTo(disposeBag)

        reloadTableTrigger
            .asDriver(onErrorJustReturn: sensorViewModel.tableViewState)
            .map { state in
            let numberOfSensors = state.sections.reduce(0, combine: { $0 + $1.items.count })
            return numberOfSensors > 0
        }
            .drive(placeholderView.rx_hidden)
            .addDisposableTo(disposeBag)
    }

    func setUpDataSource(dataSource: RxTableViewSectionedReloadDataSource<SectionOfCustomData>) {
        dataSource.configureCell = { ds, tv, ip, item in
            let cell: SensorCell = tv.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: ip) as! SensorCell
            cell.label.text = item.description
            cell.labelForType.text = NSLocalizedString("sensor.purpose." + item.purpose.rawValue, comment: "")
            let status = self.sensorViewModel.networkStatusVariable.value
            switch status {
            case .NotReachable, .Unknown:
                cell.imageStatus.image = UIImage(named: "sensor_unknown")
            default:
                if let sensorState = item.state {
                    cell.imageStatus.image = UIImage(named: sensorState.isOpen ? "sensor_open" : "sensor_closed")
                }
            }
            cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            return cell
        }
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].header
        }
        dataSource.canEditRowAtIndexPath = { _ in
            return true
        }
    }

    func addKeyButtonPressed() {
        didPressAdd()
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
}

extension UIScrollView {
    func rx_refresh<T: UIView where T: PullToRefreshViewDelegate>(animator: T) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            MainScheduler.ensureExecutingOnScheduler()
            guard let weakSelf = self else {
                observer.onCompleted()
                return NopDisposable.instance
            }
            weakSelf.addPullToRefreshWithAction({ observer.onNext() }, withAnimator: animator)
            return AnonymousDisposable {
                weakSelf.stopPullToRefresh()
            }
        }
    }
}
