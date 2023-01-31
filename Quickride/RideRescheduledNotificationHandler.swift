//
//  RideRescheduledNotificationHandler.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 24/03/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideRescheduledNotificationHandler : RideNotificationHandler {
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            let rideId = clientNotification.groupValue
            let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
            if(myActiveRidesCache == nil || rideId == nil || rideId!.isEmpty)
            {
                return handler(false)
            }
            let passengerRide = myActiveRidesCache!.getPassengerRideByRiderRideId(riderRideId: Double(rideId!)!)
            if passengerRide != nil
            {
                return handler(true)
            }
            else
            {
                return handler(false)
            }
        }
    }
    
    override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("handleTap()")
        let riderRideId = Double(userNotification.groupValue!)
        if (riderRideId != nil) {
            super.navigateToLiveRideView(riderRideId: riderRideId!)
        }
    }
}

