//
//  MyRegularRidesCache.swift
//  Quickride
//
//  Created by QuickRideMac on 19/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CoreLocation

protocol MyRegularRidesCacheListener{
    func receiveRegularPassengersInfo( passengersInfo : [MatchedRegularPassenger]?)
    func receiveRegularRiderInfo(riderInfo : MatchedRegularRider?)
    
}
protocol RegularRideUpdateListener{
    func participantStatusUpdated(rideStatus : RideStatus)
}

class MyRegularRidesCache {
    
    static var singleInstance : MyRegularRidesCache?
    var userId :Double = 0
    var regularRiderRides : [Double : RegularRiderRide] = [Double : RegularRiderRide]()
    var regularPassengerRides : [Double : RegularPassengerRide] = [Double :RegularPassengerRide]()
    var connectedPassengersOfRegularRiderRide : [Double : [MatchedRegularPassenger]] = [Double : [MatchedRegularPassenger]]()
    var connectedRiderOfRegularPassengerRide : [Double : MatchedRegularRider] = [Double : MatchedRegularRider]()
    var regularRideUpdateListeners : [Double: RegularRideUpdateListener] = [Double:RegularRideUpdateListener]()
    var isRideObjectUpdateGoingOn = false
    var pendingStatusUpdates : [RideStatus] = [RideStatus]()
    static let MAXIMUM_DISTANCE_ALLOWED_TO_CREATE_RIDE = 100.0
    
    init(userId : String){
        self.userId = Double(userId)!
    }
    static func getInstance() -> MyRegularRidesCache{
        if singleInstance == nil{
            
            singleInstance =  MyRegularRidesCache(userId: (QRSessionManager.getInstance()?.getUserId())!)
        }
        return singleInstance!
    }
    func receiveRegularRides(regularRiderRides : [RegularRiderRide],regularPassengerRides : [RegularPassengerRide]){
        AppDelegate.getAppDelegate().log.debug("receiveRegularRides()")
        self.regularRiderRides.removeAll()
        self.regularPassengerRides.removeAll()
        for regularRiderRide in regularRiderRides{
            self.regularRiderRides[regularRiderRide.rideId] = regularRiderRide
            
        }
        for regularPassengerRide in regularPassengerRides{
            self.regularPassengerRides[regularPassengerRide.rideId] = regularPassengerRide
        }
    }
    
