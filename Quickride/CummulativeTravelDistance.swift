//
//  CummulativeTravelDistance.swift
//  Quickride
//
//  Created by Vinutha on 4/4/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary..
//

import Foundation
class CummulativeTravelDistance {
    var passengerStartToPickup : Double = -1
    var passengerDropToEnd : Double = -1
    
    init(){
        
    }
    
    func isCumulativeDistanceRetrieved() -> Bool{
        if passengerStartToPickup < 0 || passengerDropToEnd < 0{
            return false
        }
        return true
    }
    
    static func getReadableDistance( distance : Double) -> String{
        getReadableDistance(distanceInMeters: distance*1000)
    }
    static func getReadableDistance( distanceInMeters : Double) -> String{
        if distanceInMeters < 1000{
            return StringUtils.getStringFromDouble(decimalNumber: distanceInMeters) + " m"
        }else{
            var distanceInKM = distanceInMeters/1000
            let string = distanceInKM.roundToPlaces(places: 2)
            return String(string) + " km"
        }
    }
}
