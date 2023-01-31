//
//  RiderDetailToPassengerCardViewModel.swift
//  Quickride
//
//  Created by Quick Ride on 7/20/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RiderDetailToPassengerCardViewModel {
    
    var currentUserRide : Ride
    var isModerator = false
    var isFromRideCreation = false
    var rideDetailInfo : RideDetailInfo?

    init() {
        currentUserRide = Ride()
    }
    
    init(currentUserRide: Ride) {
        self.currentUserRide = currentUserRide
        rideDetailInfo = LiveRideViewModelUtil.initializeRideDetailInfo(currentUserRide: currentUserRide)
        guard let rideParticipants = rideDetailInfo?.rideParticipants else {
            return
        }
        self.isModerator = RideViewUtils.checkIfPassengerEnabledRideModerator(ride: currentUserRide, rideParticipantObjects: rideParticipants)
    }
    func getRiderParticipantInfo() -> RideParticipant?{
        
        guard let rideParticipants = rideDetailInfo?.rideParticipants else {
            return nil
        }
        for rideParticipant in rideParticipants {
            if rideParticipant.rider {
                return rideParticipant
            }
        }
        return nil
    }
    func getRiderRideId() -> Double {
        return LiveRideViewModelUtil.getRiderRideId(currentUserRide: currentUserRide)
    }
    func getModeratorsAvaialbleForThisRide() -> [RideParticipant]{
        guard let rider = getRiderParticipantInfo(), let rideParticipants = rideDetailInfo?.rideParticipants else {
            return [RideParticipant]()
        }
        if !rider.rideModerationEnabled || rider.status == Ride.RIDE_STATUS_STARTED || rideParticipants.count > 2 {
            return [RideParticipant]()
        }
        var rideModerators = [RideParticipant]()
        for rideParticipant in rideParticipants {
            if rideParticipant.rideModerationEnabled && !rideParticipant.rider && rideParticipant.userId != Double(QRSessionManager.getInstance()!.getUserId())! {
                rideModerators.append(rideParticipant)
            }
        }
        return rideModerators
    }
    
    func getApplicableActionOnRiderSelection(rideParticipant : RideParticipant) -> [String]{
        
        var applicableActions = [String]()
        applicableActions.append(Strings.profile)
        if Ride.RIDE_STATUS_SCHEDULED == rideParticipant.status || Ride.RIDE_STATUS_DELAYED == rideParticipant.status || Ride.RIDE_STATUS_STARTED == rideParticipant.status {
            if let name = rideParticipant.name {
                applicableActions.append(Strings.unjoin+" " + name)
            }else{
                applicableActions.append(Strings.unjoin)

            }
        }
        return applicableActions
    }
    func getRiderVehicle() -> Vehicle?{
        guard let riderRide = rideDetailInfo?.riderRide else {
             return nil
         }
        let vehicle = Vehicle(ownerId:riderRide.userId,vehicleModel: riderRide.vehicleModel,vehicleType: riderRide.vehicleType,registrationNumber: riderRide.vehicleNumber,capacity: riderRide.capacity,fare: riderRide.farePerKm,makeAndCategory: riderRide.makeAndCategory,additionalFacilities: riderRide.additionalFacilities,riderHasHelmet : riderRide.riderHasHelmet)
         vehicle.imageURI = riderRide.vehicleImageURI
        return vehicle
    }
    
}
