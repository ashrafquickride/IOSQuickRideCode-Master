//
//  NotifyRiderRideInstanceCreationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 07/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class NotifyRiderRideInstanceCreationHandler: RideInstanceCreationNotificationHandler {
    
    override func getRide() -> Ride? {
      AppDelegate.getAppDelegate().log.debug("getRide()")
        return MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: getRideId())
        
    }
}