    func addNewRide(regularRide : RegularRide){
        AppDelegate.getAppDelegate().log.debug("addNewRide()")
        
        if  regularRide.status == Ride.RIDE_STATUS_COMPLETED ||
            regularRide.status == Ride.RIDE_STATUS_CANCELLED{
            return
        }
        if regularRide.rideType == Ride.REGULAR_RIDER_RIDE{
            if let regularRiderRide = regularRide as? RegularRiderRide{
              regularRiderRides[regularRide.rideId] = regularRiderRide
              MyRidesPersistenceHelper.storeRegularRiderRide(regularRiderRide: regularRiderRide)
            }
        }else if regularRide.rideType == Ride.REGULAR_PASSENGER_RIDE{
            if let regularPassengerRide = regularRide as? RegularPassengerRide{
               regularPassengerRides[regularRide.rideId] = regularPassengerRide
                MyRidesPersistenceHelper.storeRegularPassengerRide(regularPassengerRide: regularPassengerRide)
            }
        }
     }
    func updateRegularRide(regularRide: RegularRide){
        AppDelegate.getAppDelegate().log.debug("updateRegularRide()")
        if regularRide.rideType == Ride.REGULAR_RIDER_RIDE{
            if let regularRiderRide = regularRide as? RegularRiderRide{
              self.regularRiderRides[regularRide.rideId] = regularRiderRide
              MyRidesPersistenceHelper.updateRegularRiderRide(regularRiderRide: regularRiderRide)
            }
        }else{
            if let regularPassengerRide = regularRide as? RegularPassengerRide{
              self.regularPassengerRides[regularRide.rideId] = regularPassengerRide
              MyRidesPersistenceHelper.updateRegularPassengerRide(regularPassengerRide: regularPassengerRide)
            }
            
        }
    }
    func isStatusUpdateRedundant(rideStatus : RideStatus) -> Bool{
        AppDelegate.getAppDelegate().log.debug("isStatusUpdateRedundant()")
        var isRedundant = false
        let rideId = rideStatus.rideId
        var existingRide : Ride? = nil
        
        if Ride.REGULAR_RIDER_RIDE == rideStatus.rideType{
            existingRide = regularRiderRides[rideId]
        }else if Ride.REGULAR_PASSENGER_RIDE == rideStatus.rideType{
            existingRide = regularPassengerRides[rideId]
        }
        if existingRide == nil{
            // This can happen when the ride was removed from the cache as part of previous status
            // update
            isRedundant = true
        }
        else if existingRide?.status == rideStatus.status{
            isRedundant = true
        }
        return isRedundant
    }
    func updateRideStatus(rideStatus : RideStatus){
        if self.userId == rideStatus.userId{
            AppDelegate.getAppDelegate().log.debug("updateRideStatus()")
            if isStatusUpdateRedundant(rideStatus: rideStatus) == true{
                return
            }
            if rideStatus.rideType == Ride.REGULAR_RIDER_RIDE{
                updateRegularRiderRideStatusForCurrentUser(rideStatus: rideStatus)
            }else{
                updateRegularPassengerRideStatusForCurrentUser(rideStatus: rideStatus)
            }
        }else{
            if rideStatus.rideType == Ride.REGULAR_RIDER_RIDE{
                self.handleUpdateForCurrentUserConnectedRegularRiderRideStatusChange(rideStatus: rideStatus)
            }else{
                adjustNoOfPassengersAndAvailableSeatsToRegularRide(rideStatus: rideStatus)
            }
        }
        if isRideObjectUpdateGoingOn == false{
            notifyRideStatusChangeToListener(rideStatus: rideStatus)
        }else{
            pendingStatusUpdates.append(rideStatus)
        }
    }
    
    static func updateRegularRideStatusInPersistence(rideStatus : RideStatus){
        if let userId = SharedPreferenceHelper.getLoggedInUserId(){
            if rideStatus.userId == Double(userId){
                AppDelegate.getAppDelegate().log.debug("updateRideStatus()")
                
                if rideStatus.rideType == Ride.REGULAR_RIDER_RIDE{
                    updateRegularRiderRideStatusForCurrentUserInPersistence(rideStatus: rideStatus)
                }else{
                    updateRegularPassengerRideStatusForCurrentUserInPersistence(rideStatus: rideStatus)
                }
            }else{
                if rideStatus.rideType == Ride.REGULAR_RIDER_RIDE{
                    
                    handleUpdateForCurrentUserConnectedRegularRiderRideStatusChangeInPersistence(rideStatus: rideStatus)
                }else{
                    adjustNoOfPassengersAndAvailableSeatsToRegularRideInPersistence(rideStatus: rideStatus)
                }
            }
        }
    }
    
