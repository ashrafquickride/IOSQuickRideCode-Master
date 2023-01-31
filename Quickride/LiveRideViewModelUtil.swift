//
//  LiveRideViewModelUtil.swift
//  Quickride
//
//  Created by Quick Ride on 7/20/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class LiveRideViewModelUtil {
    
    static func initializeRideDetailInfo(currentUserRide : Ride) -> RideDetailInfo?{
        if let passengerRide = currentUserRide as? PassengerRide {
            if passengerRide.riderRideId != 0 {
               return MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoIfExist(riderRideId: passengerRide.riderRideId)
            }
        }
        let riderRideId = getRiderRideId(currentUserRide : currentUserRide)
        if riderRideId == 0 {
            return nil
        }
        return MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoIfExist(riderRideId: riderRideId)
    }
    
    static  func getRiderRideId(currentUserRide : Ride?) -> Double {
        if currentUserRide == nil{
            return 0
        }
        if let passengerRide = currentUserRide as? PassengerRide {
            if passengerRide.taxiRideId == 0 || passengerRide.taxiRideId == nil {
                return passengerRide.riderRideId
            } else {
                return passengerRide.taxiRideId!
            }
        }else{
            return currentUserRide!.rideId
        }
    }
    static func filterRideEtiqueteIamges(rideType : String, smallImage: Bool = true) -> [UserRideEtiquetteMedia]{
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        guard let etiquettMedia = clientConfiguration.userRideEtiquetteMediaList, etiquettMedia.count > 0 else {
            return []
        }
        let filtered = etiquettMedia.filter { element in
            return element.rideType == rideType && (element.smallMediaUrl != nil || (!smallImage && element.bigMediaUrl != nil ))
        }
        return filtered
    }
    
    
    static func getApplicableActionOnPassengerSelection(rideParticipant : RideParticipant,riderRide : RiderRide?,currentUserRide : Ride) -> [String]{
        var applicableActions = [String]()
        if rideParticipant.enableChatAndCall && (rideParticipant.status != Ride.RIDE_STATUS_STARTED || currentUserRide.status != Ride.RIDE_STATUS_STARTED){
            applicableActions.append(Strings.contact)
        }
        if let appStartUpData = SharedPreferenceHelper.getAppStartUpData(),!appStartUpData.enableNumberMasking && rideParticipant.enableChatAndCall && (rideParticipant.status != Ride.RIDE_STATUS_STARTED || currentUserRide.status != Ride.RIDE_STATUS_STARTED){
            applicableActions.append(Strings.smsLabel)
        }
        applicableActions.append(Strings.route)
        if currentUserRide.rideType == Ride.RIDER_RIDE && riderRide?.status == Ride.RIDE_STATUS_STARTED && rideParticipant.status == Ride.RIDE_STATUS_STARTED{
            applicableActions.append(Strings.droppedOff)
        }
        applicableActions.append(Strings.profile)
        if currentUserRide.rideType == Ride.RIDER_RIDE,let rideNotes = rideParticipant.rideNote , !rideNotes.isEmpty{
            applicableActions.append(Strings.ride_notes)
        }
        if currentUserRide.rideType == Ride.RIDER_RIDE {
            if let name = rideParticipant.name {
                applicableActions.append(String(format: Strings.rate_user, arguments: [name]))
            }else{
                applicableActions.append(Strings.rate_user)
            }
        }
        
        
        if currentUserRide.rideType == Ride.RIDER_RIDE && (Ride.RIDE_STATUS_SCHEDULED == rideParticipant.status || Ride.RIDE_STATUS_DELAYED == rideParticipant.status) {
            if let name = rideParticipant.name {
                applicableActions.append(Strings.unjoin+" "+name)
            }else{
                applicableActions.append(Strings.unjoin)
            }
        }
        return applicableActions
    }
    static func getRiderVehicle(riderRide : RiderRide?) -> Vehicle?{
        guard let riderRide = riderRide else {
             return nil
         }
        let vehicle = Vehicle(ownerId:riderRide.userId,vehicleModel: riderRide.vehicleModel,vehicleType: riderRide.vehicleType,registrationNumber: riderRide.vehicleNumber,capacity: riderRide.capacity,fare: riderRide.farePerKm,makeAndCategory: riderRide.makeAndCategory,additionalFacilities: riderRide.additionalFacilities,riderHasHelmet : riderRide.riderHasHelmet)
         vehicle.imageURI = riderRide.vehicleImageURI
        return vehicle
    }
}
