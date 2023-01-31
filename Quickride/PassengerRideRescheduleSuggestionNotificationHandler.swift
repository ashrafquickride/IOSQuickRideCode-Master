//
//  PassengerRideRescheduleSuggestionNotificationHandler.swift
//  Quickride
//
//  Created by iDisha on 14/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PassengerRideRescheduleSuggestionNotificationHandler: RideRescheduleSuggestionNotificationHandler {
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            let passengerRide = self.getRideFromGroupValue(userNotification: clientNotification)
            if passengerRide != nil && (passengerRide as! PassengerRide).riderRideId == 0{
                return handler(true)
            }
            return handler(false)
        }
        
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        
        if QRReachability.isConnectedToNetwork(){
            NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: userNotification)
        }
        if let passengerRide = getRideFromGroupValue(userNotification: userNotification){
            navigateToLiveRideView(ride: passengerRide)
            RescheduleRide(ride: passengerRide, viewController: ViewControllerUtils.getCenterViewController(),moveToRideView: false).rescheduleRide()
        }
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        if let passengerRide = getRideFromGroupValue(userNotification: userNotification){
            navigateToLiveRideView(ride: passengerRide)
        }
    }
    
    func getRideFromGroupValue(userNotification: UserNotification) -> Ride? {
        let rideId = Double(userNotification.groupValue!)
        if rideId == nil{
            return nil
        }
        let passengerRide = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: rideId!)
        return passengerRide
    }
    
}