    func updateRegularRiderRideStatusForCurrentUser( rideStatus : RideStatus){
    AppDelegate.getAppDelegate().log.debug("updateRegularRiderRideStatusForCurrentUser()")
        let status = rideStatus.status
        let ride = regularRiderRides[rideStatus.rideId]
        if ride == nil{
            return
        }
        ride?.status = status!
        if rideStatus.status == Ride.RIDE_STATUS_SUSPENDED || rideStatus.status == Ride.RIDE_STATUS_SCHEDULED{
            MyRidesPersistenceHelper.updateRegularRiderRide(regularRiderRide: ride!)
        }
        regularRiderRides[rideStatus.rideId] = ride
        handleSuspendRide(ride: ride!)
        checkStatusForMovingFromActiveToClosure(regularRide: ride!)
    }
   static func updateRegularRiderRideStatusForCurrentUserInPersistence( rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("updateRegularRiderRideStatusForCurrentUser()")
        let status = rideStatus.status
        let ride = MyRidesPersistenceHelper.getRegularRiderRide(rideid: rideStatus.rideId)
        if ride == nil{
            return
        }
        ride?.status = status!
        if rideStatus.status == Ride.RIDE_STATUS_SUSPENDED || rideStatus.status == Ride.RIDE_STATUS_SCHEDULED{
            MyRidesPersistenceHelper.updateRegularRiderRide(regularRiderRide: ride!)
        }else{
          MyRidesPersistenceHelper.deleteRegularRiderRide(rideid: ride!.rideId)
        }
      }
    func handleSuspendRide(ride :RegularRide){
        if Ride.RIDE_STATUS_SUSPENDED == ride.status
        {
            if Ride.REGULAR_RIDER_RIDE == ride.rideType{
                connectedPassengersOfRegularRiderRide.removeValue(forKey: ride.rideId)
            }else{
                connectedRiderOfRegularPassengerRide.removeValue(forKey: ride.rideId)
            }
        }
    }
    func handleUpdateForCurrentUserConnectedRegularRiderRideStatusChange(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handleUpdateForCurrentUserConnectedRegularRiderRideStatusChange()")
        let currentUserPassengerRide = getRegularPassengerRideConnectedToRegularRiderRideId(riderRideId: rideStatus.rideId)
        if currentUserPassengerRide == nil{
            return
        }
        
        //If Cancelled/Completed checkin/ clear it up move to closed rides. clear ride detail info.
        if Ride.RIDE_STATUS_CANCELLED == rideStatus.status
            || Ride.RIDE_STATUS_COMPLETED == rideStatus.status || Ride.RIDE_STATUS_SUSPENDED == rideStatus.status{
            unJoinRegularPassengerFromRiderRide(ride: currentUserPassengerRide!)
        }
    }
    
    static func handleUpdateForCurrentUserConnectedRegularRiderRideStatusChangeInPersistence(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("handleUpdateForCurrentUserConnectedRegularRiderRideStatusChange()")
        let currentUserRegularPassengerRide = MyRidesPersistenceHelper.getRegularPassengerRide(rideid: rideStatus.rideId)
      
        //If Cancelled/Completed checkin/ clear it up move to closed rides. clear ride detail info.
        if Ride.RIDE_STATUS_CANCELLED == rideStatus.status
            || Ride.RIDE_STATUS_COMPLETED == rideStatus.status || Ride.RIDE_STATUS_SUSPENDED == rideStatus.status{
           MyRegularRidesCache.updateRegularPassengerRideParamsAndStoreInPersistence(ride: currentUserRegularPassengerRide)
        }
    }
    
    func getRegularPassengerRideConnectedToRegularRiderRideId( riderRideId : Double) -> RegularPassengerRide?{
        AppDelegate.getAppDelegate().log.debug("getRegularPassengerRideConnectedToRegularRiderRideId() \( riderRideId)")
        if riderRideId == 0{
            return nil
        }
        let activeRegularPassengerRides = regularPassengerRides.values
        for ride in activeRegularPassengerRides{
            if ride.regularRiderRideId == riderRideId{
                return ride
            }
        }
        return nil
    }
    func updateRegularPassengerRideStatusForCurrentUser( rideStatus : RideStatus){
    AppDelegate.getAppDelegate().log.debug("updateRegularPassengerRideStatusForCurrentUser()")
        let status = rideStatus.status
        let passengerRide : RegularPassengerRide? = regularPassengerRides[rideStatus.rideId]
        if passengerRide == nil{
            return
        }
        if Ride.RIDE_STATUS_REQUESTED == status{
            unJoinRegularPassengerFromRiderRide(ride: passengerRide!)
        }else if Ride.RIDE_STATUS_SCHEDULED == status{
            reloadRegularPassengerRide(rideStatus: rideStatus)
        }else{
            passengerRide!.status = status!
            regularPassengerRides[passengerRide!.rideId] = passengerRide
            handleSuspendRide(ride: passengerRide!)
            checkStatusForMovingFromActiveToClosure(regularRide: passengerRide!)
        }
    }
    
