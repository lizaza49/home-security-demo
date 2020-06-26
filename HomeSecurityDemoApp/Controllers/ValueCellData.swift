//
//  ValueCellData.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 31.08.16.
//  Copyright © 2016 Ilya Myakotin. All rights reserved.
//

import Foundation

struct ValueCellData {
    let labelText: String?
    let placeholderText: String?
    let textFieldText: String?
    let keyboardType: UIKeyboardType
    let didChangeText: (String) -> ()
    let didEndEditing: (String) -> ()

    init(labelText: String? = nil, placeholderText: String? = nil, textFieldText: String? = nil, keyboardType: UIKeyboardType = .Default, didChangeText: (String) -> () = { _ in }, didEndEditing: (String) -> () = { _ in }) {
        self.labelText = labelText
        self.placeholderText = placeholderText
        self.textFieldText = textFieldText
        self.keyboardType = keyboardType
        self.didChangeText = didChangeText
        self.didEndEditing = didEndEditing
    }
}

struct SensorTypeCellData {
    let labelText: String
    let labelTypeText: String
    init(labelText: String = "", labelTypeText: String = "") {
        self.labelText = labelText
        self.labelTypeText = labelTypeText
    }
}
