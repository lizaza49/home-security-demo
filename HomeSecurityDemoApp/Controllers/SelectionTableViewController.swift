//
//  SelectionTableViewController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 29/07/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit

protocol SelectionTableViewControllerDelegate {
    func didSelect(path: NSIndexPath) -> ()
}

final class SelectionTableViewController: UITableViewController {

    var cellsValues: [String] = []
    var selectionDelegate: SelectionTableViewControllerDelegate? = nil
    var didTapClose: () -> () = {}

    private let reuseIdentifier = "selectionCell"

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let delegate = self.selectionDelegate {
            delegate.didSelect(indexPath)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "Close", style: .Plain, target: self, action: #selector(closeButtonPressed))
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellsValues.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = cellsValues[indexPath.row]
        return cell
    }

    func closeButtonPressed() {
        self.didTapClose()
    }
}