   static func updateRegularPassengerRideStatusForCurrentUserInPersistence( rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("updateRegularPassengerRideStatusForCurrentUser()")
        let status = rideStatus.status
        let regularPassengerRide = MyRidesPersistenceHelper.getRegularPassengerRide(rideid: rideStatus.rideId)
        if Ride.RIDE_STATUS_REQUESTED == status{
            updateRegularPassengerRideParamsAndStoreInPersistence(ride: regularPassengerRide)
        }else if Ride.RIDE_STATUS_SCHEDULED == status{
            MyRidesPersistenceHelper.updateRegularPassengerRide(regularPassengerRide: regularPassengerRide)
        }else{
            MyRidesPersistenceHelper.deleteRegularPassengerRide(rideid: regularPassengerRide.rideId)
        }
    }
    
    func checkStatusForMovingFromActiveToClosure(regularRide : RegularRide){
        AppDelegate.getAppDelegate().log.debug("checkStatusForMovingFromActiveToClosure()")
        if regularRide.status == Ride.RIDE_STATUS_CANCELLED ||
            regularRide.status == Ride.RIDE_STATUS_COMPLETED{
            if Ride.REGULAR_RIDER_RIDE == regularRide.rideType{
                deleteRegularRiderRideAndSubscriptions(ride: regularRide as! RegularRiderRide)
            }else if Ride.REGULAR_PASSENGER_RIDE == regularRide.rideType{
                deleteRegularPassengerRideAndSubscriptions(ride: regularRide as! RegularPassengerRide)
            }
        }
    }
    func deleteRegularRiderRideAndSubscriptions(ride : RegularRiderRide){
        AppDelegate.getAppDelegate().log.debug("deleteRegularRiderRideAndSubscriptions()")
        regularRiderRides.removeValue(forKey: ride.rideId)
        MyRidesPersistenceHelper.deleteRegularRiderRide(rideid: ride.rideId)
        
    }
    func deleteRegularPassengerRideAndSubscriptions(ride : RegularPassengerRide){
        AppDelegate.getAppDelegate().log.debug("deleteRegularPassengerRideAndSubscriptions()")
        regularPassengerRides.removeValue(forKey: ride.rideId)
        MyRidesPersistenceHelper.deleteRegularPassengerRide(rideid: ride.rideId)
    }
    func unJoinRegularPassengerFromRiderRide( ride : RegularPassengerRide){
        AppDelegate.getAppDelegate().log.debug( "unJoinRegularPassengerFromRiderRide()")
      connectedRiderOfRegularPassengerRide.removeValue(forKey: ride.rideId)
      regularPassengerRides[ride.rideId] = ride
      MyRegularRidesCache.updateRegularPassengerRideParamsAndStoreInPersistence(ride : ride)
    }
    
