//
//  RegistrationViewModel.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 01.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import RxSwift
import HomeSecurityAPI
import RxCocoa
import RxDataSources
import Result

class RegistrationViewModel: ValidationProtocol {

    let disposeBag = DisposeBag()
    var email = Variable<InputFieldData>(InputFieldData(fieldName: "Email", validate: {
        try InputFieldValidationFunctions.notEmpty("Email", $0)
    }))
    var username = Variable<InputFieldData>(InputFieldData(fieldName: "Username", validate: {
        try InputFieldValidationFunctions.notEmpty("Username", $0)
        try InputFieldValidationFunctions.isInLengthRange("Username", $0, 2, 20)
        try InputFieldValidationFunctions.containsOnlyNumbersAndLetters("Username", $0)
    }))
    var password = Variable<InputFieldData>(InputFieldData(fieldName: "Password", validate: {
        try InputFieldValidationFunctions.notEmpty("Password", $0)
        try InputFieldValidationFunctions.isInLengthRange("Password", $0, 5, 50)
    }))

    var firstname = Variable<InputFieldData>(InputFieldData(fieldName: "First name", validate: {
        try InputFieldValidationFunctions.notEmpty("First name", $0)
        try InputFieldValidationFunctions.isInLengthRange("First name", $0, 1, 50)
    }))
    var lastname = Variable<InputFieldData>(InputFieldData(fieldName: "Last name", validate: {
        try InputFieldValidationFunctions.notEmpty("Last name", $0)
        try InputFieldValidationFunctions.isInLengthRange("Last name", $0, 1, 50)
    }))

    func makeCells() -> Observable<[SectionModel<String, ValueCellData>]> {
        let emailCellData = ValueCellData(labelText: email.value.fieldName, textFieldText: email.value.text, placeholderText: "Enter email", keyboardType: .EmailAddress, didEndEditing: { [weak self] in self?.email.value.text = $0 })

        let usernameCellData = ValueCellData(labelText: username.value.fieldName, textFieldText: username.value.text, placeholderText: "Enter username", didEndEditing: { [weak self] in self?.username.value.text = $0 })

        let passwordCellData = ValueCellData(labelText: password.value.fieldName, textFieldText: password.value.text, placeholderText: "Enter password", didEndEditing: { [weak self] in self?.password.value.text = $0 })

        let firstNameCellData = ValueCellData(labelText: firstname.value.fieldName, textFieldText: firstname.value.text, placeholderText: "Enter first name", didEndEditing: { [weak self] in self?.firstname.value.text = $0 })

        let lastNameCellData = ValueCellData(labelText: lastname.value.fieldName, textFieldText: lastname.value.text, placeholderText: "Enter last name", didEndEditing: { [weak self] in self?.lastname.value.text = $0 })

        let sections = [SectionModel(model: "", items: [emailCellData]),
            SectionModel(model: "", items: [usernameCellData]),
            SectionModel(model: "", items: [passwordCellData]),
            SectionModel(model: "", items: [firstNameCellData]),
            SectionModel(model: "", items: [lastNameCellData])]
        return Observable.just(sections)
    }

    private func isValid() -> Observable<Result<Void, RegistrationError>> {
        let fields = [email.value, username.value, password.value, firstname.value, lastname.value]
        return validate(fields).map { _ in
            return .Success()
        }.catchError { error in
            return Observable.just(.Failure(RegistrationError.ValidationError(error))) }
    }

    func registrNewUser() -> Observable<Result<Void, RegistrationError>> {
        return self.isValid().flatMap { result -> Observable<Result<Void, RegistrationError>> in
            switch result {
            case .Success():
                return CospaceServices.authService.register(email: self.email.value.text,
                    username: self.username.value.text,
                    password: self.password.value.text,
                    firstname: self.firstname.value.text,
                    lastname: self.lastname.value.text)
                    .doOnNext {_ in LocationService.sharedService.start() }.map { _ in .Success() }
                    .catchError { Observable.just(.Failure(RegistrationError.APIError($0))) }
            case .Failure(_):
                return Observable.just(result)
            }
        }
    }
}

enum RegistrationError: ErrorType, CustomStringConvertible {
    case ValidationError(ErrorType)
    case APIError(ErrorType)

    var description: String {
        switch self {
        case .ValidationError(let error):
            guard let error = error as? CustomStringConvertible else { return "Unknown error" }
            return error.description
        case .APIError(let error):
            guard let error = error as? CustomStringConvertible else { return "Unknown error" }
            return error.description
        }
    }
}
