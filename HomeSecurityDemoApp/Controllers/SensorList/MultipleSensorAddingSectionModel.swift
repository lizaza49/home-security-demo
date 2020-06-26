//
//  MultipleSensorAddingSectionModel.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 06.09.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import RxDataSources

enum MultipleSensorAddingSectionModel {
    case SelectionCellSection(title: String, items: [SectionItem])
    case CodeValueCellSection(title: String, items: [SectionItem])
    case NameCellSection(title: String, items: [SectionItem])
}

enum SectionItem {
    case SelectionCellItem(data: SensorTypeCellData)
    case CodeValueCellItem(data: ValueCellData)
    case NameCellItem(data: ValueCellData)
}

extension MultipleSensorAddingSectionModel: SectionModelType {
    typealias Item = SectionItem
    var items: [SectionItem] {
        switch self {
        case .SelectionCellSection(title: _, items: let items):
            return items.map { $0 }
        case .CodeValueCellSection(title: _, items: let items):
            return items.map { $0 }
        case .NameCellSection(title: _, items: let items):
            return items.map { $0 }
        }
        }
        init(original: MultipleSensorAddingSectionModel, items: [Item]) {
            switch original {
            case let .SelectionCellSection(title: title, items: _):
                self = .SelectionCellSection(title: title, items: items)
            case let .CodeValueCellSection(title, _):
                self = .CodeValueCellSection(title: title, items: items)
            case let .NameCellSection(title, _):
                self = .NameCellSection(title: title, items: items)
            }
            }
            }
