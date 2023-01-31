//
//  RiderRideRescheduleSuggestionNotificationHandler.swift
//  Quickride
//
//  Created by iDisha on 14/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RiderRideRescheduleSuggestionNotificationHandler: RideRescheduleSuggestionNotificationHandler {
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            let riderRide = self.getRideFromGroupValue(userNotification: clientNotification)
            if riderRide != nil && (riderRide as! RiderRide).noOfPassengers == 0{
                return handler(true)
            }
            return handler(false)
        }
        
        
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        
        if QRReachability.isConnectedToNetwork(){
            NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: userNotification)
        }
        if let riderRide = getRideFromGroupValue(userNotification: userNotification){
            navigateToLiveRideView(ride: riderRide)
            RescheduleRide(ride: riderRide, viewController: ViewControllerUtils.getCenterViewController(),moveToRideView: false).rescheduleRide()
        }
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        if let riderRide = getRideFromGroupValue(userNotification: userNotification){
            navigateToLiveRideView(ride: riderRide)
        }
        
    }
    
    func getRideFromGroupValue(userNotification: UserNotification) -> Ride? {
        let rideId = Double(userNotification.groupValue!)
        if rideId == nil{
            return nil
        }
        let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideId!)
        return riderRide
    }
}
