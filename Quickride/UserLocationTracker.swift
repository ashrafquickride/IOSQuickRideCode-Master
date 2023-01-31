//
//  UserLocationTracker.swift
//  Quickride
//
//  Created by QuickRideMac on 25/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import CoreLocation
class UserLocationTracker {
    
    var userLocations : [UserLocation] = [UserLocation]()
    let MAX_LOCATION_STORE = 50
    let MIN_TIME_TO_IDENTIFY_MOVING_IN_SEC = 300.0
    let MIN_DISTANCE_TO_CONSIDER_USER_IS_NEAR_BY = 200
    let MIN_SPEED_TO_CONSIDER_USER_IS_MOVING = 1.5

    func addUserLocation( location :  CLLocation){
      AppDelegate.getAppDelegate().log.debug("addUserLocation()")
    let newLocation = UserLocation(userId: Double((QRSessionManager.getInstance()?.getUserId())!)!, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, bearing: location.course, locationTime: NSDate())
    
    userLocations.append(newLocation)
        if userLocations.count > MAX_LOCATION_STORE{
            userLocations.removeFirst()
        }
    }
    
    
    func  isUserMoving() -> Bool{
      AppDelegate.getAppDelegate().log.debug("isUserMoving()")
        if userLocations.count < 2{
            return false
        }
    let firstLocation = userLocations.first
    let lastLocation = userLocations.last
    let timeDifferenceBetweenLocationsInSecs = lastLocation!.locationTime.timeIntervalSince1970 - firstLocation!.locationTime.timeIntervalSince1970
        if timeDifferenceBetweenLocationsInSecs < MIN_TIME_TO_IDENTIFY_MOVING_IN_SEC {
            return false
        }
      let distanceBetweenLocationsInKms =  LocationClientUtils.getDistance(fromLatitude: lastLocation!.latitude, fromLongitude: lastLocation!.longitude, toLatitude: firstLocation!.latitude, toLongitude: firstLocation!.longitude)
    
    let speed = (distanceBetweenLocationsInKms*1000)/timeDifferenceBetweenLocationsInSecs;
        if speed >= MIN_SPEED_TO_CONSIDER_USER_IS_MOVING{
            return true
        }else{
            return false
        }
    }
    
    func getLatestLocationOfUser() -> UserLocation?{
      AppDelegate.getAppDelegate().log.debug("getLatestLocationOfUser()")
        if userLocations.count == 0{
            return nil
        }else{
            return userLocations.last
        }
    }
    
}
