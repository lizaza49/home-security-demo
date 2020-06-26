//
//  LocationService.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 26/08/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import HomeSecurityAPI
import CoreLocation
import RxSwift

class LocationService: NSObject, CLLocationManagerDelegate {

    static let sharedService = LocationService()

    private let locationManager: CLLocationManager = CLLocationManager()
    private let disposeBag = DisposeBag()

    func start() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingLocation()
    }

    func stop() {
        locationManager.stopUpdatingLocation()
    }

    @objc func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        CospaceServices.securityService.getHomeNetwork().flatMap { network -> Observable<Void> in
            if !network.ssid.isEmpty && !network.bssid.isEmpty {
                let atHome: Bool
                if let ssid = NetworkInfo.ssid, let bssid = NetworkInfo.bssid {
                    atHome = network.ssid.compare(ssid) == .OrderedSame && network.bssid.compare(bssid) == .OrderedSame
                } else {
                    atHome = false
                }
                return CospaceServices.familyService.registerMyselfAtHome(atHome)
            }
            return Observable.just()
        }.subscribe().addDisposableTo(disposeBag)
    }
}
