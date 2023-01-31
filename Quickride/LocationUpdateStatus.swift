//
//  LocationUpdateStatus.swift
//  Quickride
//
//  Created by Quick Ride on 11/21/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps

extension NSNotification.Name{
    static let locationUpdateSatatus = NSNotification.Name("locationUpdateStatus")
}
class LocationUpdateStatus: NSObject, CLLocationManagerDelegate {
    
    var batteryLevel : Double
    var batteryState : UIDevice.BatteryState
    var locationPermission: CLAuthorizationStatus

    init(batteryLevel : Double,batteryState : UIDevice.BatteryState,locationPermission: CLAuthorizationStatus) {
        self.batteryLevel = batteryLevel
        self.batteryState = batteryState
        self.locationPermission = locationPermission
    }
}
