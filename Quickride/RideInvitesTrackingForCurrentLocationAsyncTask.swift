//
//  RideInvitesTrackingForCurrentLocationAsyncTask.swift
//  Quickride
//
//  Created by rakesh on 1/26/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideInvitesTrackingForCurrentLocationAsyncTask{
    
    var location : LatLng
    
    init(location : LatLng)
    {
        self.location = location
    }
    
    func updateNotificationStatusForRides(){
        
        if let riderRides = MyActiveRidesCache.getRidesCacheInstance()?.getActiveRiderRides() {
            for ride in riderRides {
                if ride.value.status != Ride.RIDE_STATUS_STARTED{
                    continue
                }
                let rideInvites = RideInviteCache.getInstance().getPendingInvitesOfRide(rideId: ride.value.rideId)
                
                for invite in rideInvites{
                    if LocationClientUtils.getDistance(fromLatitude: location.latitude, fromLongitude: location.longitude, toLatitude: invite.pickupLatitude, toLongitude: invite.pickupLongitude) >= 200{
//                        RideInviteCache.getInstance().removeInvitation(id: invite.rideInvitationId)
                    }
                }
            }
        }
    }
}
