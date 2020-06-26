//
//  NetworkingInfo.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 29/08/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import SystemConfiguration.CaptiveNetwork

struct NetworkInfo {
    static var ssid: String? {
        if let data = NetworkInfo.interfaceData,
            let ssid = data["SSID"] as? String {
            return ssid
        }
        return nil
    }

    static var bssid: String? {
        if let data = NetworkInfo.interfaceData,
            let bssid = data["BSSID"] as? String {
            return bssid
        }
        return nil
    }

    static var ssiddata: NSData? {
        if let data = NetworkInfo.interfaceData,
            let ssiddata = data["SSIDDATA"] as? NSData {
            return ssiddata
        }
        return nil
    }

    private static var interfaceData: [String: AnyObject]? {
        guard let unwrappedCFArrayInterfaces = CNCopySupportedInterfaces() else {
            return nil
        }
        guard let swiftInterfaces = (unwrappedCFArrayInterfaces as NSArray) as? [String] else {
            return nil
        }
        for interface in swiftInterfaces {
            guard let unwrappedCFDictionaryForInterface = CNCopyCurrentNetworkInfo(interface) else {
                return nil
            }
            guard let SSIDDict = (unwrappedCFDictionaryForInterface as NSDictionary) as? [String: AnyObject] else {
                return nil
            }
            return SSIDDict
        }
        return nil
    }
}
