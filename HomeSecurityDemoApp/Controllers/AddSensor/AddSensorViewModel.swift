//
//  AddSensorViewModel.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 31.08.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import HomeSecurityAPI
import RxCocoa
import RxDataSources
import Result

class AddSensorViewModel: ValidationProtocol {
    var sections = Variable<[MultipleSensorAddingSectionModel]>([])
    var purpose = Variable<Sensor.Purpose>(.Window)
    var code = Variable<InputFieldData>(InputFieldData(fieldName: "Code", validate: {
        try InputFieldValidationFunctions.notEmpty("Code", $0)
    }))
    var name = Variable<InputFieldData>(InputFieldData(fieldName: "Name", validate: {
        try InputFieldValidationFunctions.notEmpty("Name", $0)
    }))
    let disposeBag = DisposeBag()
    var viewType = SensorEditingAction.Add
    var sensor: Sensor? {
        didSet {
            viewType = (sensor != nil) ? SensorEditingAction.Update : SensorEditingAction.Add
            name.value.text = sensor?.description ?? ""
        }
    }
    var buttonText: String {
        return viewType == .Add ? "Add" : "Update"
    }
    var titleText: String {
        return viewType == .Add ? "Add sensor" : "Edit sensor"
    }

    func makeCells() -> Observable<[MultipleSensorAddingSectionModel]> {
        let cellName = ValueCellData(labelText: name.value.fieldName, placeholderText: "Enter name", textFieldText: name.value.text, didEndEditing: { [weak self] in self?.name.value.text = $0 })
        let cellCode = ValueCellData(labelText: code.value.fieldName, placeholderText: "Enter code", textFieldText: code.value.text, didEndEditing: { [weak self] in self?.code.value.text = $0 })
        let cellType = SensorTypeCellData(labelText: "Sensor Type", labelTypeText: NSLocalizedString("sensor.purpose." + self.purpose.value.rawValue, comment: ""))
        let newSections: [MultipleSensorAddingSectionModel]
        switch viewType {
        case .Update:
            newSections = [MultipleSensorAddingSectionModel.SelectionCellSection(title: "", items: [SectionItem.SelectionCellItem(data: cellType)]), MultipleSensorAddingSectionModel.NameCellSection(title: "", items: [SectionItem.NameCellItem(data: cellName)])]
        case .Add:
            newSections = [MultipleSensorAddingSectionModel.SelectionCellSection(title: "", items: [SectionItem.SelectionCellItem(data: cellType)]),
                MultipleSensorAddingSectionModel.CodeValueCellSection(title: "", items: [SectionItem.CodeValueCellItem(data: cellCode)]),
                MultipleSensorAddingSectionModel.NameCellSection(title: "", items: [SectionItem.NameCellItem(data: cellName)])]
        }
        return Observable.just(newSections)
    }

    private func isValid() -> Observable<Result<Void, SensorEditingActionError>> {
        let fields: [InputFieldData]
        switch self.viewType {
        case .Add:
            fields = [code.value, name.value]
        case .Update:
            fields = [name.value]
        }
        return validate(fields).map { _ in .Success() }.catchError { error in
            return Observable.just(.Failure(SensorEditingActionError.ValidationError(error))) }
    }

    func doCurrentAction() -> Observable<Result<Sensor, SensorEditingActionError>> {
        return self.isValid()
            .flatMap { result -> Observable<Result<Sensor, SensorEditingActionError>> in
            switch result {
            case .Success():
                switch self.viewType {
                case .Add:
                    return CospaceServices.sensorsService.createSensor(code: self.code.value.text, purpose: self.purpose.value, description: self.name.value.text).map {
                        .Success($0) }
                        .catchError { Observable.just(.Failure(SensorEditingActionError.APIError($0))) }

                case .Update:
                    if let newSensor = self.sensor {
                        return CospaceServices.sensorsService.updateSensor(newSensor, purpose: self.purpose.value, description: self.name.value.text)
                            .map { .Success(newSensor) }
                            .catchError { Observable.just(.Failure(SensorEditingActionError.APIError($0))) }
                    } else {
                        return Observable.just(.Failure(SensorEditingActionError.UpdateSensor))
                    }
                }
            case .Failure(let error):
                return Observable.just(.Failure(error))
            }
        }
    }
}

enum SensorEditingActionError: ErrorType, CustomStringConvertible {
    case UpdateSensor
    case APIError(ErrorType)
    case ValidationError(ErrorType)

    var description: String {
        switch self {
        case .UpdateSensor:
            return "There was an error updating the sensor"
        case .ValidationError(let error):
            guard let error = error as? CustomStringConvertible else { return "Unknown error" }
            return error.description
        case .APIError(let error):
            guard let error = error as? CustomStringConvertible else { return "Unknown error" }
            return error.description
        }
    }
}

enum SensorEditingAction {
    case Add
    case Update
}
