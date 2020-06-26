//
//  InputFieldData.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 02.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation

struct InputFieldData {
    var text: String
    let fieldName: String
    let validate: (String) throws -> ()

    init(text: String = "", fieldName: String = "", validate: (String) throws -> () = { _ in }) {
        self.fieldName = fieldName
        self.text = text
        self.validate = validate
    }
}

struct InputFieldValidationFunctions {
    static let notEmpty: (String, String) throws -> () = { name, text in
        if text.isEmpty {
            throw ValidationError.Empty(name)
        }
    }

    static let isInLengthRange: (String, String, Int, Int) throws -> () = { name, text, min, max in
        if (text.characters.count > min) && (text.characters.count < max) { return } else if (text.characters.count < min) { throw ValidationError.TooShort(name, min) } else if (text.characters.count > max) { throw ValidationError.TooLong(name, max) }
    }

    static let containsOnlyNumbersAndLetters: (String, String) throws -> () = { name, text in
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9]*$", options: [.CaseInsensitive])
        if regex.firstMatchInString(text, options: [], range: NSMakeRange(0, text.characters.count)) == nil {
            throw ValidationError.CanContainLettersAndNumbersOnly(name)
        }
        return
    }
}
