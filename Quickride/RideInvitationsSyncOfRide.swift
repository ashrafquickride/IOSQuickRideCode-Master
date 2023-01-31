//
//  SyncRideInvitationsOfRide.swift
//  Quickride
//
//  Created by QuickRideMac on 10/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideInvitationsSyncOfRide {
    
    func syncRideInvitations(){
        var rideIdList = [String: [String]]()
        if let riderRides = MyActiveRidesCache.getRidesCacheInstance()?.getActiveRiderRides() {
            for riderRide in riderRides {
                if rideIdList[Ride.RIDER_RIDE] == nil {
                    rideIdList[Ride.RIDER_RIDE] = [String]()
                }
                rideIdList[Ride.RIDER_RIDE]!.append(StringUtils.getStringFromDouble(decimalNumber: riderRide.value.rideId))
            }
        }
        
        if let passengerRides = MyActiveRidesCache.getRidesCacheInstance()?.getActivePassengerRides() {
            for passengerRide in passengerRides {
                if rideIdList[Ride.PASSENGER_RIDE] == nil {
                    rideIdList[Ride.PASSENGER_RIDE] = [String]()
                }
                rideIdList[Ride.PASSENGER_RIDE]!.append(StringUtils.getStringFromDouble(decimalNumber: passengerRide.value.rideId))
            }
        }
        if rideIdList.isEmpty {
            return
        }
        guard let rideIds = try? JSONSerialization.data(withJSONObject: rideIdList, options: []) else {
            return
        }
        let rideIdsInString = String(data: rideIds, encoding: String.Encoding.utf8)
        RideMatcherServiceClient.getAllRideInvitations(userId: QRSessionManager.getInstance()?.getUserId(), rideIdList: rideIdsInString) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                if let rideInvitations = Mapper<RideInvitation>().mapArray(JSONObject: responseObject!["resultData"]) {
                    RideInviteCache.getInstance().syncRideInvites(rideInvitations: rideInvitations)
                }
            } else {
                AppDelegate.getAppDelegate().log.error("handleResponse() failed : \(String(describing: responseObject)), \(String(describing: error))")
            }
        }
    }
}
