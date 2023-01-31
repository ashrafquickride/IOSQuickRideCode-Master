//
//  MatchOptionQueryResult.swift
//  Quickride
//
//  Created by QuickRideMac on 14/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation

class MatchOptionQueryResult {
    static let THRESHOLD_DISTANCE_TO_CONSIDER_SAME_LOCATION_FOR_RESULT = 500.0;//Metres
    static let THRESHOLD_TIME_TO_CONSIDER_SAME_LOCATION_FOR_RESULT = 180.0 //3mins // 180 Seconds
    var latitude : Double
    var longitude : Double
    var rideType : String
    var queryTime : NSDate
    var nearestOptions : [NearByRideOption]
    
    init( latitude: Double, longitude: Double, rideType :String, queryTime : NSDate, nearestOptions :[NearByRideOption]) {
        self.latitude = latitude
        self.longitude = longitude
        self.rideType = rideType
        self.queryTime = queryTime
        self.nearestOptions = nearestOptions
    }
    
    func doesQueryMatches( latitude: Double,  longitude: Double,  rideType:String,  startTime :NSDate) -> Bool{
        let queryLocation = CLLocation(latitude: latitude, longitude: longitude)
        let availableLocation = CLLocation(latitude: self.latitude , longitude: self.longitude)
        if queryLocation.distance(from: availableLocation) < MatchOptionQueryResult.THRESHOLD_DISTANCE_TO_CONSIDER_SAME_LOCATION_FOR_RESULT && startTime.timeIntervalSince1970 - self.queryTime.timeIntervalSince1970 < MatchOptionQueryResult.THRESHOLD_TIME_TO_CONSIDER_SAME_LOCATION_FOR_RESULT && rideType == self.rideType{
            return true
        }else{
            return false
        }
    }
}
