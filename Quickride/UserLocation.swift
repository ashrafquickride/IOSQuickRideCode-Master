//
//  UserLocation.swift
//  Quickride
//
//  Created by QuickRideMac on 25/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class UserLocation {
    
    var userId : Double
    var latitude : Double
    var longitude : Double
    var bearing : Double?
    var locationTime : NSDate
    
    init(userId : Double,latitude : Double,longitude : Double,bearing : Double?,locationTime : NSDate){
        self.userId  = userId
        self.latitude = latitude
        self.longitude = longitude
        self.bearing = bearing
        self.locationTime = locationTime
    }
}
