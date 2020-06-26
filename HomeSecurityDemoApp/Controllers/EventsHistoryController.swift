//
//  EventsHistoryController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 13/09/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import HomeSecurityAPI
import RxSwift

final class EventsHistoryController: UIViewController, UITableViewDelegate, UITableViewDataSource, ErrorAlertConstructor, ErrorsHandler {

    private var tableView: UITableView!
    private let reuseIdentifier = "ReusableCellIdentifier"
    private var refreshLoadingView: RefreshControl!
    private var events: [(date: NSDate, events: [HomeSecurityAPI.Event])] = []
    private var shouldAllowLoadMore: Bool = true
    private var loadMoreInprocess: Bool = false
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Events history"
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        let leftConstraint = NSLayoutConstraint(item: tableView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: tableView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: tableView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: tableView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        [NSLayoutConstraint.activateConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])]

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        let nib = UINib(nibName: "EventCell", bundle: NSBundle.mainBundle())
        tableView.registerNib(nib, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
        setUpRefreshControl()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        CospaceServices.eventsService.getEvents().subscribe(onNext: gotEvents, onError: handleError).addDisposableTo(disposeBag)
    }

    func setUpRefreshControl() {
        refreshLoadingView = RefreshControl.instanceFromNib("RefreshControl") as! RefreshControl
        tableView.addPullToRefreshWithAction({
            CospaceServices.eventsService.getEvents().subscribe(onNext: self.gotEvents, onError: self.handleError).addDisposableTo(self.disposeBag)
        }, withAnimator: refreshLoadingView)
    }

    func loadMoreEvents() {
        let pair = self.events.last
        if let lastEvent = pair?.events.last where !self.loadMoreInprocess {
            self.loadMoreInprocess = true
            CospaceServices.eventsService.getEvents(startingWith: lastEvent).subscribe(onNext: { events in
                let count = events.reduce(0) { $0 + $1.events.count }
                self.shouldAllowLoadMore = count >= CospaceServices.eventsService.eventsPageSize
                self.loadMoreInprocess = false
                self.mergeEvents(events)
            }, onError: { error in
                self.handleError(error)
                self.loadMoreInprocess = false
            }).addDisposableTo(self.disposeBag)
        }
    }

    func gotEvents(eventsMas: [(date: NSDate, events: [HomeSecurityAPI.Event])]) {
        events = eventsMas
        let count = eventsMas.reduce(0) { $0 + $1.events.count }
        shouldAllowLoadMore = count >= CospaceServices.eventsService.eventsPageSize
        tableView.reloadData()
        tableView.stopPullToRefresh()
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section >= events.count { return 0 }
        return events[section].events.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let eventCell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! EventCell
        let dateFormatter = NSDateFormatter()
        dateFormatter.timeStyle = .ShortStyle
        eventCell.eventTime.text = dateFormatter.stringFromDate(events[indexPath.section].events[indexPath.row].time)
        eventCell.eventTitle.text = events[indexPath.section].events[indexPath.row].description
        eventCell.eventIcon.image = events[indexPath.section].events[indexPath.row].type.icon
        return eventCell
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return events.count + (shouldAllowLoadMore ? 1 : 0)
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section >= events.count {
            let headerView = LoadMoreSection.instanceFromNib("LoadMoreSection") as! LoadMoreSection
            headerView.didPressMoreButton = {
                self.loadMoreEvents()
            }
            return headerView
        } else {
            let headerView = DateSection.instanceFromNib("DateSection") as! DateSection
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            dateFormatter.doesRelativeDateFormatting = true
            headerView.dateLabel.text = dateFormatter.stringFromDate(events[section].date)
            return headerView
        }
    }

    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func mergeEvents(newEvents: [(date: NSDate, events: [HomeSecurityAPI.Event])]) {
        for pair in newEvents {
            if let index = events.indexOf({ obj in
                obj.date.compare(pair.date) == .OrderedSame
            }) {
                var events = self.events[index].events
                events.appendContentsOf(pair.events)
                self.events[index] = (date: pair.date, events: events)
            } else {
                events.append(pair)
            }
        }
        self.tableView.reloadData()
    }
}

extension HomeSecurityAPI.Event.EventType {
    var icon: UIImage? {
        switch self {
        case .SecuredOff:
            return UIImage(named: "events_sec_off")
        case .SecuredOn:
            return UIImage(named: "events_sec_on")
        default:
            return UIImage(named: "events_error")
        }
    }
}
