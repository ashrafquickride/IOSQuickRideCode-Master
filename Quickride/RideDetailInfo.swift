//
//  RideDetailInfo.swift
//  Quickride
//
//  Created by KNM Rao on 11/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import GoogleMaps
import ObjectMapper

class RideDetailInfo:NSObject, Mappable{
    
    static var minTimeDiffCurrentLocation : Int = 3
    var riderRideId : Double?
    var currentUserRide : Ride?
    var riderRide : RiderRide?
    var rideLocationUpdateTime : Double?
    var rideCurrentLocation : LatLng?
    var rideParticipants : [RideParticipant]? = nil
    var rideParticipantLocations : [RideParticipantLocation]? = nil
    var riderRideRoutePathData : RoutePathData?
    var rideTravelledPath : String?
    var offlineData = false
    var taxiShareRide: TaxiShareRide?
    override init(){
        
    }
    
    init(riderRideId : Double){
        self.riderRideId = riderRideId
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.riderRideId <- map["riderRideId"]
        self.currentUserRide <- map["currentUserRide"]
        self.riderRide <- map["riderRide"]
        self.rideParticipants <- map["rideParticipants"]
        self.rideLocationUpdateTime <- map["rideLocationUpdateTime"]
        self.rideCurrentLocation <- map["rideCurrentLocation"]
        self.rideParticipantLocations <- map["rideParticipantLocations"]
        self.riderRideRoutePathData <- map["riderRideRoutePathData"]
        self.rideTravelledPath <- map["rideTravelledPath"]
        self.offlineData <- map["offlineData"]
        self.taxiShareRide <- map["taxiShareRide"]
    }
    
     func addNewParticipant(rideParticipant : RideParticipant){
       AppDelegate.getAppDelegate().log.debug("addNewParticipant()")
        if self.rideParticipants == nil {
            rideParticipants = [RideParticipant]()
        }
        rideParticipants?.append(rideParticipant)
    }
    
    func removeParticipant(participantId : Double){
       AppDelegate.getAppDelegate().log.debug("removeParticipant()")
        if rideParticipants == nil || rideParticipants?.isEmpty == true{
            return
        }
        for index in 0...(rideParticipants?.count)!-1{
            if rideParticipants![index].userId == participantId{
                self.rideParticipants?.remove(at: index)
                removeRideParticipantLocation(userId: participantId)
                break
            }
        }
        
    }
    
    
    func getRideParticipant(rideParticipantId : Double?) -> RideParticipant?{
      AppDelegate.getAppDelegate().log.debug("getRideParticipant() \(String(describing: rideParticipantId))")
        if rideParticipants == nil{
            return nil
        }
        for rideParticipant in rideParticipants!{
            if rideParticipant.userId == rideParticipantId!{
                return rideParticipant
            }
        }
        return nil
    }
  func getScheduledRideParticipant(rideParticipantId : Double?) -> RideParticipant?{
    AppDelegate.getAppDelegate().log.debug("getScheduledRideParticipant() \(String(describing: rideParticipantId))")
    if rideParticipants == nil{
      return nil
    }
    for rideParticipant in rideParticipants!{
      if rideParticipant.userId == rideParticipantId &&
        rideParticipant.status != Ride.RIDE_STATUS_COMPLETED{
        return rideParticipant
      }
    }
    return nil
  }
  
    func updateRideParticipantStatus(participantId : Double?, status : String){
      AppDelegate.getAppDelegate().log.debug("updateRideParticipantStatus() \(String(describing: participantId))")
        if Ride.RIDE_STATUS_CANCELLED == status||Ride.RIDE_STATUS_REQUESTED == status{
            removeParticipant(participantId: participantId!)
            return
        }
        let participant : RideParticipant? = getRideParticipant(rideParticipantId: participantId)
        if participant != nil{
            participant!.status = status
            if currentUserRide?.userId == participantId{
              currentUserRide?.status = status
          }
        }
        
    }
    
