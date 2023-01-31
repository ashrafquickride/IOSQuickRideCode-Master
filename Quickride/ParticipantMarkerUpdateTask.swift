//
//  ParticipantMarkerUpdateTask.swift
//  Quickride
//
//  Created by KNM Rao on 04/11/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


class ParticipantMarkerUpdateTask {
    
    var currentParticipantRide : Ride?
    var riderRideId,riderId : Double?
    
    init(currentParticipantRide : Ride){
        self.currentParticipantRide = currentParticipantRide
        if Ride.PASSENGER_RIDE == currentParticipantRide.rideType, let passengerRide = currentParticipantRide as? PassengerRide{
            riderRideId = passengerRide.riderRideId
            riderId = passengerRide.riderId
        }else {
            riderRideId = currentParticipantRide.rideId
            riderId = currentParticipantRide.userId
        }
    }
    
    func pullLatestLocationUpdatesBasedOnExpiry(){
        AppDelegate.getAppDelegate().log.debug("pullLatestLocationUpdatesBasedOnExpiry")
        
        if isLocationUpdateFromSerVerRequired(){
            retrieveRiderParticipantLocationFromServer()
        }
    }
    func retrieveRiderParticipantLocationFromServer() {
        AppDelegate.getAppDelegate().log.debug("retrieveRiderParticipantLocationFromServer")
        LocationUpdationServiceClient.getRiderParticipantLocation(rideId: riderRideId!, targetViewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let newLocation = Mapper<RideParticipantLocation>().map(JSONObject: responseObject!["resultData"])
                if newLocation != nil{
                    MyActiveRidesCache.getRidesCacheInstance()?.updateRideParticipantLocation(rideParticipantLocation: newLocation)
                }
            }
        }
    }
    
//    func retrieveRideParticipantLocationFromServer() {
//        AppDelegate.getAppDelegate().log.debug("retrieveRideParticipantLocationFromServer")
//        LocationUpdationServiceClient.getRideParticipantLocations(rideId: riderRideId!, targetViewController: nil) { (responseObject, error) in
//            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
//                let newRideParticipantLocations = Mapper<RideParticipantLocation>().mapArray(JSONObject: responseObject!["resultData"])
//                if newRideParticipantLocations != nil && newRideParticipantLocations!.isEmpty == false{
//                    for newRideParticipantLocation in newRideParticipantLocations!{
//                        MyActiveRidesCache.getRidesCacheInstance()?.updateRideParticipantLocation(rideParticipantLocation: newRideParticipantLocation)
//                    }
//                }
//            }
//        }
//    }

    
    func isLocationUpdateFromSerVerRequired() -> Bool {
        let rideDetailInfo = MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoIfExist(riderRideId: riderRideId)
        if rideDetailInfo == nil{
            return false
        }
        if rideDetailInfo!.rideParticipants == nil || rideDetailInfo!.rideParticipants!.isEmpty{
            return false
        }
        for rideParticipant in rideDetailInfo!.rideParticipants! {
            
            if !rideParticipant.rider{
                continue
            }
            if  Ride.RIDE_STATUS_COMPLETED == rideParticipant.status{
                return false
            }
            guard let participantLocation = rideDetailInfo!.getRideParticipantLocation(userId: rideParticipant.userId) else { return true }
                
            if   RideViewUtils.isLatestLocationUpdateExpired(lastUpdateTime: participantLocation.lastUpdateTime) {
                    return true
            }
        }
        return false
    }
}
