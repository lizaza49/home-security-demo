//
//  MenuViewController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 27/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import UIKit

enum MenuItemType {
    case SensorsList
    case PhonesList
    case FamilyList
    case EventsList
    case LogOut
}

struct MenuItem {
    let actionType: MenuItemType
    let title: String
    let image: UIImage?
}

class MenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    weak var menuActionDelegate: MenuActionDelegate? = nil

    let reuseIdentifier = "ReusableCellIdentifier"
    let header = MenuHeader.instanceFromNib("MenuHeader")
    let menuItems = [
        MenuItem(actionType: .SensorsList, title: "Sensors", image: UIImage(named: "menu_sensors")),
        MenuItem(actionType: .PhonesList, title: "Phone numbers", image: UIImage(named: "menu_phones")),
        MenuItem(actionType: .FamilyList, title: "Family", image: UIImage(named: "menu_family")),
        MenuItem(actionType: .EventsList, title: "Events history", image: UIImage(named: "menu_events")),
        MenuItem(actionType: .LogOut, title: "Logout", image: nil),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.cornflowerColor()
        self.tableView.backgroundColor = UIColor.cornflowerColor()
        self.tableView.registerNib(UINib(nibName: "MenuCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: self.reuseIdentifier)
    }

    override func viewDidLayoutSubviews() {
        if let header = self.header {
            header.setNeedsLayout()
            header.layoutIfNeeded()
            let height = header.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height
            header.frame.size.height = height
            self.tableView.tableHeaderView = header
        }
        super.viewDidLayoutSubviews()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.reuseIdentifier, forIndexPath: indexPath) as! MenuCell
        cell.configureWithMenuItem(self.menuItems[indexPath.row])
        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.revealViewController().revealToggle(self)
        self.menuActionDelegate?.menuItemPressed(self.menuItems[indexPath.row].actionType)
    }
}