    static func updateRegularPassengerRideParamsAndStoreInPersistence(ride : RegularPassengerRide){
        ride.status = Ride.RIDE_STATUS_REQUESTED
        ride.regularRiderRideId = 0
        ride.riderId = 0
        ride.riderName = nil
        ride.points = 0
        ride.pickupAddress = nil
        ride.pickupLatitude = 0
        ride.pickupLongitude = 0
        ride.pickupTime = 0
        ride.dropAddress = nil
        ride.dropLatitude = 0
        ride.dropLongitude = 0
        ride.dropTime = 0
        MyRidesPersistenceHelper.updateRegularPassengerRide(regularPassengerRide: ride)
    }
    func reloadRegularPassengerRide(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("reloadRegularPassengerRide()")
        isRideObjectUpdateGoingOn = true
        let regularPassegnerRide = regularPassengerRides[rideStatus.rideId]
        if regularPassegnerRide != nil{
            regularPassegnerRide?.status = Ride.RIDE_STATUS_SCHEDULED
            regularPassegnerRide?.regularRiderRideId = rideStatus.joinedRideId
            regularPassengerRides[(regularPassegnerRide?.rideId)!] = regularPassegnerRide
        }
        RegularPassengerRideServiceClient.getRegularPassengerRide(rideId: rideStatus.rideId) { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let regularPassengerRide = Mapper<RegularPassengerRide>().map(JSONObject: responseObject!["resultData"])
                let existingRegularPassengerRide = self.regularPassengerRides[rideStatus.rideId]
                if existingRegularPassengerRide == nil{
                    self.regularPassengerRides[rideStatus.rideId] = regularPassengerRide
                }else{
                    existingRegularPassengerRide!.updateWithValuesFromNewRide(newRide: regularPassengerRide!)
                    self.regularPassengerRides[rideStatus.rideId] = existingRegularPassengerRide
                }
                
                //RideManagementMqttProxy.getInstance().passengerJoinedRegularRiderRide((regularPassengerRide?.regularRiderRideId)!)
            }
            self.processPeningRideStatusUpdates()
            self.isRideObjectUpdateGoingOn = false
        }
    }
    func processPeningRideStatusUpdates(){
        AppDelegate.getAppDelegate().log.debug("processPeningRideStatusUpdates()")
        for pendingRideStatus in pendingStatusUpdates{
            notifyRideStatusChangeToListener(rideStatus: pendingRideStatus)
        }
        pendingStatusUpdates.removeAll()
    }
    
    func notifyRideStatusChangeToListener(rideStatus : RideStatus){
        AppDelegate.getAppDelegate().log.debug("notifyRideStatusChangeToListener()")
        if self.regularRideUpdateListeners.isEmpty == true {return}
        DispatchQueue.main.async() { () -> Void in
            for rideUpdateListener in self.regularRideUpdateListeners{
                rideUpdateListener.1.participantStatusUpdated(rideStatus: rideStatus)
            }
        }
    }
    
    func adjustNoOfPassengersAndAvailableSeatsToRegularRide( rideStatus:RideStatus){
        AppDelegate.getAppDelegate().log.debug("adjustNoOfPassengersAndAvailableSeatsToRegularRide()")
        let ride = regularRiderRides[rideStatus.joinedRideId]
        if ride == nil{
            return
        }
        
        if isParticipantRideCancelledOrRequested(rideStatus: rideStatus.status!)  == true||isParticipantRideCompleted(status: rideStatus.status!) == true {
            ride?.noOfPassengers = (ride?.noOfPassengers)! - 1
            let availableSeats =  (ride?.availableSeats)! + 1
            ride?.availableSeats = availableSeats
            regularRiderRides[rideStatus.joinedRideId] = ride
            if self.connectedPassengersOfRegularRiderRide[rideStatus.joinedRideId] != nil && self.connectedPassengersOfRegularRiderRide[rideStatus.joinedRideId]! .isEmpty == false{
                removeConnectedRegularPassenger(regularPassengerRideId: rideStatus.rideId,regularRiderRideId:  rideStatus.joinedRideId)
            }
            notifyRideStatusChangeToListener(rideStatus: rideStatus)
        }else if isParticipantNewlyAdded(status: rideStatus.status!){
            ride?.noOfPassengers = (ride?.noOfPassengers)! + 1
            let availableSeats =  (ride?.availableSeats)!-1
            ride?.availableSeats =  availableSeats
            regularRiderRides[ride!.rideId] = ride
            if connectedPassengersOfRegularRiderRide[rideStatus.joinedRideId] != nil && connectedPassengersOfRegularRiderRide[rideStatus.joinedRideId]!.isEmpty == false{
                RegularPassengerRideServiceClient.getPassengerInfoOfRegularRiderRide(regularRiderRideId: rideStatus.joinedRideId, userId: rideStatus.userId, completionHander: { (responseObject, error) -> Void in
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        let connectedPasseger = Mapper<MatchedRegularPassenger>().map(JSONObject: responseObject!["resultData"])! as MatchedRegularPassenger
                        
                        
                        var connectedPassengers = self.connectedPassengersOfRegularRiderRide[rideStatus.joinedRideId]
                        if connectedPassengers == nil{
                            connectedPassengers = [MatchedRegularPassenger]()
                        }
                        connectedPassengers?.append(connectedPasseger)
                        self.connectedPassengersOfRegularRiderRide[rideStatus.joinedRideId] = connectedPassengers
                        self.notifyRideStatusChangeToListener(rideStatus: rideStatus);
                    }
                })
            }
        }
        MyRidesPersistenceHelper.updateRegularRiderRide(regularRiderRide: ride!)
    }
    
    static func adjustNoOfPassengersAndAvailableSeatsToRegularRideInPersistence(rideStatus:RideStatus){
        AppDelegate.getAppDelegate().log.debug("adjustNoOfPassengersAndAvailableSeatsToRegularRide()")
        let ride = MyRidesPersistenceHelper.getRegularRiderRide(rideid: rideStatus.rideId)
        if ride == nil{
            return
        }
        
        if rideStatus.status == Ride.RIDE_STATUS_REQUESTED || rideStatus.status == Ride.RIDE_STATUS_CANCELLED || rideStatus.status == Ride.RIDE_STATUS_SUSPENDED || rideStatus.status == Ride.RIDE_STATUS_COMPLETED {
            ride?.noOfPassengers = (ride?.noOfPassengers)! - 1
            let availableSeats =  (ride?.availableSeats)! + 1
            ride?.availableSeats = availableSeats
        
        }else if rideStatus.status == Ride.RIDE_STATUS_SCHEDULED{
            ride?.noOfPassengers = (ride?.noOfPassengers)! + 1
            let availableSeats =  (ride?.availableSeats)!-1
            ride?.availableSeats =  availableSeats
        }
        MyRidesPersistenceHelper.updateRegularRiderRide(regularRiderRide: ride!)
    }
    
    func removeConnectedRegularPassenger( regularPassengerRideId : Double, regularRiderRideId : Double) -> Bool{
        AppDelegate.getAppDelegate().log.debug("removeConnectedRegularPassenger() \(regularPassengerRideId) \(regularRiderRideId)")
        var connectedPassengersOfRide : [MatchedRegularPassenger]? = connectedPassengersOfRegularRiderRide[regularRiderRideId]!
        if connectedPassengersOfRide == nil || connectedPassengersOfRide!.isEmpty == true {
            return false
        }
        var connectedPassengerIndex = -1
        for index in 0...connectedPassengersOfRide!.count-1{
            if(connectedPassengersOfRide![index].rideid == regularPassengerRideId)
            {
                connectedPassengerIndex = index
                break
            }
        }
        if connectedPassengerIndex != -1{
            connectedPassengersOfRide?.remove(at: connectedPassengerIndex)
            connectedPassengersOfRegularRiderRide[regularRiderRideId] = connectedPassengersOfRide
            return true
        }
        return false
    }
    func  isParticipantRideCancelledOrRequested( rideStatus : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("checking if the ride is already closed or requested")
        return Ride.RIDE_STATUS_CANCELLED == rideStatus ||
            Ride.RIDE_STATUS_REQUESTED == rideStatus || Ride.RIDE_STATUS_SUSPENDED == rideStatus
    }
    func isParticipantRideCompleted( status : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("isParticipantRideCompleted() \(status)")
        return Ride.RIDE_STATUS_COMPLETED == status
    }
    
    
    func isParticipantNewlyAdded( status : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("isParticipantNewlyAdded() \(status)")
        return Ride.RIDE_STATUS_SCHEDULED == status
    }
    func getRegularRides(listener : MyRidesCacheListener){
        AppDelegate.getAppDelegate().log.debug("getRegularRides()")
        listener.receiveActiveRegularRides(regularRiderRides: regularRiderRides, regularPassengerRides: regularPassengerRides)
    }
    func  getRegularPassengerRide( passengerRideId : Double) -> RegularPassengerRide?{
        AppDelegate.getAppDelegate().log.debug("getRegularPassengerRide() \(passengerRideId)")
        return regularPassengerRides[passengerRideId]
    }
    func getRegularRiderRide( riderRideId : Double) -> RegularRiderRide?{
        AppDelegate.getAppDelegate().log.debug("getRegularRiderRide() \(riderRideId)")
        return regularRiderRides[riderRideId]
    }
    func getConnectedPassengersOfRegularRiderRide(rideId : Double,viewController : UIViewController ,listener : MyRegularRidesCacheListener){
        AppDelegate.getAppDelegate().log.debug("getConnectedPassengersOfRegularRiderRide() \(rideId)")
        if connectedPassengersOfRegularRiderRide[rideId] == nil || connectedPassengersOfRegularRiderRide[rideId]!.isEmpty{
            RegularPassengerRideServiceClient.getPassengersInfoOfRegularRiderRide(regularRiderRideId: rideId, completionHander: { (responseObject, error) -> Void in
                if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                    ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: viewController, handler: nil)
                }else if (responseObject!["result"] as! String == "SUCCESS") && responseObject!["resultData"] != nil{
                    let connectedPassengers = Mapper<MatchedRegularPassenger>().mapArray(JSONObject: responseObject!["resultData"])
                    self.connectedPassengersOfRegularRiderRide[rideId] = connectedPassengers
                    listener.receiveRegularPassengersInfo(passengersInfo: connectedPassengers)
                }
            })
        }else{
            listener.receiveRegularPassengersInfo(passengersInfo: connectedPassengersOfRegularRiderRide[rideId])
        }
    }
    func getConnectedRiderOfRegularPassengerRide(regularPassengerRideId : Double,regularRiderRideId : Double,viewController : UIViewController,listener : MyRegularRidesCacheListener){
        AppDelegate.getAppDelegate().log.debug("getConnectedRiderOfRegularPassengerRide() \(regularPassengerRideId) \(regularRiderRideId)")
        if connectedRiderOfRegularPassengerRide[regularPassengerRideId] == nil || connectedRiderOfRegularPassengerRide[regularPassengerRideId]?.rideid != regularRiderRideId{
          connectedRiderOfRegularPassengerRide.removeValue(forKey: regularPassengerRideId)
            RegularRiderRideServiceClient.getRiderInfoOfRegularRiderRide(regularRiderRideId: regularRiderRideId,regularPassengerRideId : regularPassengerRideId, handler: { (responseObject, error) -> Void in
                if responseObject == nil || responseObject!["result"] as! String == "FAILURE"{
                    ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: viewController, handler: nil)
                }else if (responseObject!["result"] as! String == "SUCCESS") && responseObject!["resultData"] != nil{
                    let connectedRider = Mapper<MatchedRegularRider>().map(JSONObject: responseObject!["resultData"]!)
                    self.connectedRiderOfRegularPassengerRide[regularPassengerRideId] = connectedRider
                    listener.receiveRegularRiderInfo(riderInfo: connectedRider)
                }
            })
        }else{
            listener.receiveRegularRiderInfo(riderInfo: connectedRiderOfRegularPassengerRide[regularPassengerRideId])
        }
    }
    func checkForDuplicate(regularRide : RegularRide) -> Bool{
        AppDelegate.getAppDelegate().log.debug("checkForDuplicate()")
        if regularRide.rideType == Ride.REGULAR_RIDER_RIDE{
            for regularRiderRide in regularRiderRides.values{
                if checkForRedundancy(ride: regularRiderRide, newRide: regularRide){
                    return true
                }
            }
        }else{
            for regularpassengerRide in regularPassengerRides.values{
                if checkForRedundancy(ride: regularpassengerRide, newRide: regularRide){
                    return true
                }
            }
        }
        return false
    }
    
    func checkForRedundancy(ride : RegularRide , newRide : RegularRide) -> Bool{
        AppDelegate.getAppDelegate().log.debug("checkForRedundancy()")
        let newRideStartPoint = CLLocation(latitude: ride.startLatitude, longitude: ride.startLongitude)
        let existingRideStartPoint = CLLocation(latitude: newRide.startLatitude, longitude: newRide.startLongitude)
        let newRideEndPoint = CLLocation(latitude: ride.endLatitude!, longitude: ride.endLongitude!)
        let existingRideEndPoint = CLLocation(latitude: newRide.endLatitude!, longitude: newRide.endLongitude!)
        
        return newRideStartPoint.distance(from: existingRideStartPoint) < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES &&
            newRideEndPoint.distance(from: existingRideEndPoint) < MyActiveRidesCache.THRESHOLD_DISTANCE_BETWEEN_TWO_POINTS_IN_METRES
    }
    
    func addRideUpdateListener(rideId: Double,listener : RegularRideUpdateListener){
        AppDelegate.getAppDelegate().log.debug("addRideUpdateListener()")
        self.regularRideUpdateListeners[rideId] = listener
    }
    func removeRideUpdateListenre(rideId: Double){
        AppDelegate.getAppDelegate().log.debug("removeRideUpdateListenre()")
        self.regularRideUpdateListeners.removeValue(forKey: rideId)
    }
    func removeCacheInstance(){
        AppDelegate.getAppDelegate().log.debug("removeCacheInstance()")
        self.regularRiderRides.removeAll()
        self.regularPassengerRides.removeAll()
        self.regularRideUpdateListeners.removeAll()
        self.userId = 0
        MyRegularRidesCache.singleInstance = nil
    }
    
    func isThereAnyRegularRide() -> Bool
    {
        if self.regularRiderRides.isEmpty && self.regularPassengerRides.isEmpty
        {
            return false
        }
        else
        {
            return true
        }
    }
    
    func isRideClosed(status : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("isRideClosed() \(status)")
        return Ride.RIDE_STATUS_COMPLETED == status || Ride.RIDE_STATUS_CANCELLED == status || Ride.RIDE_STATUS_SUSPENDED == status
    }
    
    func getActiveRegularRiderRides() -> [RegularRiderRide]{
        var activeRegularRiderRides = [RegularRiderRide]()
        for regularRide in regularRiderRides.values{
            if regularRide.status !=  Ride.RIDE_STATUS_SUSPENDED{
                activeRegularRiderRides.append(regularRide)
            }
        }
        return activeRegularRiderRides
    }
    
    func getActiveRegularPassengerRides() -> [RegularPassengerRide]{
        var activeRegularPassengerRides = [RegularPassengerRide]()
        for regularRide in regularPassengerRides.values{
            if regularRide.status != Ride.RIDE_STATUS_SUSPENDED{
                activeRegularPassengerRides.append(regularRide)
            }
        }
        return activeRegularPassengerRides
    }
    
    func getSuspendedRegularRiderRides() -> [RegularRiderRide]{
        var activeRegularRiderRides = [RegularRiderRide]()
        for regularRide in regularRiderRides.values{
            if regularRide.status ==  Ride.RIDE_STATUS_SUSPENDED{
                activeRegularRiderRides.append(regularRide)
            }
        }
        return activeRegularRiderRides
    }
    
    func getSuspendedRegularPassengerRides() -> [RegularPassengerRide]{
        var activeRegularPassengerRides = [RegularPassengerRide]()
        for regularRide in regularPassengerRides.values{
            if regularRide.status == Ride.RIDE_STATUS_SUSPENDED{
                activeRegularPassengerRides.append(regularRide)
            }
        }
        return activeRegularPassengerRides
    }
}
