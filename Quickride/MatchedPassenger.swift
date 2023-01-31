
//
//  MatchedPassenger.swift
//  Quickride
//
//  Created by Vinayak Deshpande on 10/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


public class MatchedPassenger:MatchedUser,NSCopying{
  
  var requiredSeats:Int = 1
  var passengerTaxiRideId = 0
  static let REQUIRED_SEATS = "requiredSeats"
  
  required public init(map: Map){
    super.init(map: map)
  }
    override init() {
        super.init()
    }
  
  public override func mapping(map: Map) {
    super.mapping(map: map)
    requiredSeats <- map["requiredSeats"]
    passengerTaxiRideId <- map["passengerTaxiRideId"]
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
        self.rideid = rideInvitation.passenegerRideId
        self.userid = rideInvitation.passengerId
        self.distance = rideInvitation.matchedDistance
        self.pickupLocationAddress = rideInvitation.pickupAddress
        self.dropLocationAddress = rideInvitation.dropAddress
        self.requiredSeats = rideInvitation.noOfSeats
        if rideInvitation.rideType == Ride.PASSENGER_RIDE || rideInvitation.rideType == Ride.REGULAR_PASSENGER_RIDE {
            self.points = rideInvitation.riderPoints
            self.newFare = rideInvitation.newRiderFare
        }else {
            self.points = rideInvitation.points
            self.newFare = rideInvitation.newFare
        }
    }
    public func copy(with zone: NSZone? = nil) -> Any {
        
        let matchedPassenger = MatchedPassenger()
        initialise(matchedUser: matchedPassenger)
        matchedPassenger.requiredSeats = self.requiredSeats
        return matchedPassenger
    }
   
}
