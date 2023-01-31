//
//  PassengerReminderNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 22/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PassengerReminderNotificationHandler : RideNotificationHandler {
  
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let groupValue = clientNotification.groupValue, !groupValue.isEmpty, let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance(), let rideId = Double(groupValue) else {
                return handler(false)
            }
            if let _ = myActiveRidesCache.getPassengerRide(passengerRideId: rideId) {
                return handler(true)
            }else if let _ = myActiveRidesCache.getPassengerRideByRiderRideId(riderRideId: rideId){
                return handler(true)
            }
            return handler(false)
        }
        
    }
  
  override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handleTap()")
    let riderRideId = Double(userNotification.msgObjectJson!)
    if (riderRideId != nil) {
        super.navigateToLiveRideView(riderRideId: riderRideId!)
    }
  }
}