    func updateExistingLocation(existingLocation : RideParticipantLocation,newLocation : RideParticipantLocation ) -> RideParticipantLocation{
      AppDelegate.getAppDelegate().log.debug("updateExistingLocation() existing : \(existingLocation) new : \(newLocation)")

        existingLocation.latitude = newLocation.latitude
        existingLocation.longitude = newLocation.longitude
        existingLocation.bearing = newLocation.bearing
        existingLocation.lastUpdateTime = newLocation.lastUpdateTime
        existingLocation.sequenceNo = newLocation.sequenceNo
        existingLocation.participantETAInfos = newLocation.participantETAInfos
        return existingLocation
        
    }
    func updateRideParticipantLocation(rideParticipantLocation : RideParticipantLocation)-> RideParticipantLocation{
      AppDelegate.getAppDelegate().log.debug("updateRideParticipantLocation()")
        let existingLocation = getRideParticipantLocation(userId: rideParticipantLocation.userId)
        
        if rideParticipantLocation.bearing == nil || rideParticipantLocation.bearing! < 0.0{
            
            let newLocation = CLLocation(latitude: rideParticipantLocation.latitude!, longitude: rideParticipantLocation.longitude!)
            let bearing = newLocation.getDirection(prevLat : existingLocation?.latitude, prevLng : existingLocation?.longitude)
            rideParticipantLocation.bearing = bearing
        }
        if existingLocation == nil{
            addRideParticipantLocation(rideParticipantLocation: rideParticipantLocation)
            return rideParticipantLocation
        }else{
            return updateExistingLocation(existingLocation: existingLocation!, newLocation: rideParticipantLocation)
        }
    }
    
    func addRideParticipantLocation(rideParticipantLocation: RideParticipantLocation){
      AppDelegate.getAppDelegate().log.debug("addRideParticipantLocation()")
        if rideParticipantLocations != nil {
            rideParticipantLocations!.append(rideParticipantLocation)
        }
    }
    func removeRideParticipantLocation(userId : Double){
        AppDelegate.getAppDelegate().log.debug("removeRideParticipantLocation()   \(userId)")
        if rideParticipantLocations == nil || rideParticipantLocations?.count == 0 {
           return 
        }
        for index in 0...rideParticipantLocations!.count-1 {
            if rideParticipantLocations![index].userId == userId{
                rideParticipantLocations!.remove(at: index)
                break
            }
        }
    }
    
    func getRideParticipantLocation(userId : Double?) -> RideParticipantLocation?{
      AppDelegate.getAppDelegate().log.debug("getRideParticipantLocation()   \(String(describing: userId))")
        if rideParticipantLocations == nil {
            return nil
        }
        for rideParticipantLocation in rideParticipantLocations!{
            if rideParticipantLocation.userId == userId{
                return rideParticipantLocation
            }
        }
        return nil
    }
    
    func updateRiderRideStatus(status : String){
      AppDelegate.getAppDelegate().log.debug("updateRiderRideStatus()   \(status)")
        if riderRide != nil {
            riderRide!.status = status
            updateRideParticipantStatus(participantId: riderRide!.userId, status: status)
        }
    }
    func isLoaded() -> Bool{
        AppDelegate.getAppDelegate().log.debug("isLoaded()")
        if currentUserRide != nil && riderRide != nil && rideParticipants != nil{
            return true
        }else{
            return false
        }
    }
    public override var description: String {
        return "riderRideId: \(String(describing: self.riderRideId))," + "currentUserRide: \(String(describing: self.currentUserRide))," + " riderRide: \( String(describing: self.riderRide))," + "rideLocationUpdateTime: \(String(describing: self.rideLocationUpdateTime))," + "rideCurrentLocation: \(String(describing: self.rideCurrentLocation))," + " rideParticipants: \( String(describing: self.rideParticipants))," + "rideParticipantLocations: \(String(describing: self.rideParticipantLocations))," + "rideCurrentLocation: \(String(describing: self.rideCurrentLocation))," + " riderRideRoutePathData: \( String(describing: self.riderRideRoutePathData))," + "rideTravelledPath: \(String(describing: self.rideTravelledPath))," + "offlineData: \(String(describing: self.offlineData)),"
    }

}
