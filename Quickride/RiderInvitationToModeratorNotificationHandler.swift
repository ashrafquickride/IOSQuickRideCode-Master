//
//  RiderInvitationToModeratorNotificationHandler.swift
//  Quickride
//
//  Created by Vinutha on 14/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RiderInvitationToModeratorNotificationHandler : RideInvitationNotificationHandler {
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let invitation = RideInvitationNotificationHandler.prepareRideInvitation(notification: clientNotification) else{
                return handler(false)
            }
            if let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance(), let riderRide = myActiveRidesCache.getRiderRideFromRideDetailInfo(rideId: invitation.rideId), riderRide.status != Ride.RIDE_STATUS_COMPLETED, riderRide.status != Ride.RIDE_STATUS_CANCELLED {
                RideInviteCache.getInstance().getRideInviteFromServer(id: invitation.rideInvitationId) { (invite,responseError, error) in
                    if responseError != nil || error != nil {
                        return handler(true)
                    }
                    return handler(invite != nil)
                }
            }
            return handler(false)
        }
        
    }
}

