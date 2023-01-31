//
//  RideInvitationWithFareChangeNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 17/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class RideInvitationWithFareChangeNotificationHandler: RideInvitationNotificationHandler{
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: clientNotification), rideInvitation.rideId != 0, let rideType = rideInvitation.rideType,!rideType.isEmpty else {
                return handler(false)
            }
            if rideType != Ride.PASSENGER_RIDE{
                return handler(false)
            }
            guard let ride = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideInvitation.rideId), ride.availableSeats > 0 else {
                return handler(false)
            }
            RideInviteCache.getInstance().getRideInviteFromServer(id: rideInvitation.rideInvitationId) { (invite,responseError, error) in
                if responseError != nil || error != nil {
                    return handler(true)
                }
                return handler(invite != nil)
            }
            
           
        }
        
    }
    override func handleTextToSpeechMessage(userNotification : UserNotification)
    {
        let rideInvitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: userNotification)
        let rideId = rideInvitation?.rideId
        let rideType = rideInvitation?.rideType
        
        if Ride.PASSENGER_RIDE == rideType
        {
            let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
            if myActiveRidesCache == nil{
                return
            }
            let ride = myActiveRidesCache!.getRiderRide(rideId: rideId!)
            if ride != nil
            {
                if Ride.RIDE_STATUS_STARTED == ride!.status{
                    checkRiderRideStatusAndSpeakInvitation(text: userNotification.title!, time: NotificationHandler.delay_time)
                }
            }
        }
    }

    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
        return Strings.ACCEPT
    }
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        AppDelegate.getAppDelegate().log.debug("getNegativeActionNameWhenApplicable()")
        return Strings.REJECT
    }
    override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        AppDelegate.getAppDelegate().log.debug("getNeutralActionNameWhenApplicable()")
        return nil
    }
}
