//
//  SensorListViewModel.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 17.08.16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import HomeSecurityAPI
import RxCocoa
import RxDataSources

struct SectionOfCustomData {
    var header: String
    var items: [Sensor]
}
extension SectionOfCustomData: SectionModelType {
    typealias Item = Sensor

    init(original: SectionOfCustomData, items: [Item]) {
        self = original
        self.items = items
    }
}

class SensorListViewModel {
    private let reachabilityManager = NetworkReachabilityManager()
    private let disposeBag = DisposeBag()
    var tableViewState = SensorsTableViewState()
    var networkStatusVariable = Variable<NetworkReachabilityManager.NetworkReachabilityStatus>(.Unknown)
    private var networkStatusObservable: Observable<NetworkReachabilityManager.NetworkReachabilityStatus> {
        return Observable.create { [weak self] observer in
            guard let weakSelf = self else {
                observer.onCompleted()
                return NopDisposable.instance
            }
            weakSelf.reachabilityManager?.listener = { status in
                observer.onNext(status)
            }
            weakSelf.reachabilityManager?.startListening()
            return AnonymousDisposable {
                weakSelf.reachabilityManager?.stopListening()
            }
        }
    }

    init() {
        networkStatusObservable.map { status in
            return status
        }.bindTo(networkStatusVariable)
            .addDisposableTo(disposeBag)
    }
}

struct SensorsTableViewState {
    let sections: [SectionOfCustomData]
    private let disposeBag = DisposeBag()
    init(sections: [SectionOfCustomData] = []) {
        self.sections = sections
    }

    func sensor(forIndexPath indexPath: NSIndexPath) -> Sensor {
        return self.sections[indexPath.section].items[indexPath.row]
    }

    func update() -> Observable<SensorsTableViewState> {
        return CospaceServices.sensorsService.getCurrentUserSensorsList().map { result in
            return SensorsTableViewState(sections: [SectionOfCustomData(header: "", items: result)])
        }
    }

    func deleteSensor(forIndexPath indexPath: NSIndexPath) -> Observable<SensorsTableViewState> {
        return CospaceServices.sensorsService.deleteSensor(self.sections[indexPath.section].items[indexPath.row]).map { _ in
            var newSensors = self.sections[indexPath.section].items
            newSensors.removeAtIndex(indexPath.row)
            return SensorsTableViewState(sections: [SectionOfCustomData(header: "", items: newSensors)])
        }
    }
}
