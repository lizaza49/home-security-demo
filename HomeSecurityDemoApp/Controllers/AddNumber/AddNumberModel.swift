//
//  AddNumberModel.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 29.08.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import HomeSecurityAPI
import RxCocoa
import RxDataSources
import Result

class AddNumberModel: ValidationProtocol {
    let disposeBag = DisposeBag()
    var viewType = PhoneEditingAction.Add
    var phone: Phone? {
        didSet {
            viewType = (phone != nil) ? PhoneEditingAction.Update : PhoneEditingAction.Add
            number.value.text = phone?.number ?? ""
            name.value.text = phone?.name ?? ""
        }
    }
    var priority: Phone.Priority? = nil
    var buttonText: String {
        return viewType == .Add ? "Add" : "Update"
    }
    var titleText: String {
        return viewType == .Add ? "Add phone" : "Edit phone"
    }
    var name = Variable<InputFieldData>(InputFieldData(fieldName: "Name", validate: {
        try InputFieldValidationFunctions.notEmpty("Name", $0)
    }))
    var number = Variable<InputFieldData>(InputFieldData(fieldName: "Number", validate: {
        try InputFieldValidationFunctions.notEmpty("Number", $0)
    }))

    func makeCells() -> Observable<[SectionModel<String, ValueCellData>]> {
        let cellName = ValueCellData(labelText: name.value.fieldName, placeholderText: "Enter Name", textFieldText: name.value.text, didEndEditing: { [weak self] in self?.name.value.text = $0 })
        let cellNumber = ValueCellData(labelText: number.value.fieldName, placeholderText: "Enter number", textFieldText: number.value.text, keyboardType: .PhonePad, didEndEditing: { [weak self] in self?.number.value.text = $0 })
        let newSections = [SectionModel(model: "", items: [cellName]), SectionModel(model: "", items: [cellNumber])]
        return Observable.just(newSections)
    }

    private func isValid() -> Observable<Result<Void, PhoneEditingError>> {
        let fields = [name.value, number.value]
        return validate(fields).map { _ in
            .Success()
        }.catchError {
            Observable.just(.Failure(PhoneEditingError.ValidationError($0)))
        }
    }

    func doCurrentAction() -> Observable<Result<Phone, PhoneEditingError>> {
        return self.isValid().flatMap { result -> Observable<Result<Phone, PhoneEditingError>> in
            switch result {
            case .Success():
                switch self.viewType {
                case .Add:
                    if let priority = self.priority {
                        return CospaceServices.phonesService.addPhone(self.number.value.text, priority: priority, name: self.name.value.text).map { .Success($0) }.catchError {
                            return Observable.just(.Failure(PhoneEditingError.APIError($0))) }
                    } else {
                        return Observable.just(.Failure(PhoneEditingError.AddPhoneError))
                    }
                case .Update:
                    if let phone = self.phone {
                        return CospaceServices.phonesService.updatePhone(phone, number: self.number.value.text, priority: phone.priority, name: self.name.value.text).map { .Success($0) }.catchError { Observable.just(.Failure(PhoneEditingError.APIError($0))) }
                    } else {
                        return Observable.just(.Failure(PhoneEditingError.UpdatePhoneError))
                    }
                }
            case .Failure(let error):
                return Observable.just(.Failure(error))
            }
        }
    }
}

enum PhoneEditingError: ErrorType, CustomStringConvertible {
    case UpdatePhoneError
    case AddPhoneError
    case APIError(ErrorType)
    case ValidationError(ErrorType)

    var description: String {
        switch self {
        case .UpdatePhoneError:
            return "There was an error updating the phone"
        case .AddPhoneError:
            return "There was an error adding the phone"
        case .ValidationError(let error):
            guard let error = error as? CustomStringConvertible else { return "Unknown error" }
            return error.description
        case .APIError(let error):
            guard let error = error as? CustomStringConvertible else { return "Unknown error" }
            return error.description
        }
    }
}

enum PhoneEditingAction {
    case Add
    case Update
}
