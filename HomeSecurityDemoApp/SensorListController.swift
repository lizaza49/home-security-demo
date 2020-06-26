//
//  TableViewController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 12.07.16.
//  Copyright © 2016 Admin. All rights reserved.
//
import UIKit

class SensorListController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    let text = "HEY"
    let countRow = 15

    var didSelectSensor: (String) -> () = { _ in }
    var didPressAdd: () -> () = {}

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = false
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Add", style: .Plain, target: self, action: #selector(addButtonPressed))
    }

    func addButtonPressed() {
        self.didPressAdd()
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return countRow
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestSwiftCell")
        cell.textLabel?.text = "\(text) \(indexPath.row)"
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
