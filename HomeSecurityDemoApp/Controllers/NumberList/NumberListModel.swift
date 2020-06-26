//
//  NumberListModel.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 22.08.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import UIKit
import HomeSecurityAPI
import RxSwift
import RxCocoa
import RxDataSources

struct NumberListModel {
    let sections: [SectionModel<String, Phone>]

    init(sections: [SectionModel<String, Phone>] = []) {
        self.sections = sections
    }

    func updateNumbers(priority: Phone.Priority) -> Observable<NumberListModel> {
        return CospaceServices.phonesService.getPhones(priority)
            .map { newphones in
            return NumberListModel(sections: [SectionModel(model: "", items: newphones)])
        }
    }

    func phone(forIndexPath indexPath: NSIndexPath) -> Phone {
        return self.sections[indexPath.section].items[indexPath.row]
    }

    func deletePhone(forIndexPath indexPath: NSIndexPath) -> Observable<NumberListModel> {
        return CospaceServices.phonesService.deletePhone(sections[indexPath.section].items[indexPath.row])
            .map { _ in
            var newPhones = self.sections[indexPath.section].items
            newPhones.removeAtIndex(indexPath.row)
            return NumberListModel(sections: [SectionModel(model: "", items: newPhones)])
        }
    }
}
