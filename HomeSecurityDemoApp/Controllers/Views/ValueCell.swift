//
//  AddSensorCell.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 28.07.16.
//  Copyright © 2016 Ilya Myakotin. All rights reserved.
//

import Foundation
import UIKit

class ValueCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!

    var didChangeText: (String) -> () = { _ in }
    var didEndEditing: (String) -> () = { _ in }
    var didBeginEditing: () -> () = {}

    override func awakeFromNib() {
        super.awakeFromNib()
        self.textField.delegate = self
        textField.addTarget(self, action: #selector(valueChanged), forControlEvents: .EditingChanged)
    }

    func valueChanged() {
        if let editedText = textField.text {
            didChangeText(editedText)
        }
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        didBeginEditing()
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if let editedText = textField.text {
            didEndEditing(editedText)
        }
    }
}
