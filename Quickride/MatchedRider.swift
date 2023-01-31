//
//  MatchedRider.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 10/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MatchedRider : MatchedUser,NSCopying {
  
  var model:String?
  var fare:Double?
  var rideStatus:String?
  var availableSeats:Int?
  var capacity:Int?
  var joinedPassengers : [UserBasicInfo]?
  var vehicleType : String?
  var vehicleNumber : String?
  var vehicleMakeAndCategory : String?
  var vehicleImageURI : String?
  var additionalFacilities : String?
  var riderHasHelmet = false
  var route : RoutePathData?
  var rideAssuIncId : Double?
  
  override init(){
    super.init()
  }
    override init(ride: Ride, rideInvitation: RideInvitation, userProfile: UserBasicInfo) {
        super.init(ride: ride, rideInvitation: rideInvitation, userProfile: userProfile)
    }
  
  init(rideInvitation : RideInvitation) {
    super.init()
    self.pickupLocationLatitude = rideInvitation.pickupLatitude
    self.pickupLocationLongitude = rideInvitation.pickupLongitude
    self.dropLocationLatitude = rideInvitation.dropLatitude
    self.dropLocationLongitude = rideInvitation.dropLongitude
    self.pickupTime = rideInvitation.pickupTime
    self.dropTime = rideInvitation.dropTime
    self.rideid = rideInvitation.rideId
    self.userid = rideInvitation.riderId
    self.distance = rideInvitation.matchedDistance
    self.points = rideInvitation.points
    self.newFare = rideInvitation.newFare
    self.pickupLocationAddress = rideInvitation.pickupAddress
    self.dropLocationAddress = rideInvitation.dropAddress

  }
  required internal init(_ map: Map) {
    super.init(map : map)
  }
    init(passengerRide : PassengerRide) {
        super.init()
        self.pickupLocationLatitude = passengerRide.pickupLatitude
        self.pickupLocationLongitude = passengerRide.pickupLongitude
        self.dropLocationLatitude = passengerRide.dropLatitude
        self.dropLocationLongitude = passengerRide.dropLongitude
        self.pickupTime = passengerRide.pickupTime
        self.dropTime = passengerRide.dropTime
        self.rideid = passengerRide.rideId
        self.userid = passengerRide.riderId
        self.distance = passengerRide.overLappingDistance
        self.points = passengerRide.points
        self.newFare = passengerRide.newFare
        self.pickupLocationAddress = passengerRide.pickupAddress
        self.dropLocationAddress = passengerRide.dropAddress
        self.userPreferredPickupDrop = UserPreferredPickupDrop(userId: nil, latitude: nil, longitude: nil, type: nil, note: passengerRide.pickupNote)
    }
    
    override init(riderRide : RiderRide, rideParticipant: RideParticipant, currentRideParticipant: RideParticipant?) {
        super.init(riderRide: riderRide, rideParticipant: rideParticipant, currentRideParticipant: currentRideParticipant)
        self.model = riderRide.vehicleModel
        self.fare = riderRide.farePerKm
        self.rideStatus = rideParticipant.status
        self.availableSeats = riderRide.availableSeats
        self.capacity = riderRide.capacity
        self.vehicleType = riderRide.vehicleType
        self.vehicleNumber = riderRide.vehicleNumber
        self.vehicleMakeAndCategory = riderRide.makeAndCategory
        self.vehicleImageURI = riderRide.vehicleImageURI
        self.additionalFacilities = riderRide.additionalFacilities
        self.riderHasHelmet = riderRide.riderHasHelmet
    }
    
    required public init(map: Map) {
        super.init(map: map)
    }
    
    
  
  override func mapping(map: Map) {
    super.mapping(map: map)
    model <- map["model"]
    fare <- map["fare"]
    rideStatus <- map["rideStatus"]
    availableSeats <- map["availableSeats"]
    capacity <- map["capacity"]
    vehicleType <- map["vehicleType"]
    if vehicleType == nil || vehicleType!.isEmpty{
      vehicleType = Vehicle.checkVehicleTypeFromModel(vehicleModel: model)
    }
    vehicleNumber <- map["vehicleNumber"]
    vehicleMakeAndCategory <- map["vehicleMakeAndCategory"]
    additionalFacilities <- map["additionalFacilities"]
    vehicleImageURI <- map["vehicleImageURI"]
    riderHasHelmet <- map["riderHasHelmet"]
    rideAssuIncId <- map["rideAssuIncId"]
  }
    
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let matchedUser = MatchedRider()
        initialise(matchedUser: matchedUser)
        
        matchedUser.model = self.model
        matchedUser.fare = self.fare
        matchedUser.rideStatus = self.rideStatus
        matchedUser.availableSeats = self.availableSeats
        matchedUser.capacity = self.capacity
        matchedUser.joinedPassengers  = self.joinedPassengers
        matchedUser.vehicleType  = self.vehicleType
        matchedUser.vehicleNumber  = self.vehicleNumber
        matchedUser.vehicleMakeAndCategory = self.vehicleMakeAndCategory
        matchedUser.vehicleImageURI = self.vehicleImageURI
        matchedUser.additionalFacilities = self.additionalFacilities
        matchedUser.riderHasHelmet  = self.riderHasHelmet
        matchedUser.route  = self.route
        matchedUser.rideAssuIncId = self.rideAssuIncId
        return matchedUser
    }
  
}
