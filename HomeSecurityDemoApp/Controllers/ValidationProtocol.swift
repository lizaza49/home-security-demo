//
//  ValidationProtocol.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 02.09.16.
//  Copyright © 2016 Ilya Myakotin. All rights reserved.
//

import Foundation
import Result
import RxSwift

public enum ValidationError: ErrorType {
    case Empty(String)
    case TooShort(String, Int)
    case TooLong(String, Int)
    case CanContainLettersAndNumbersOnly(String)
}

protocol ValidationProtocol {
    func validate(fields: [InputFieldData]) -> Observable<[Void]>
}

extension ValidationProtocol {
    func validate(fields: [InputFieldData]) -> Observable<[Void]> {
        return fields.flatMap { field -> Observable<Void> in
            do {
                try field.validate(field.text)
            } catch {
                return Observable.error(error)
            }
            return Observable.just()
        }.toObservable().merge().toArray()
    }
}
