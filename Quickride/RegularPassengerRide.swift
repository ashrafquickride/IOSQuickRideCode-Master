//
//  RegularPassengerRide.swift
//  Quickride
//
//  Created by QuickRideMac on 19/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
public class RegularPassengerRide : RegularRide {
    
    var regularRiderRideId : Double = 0
    var riderId : Double = 0
    var riderName : String?
    var points : Double = 0
    var pickupAddress : String?
    var dropAddress : String?
    var pickupLatitude : Double = 0
    var pickupLongitude : Double = 0
    var dropLatitude : Double = 0
    var dropLongitude : Double = 0
    var pickupTime : Double = 0
    var dropTime : Double = 0
    
    override init() {
        super.init()
        rideType = Ride.REGULAR_PASSENGER_RIDE
    }
    init(passengerRide: PassengerRide) {
        super.init(ride: passengerRide)
        self.rideType = Ride.REGULAR_PASSENGER_RIDE
    }

    required public init?(_ map: Map) {
        super.init()
    }
    
    override init(ride: Ride) {
        super.init(ride: ride)
        self.rideType = Ride.REGULAR_PASSENGER_RIDE
    }
    
  init(regularPassengerRide : RegularPassengerRide) {
    super.init(ride: regularPassengerRide)
    self.regularRiderRideId = regularPassengerRide.regularRiderRideId
    self.riderId = regularPassengerRide.riderId
    self.riderName = regularPassengerRide.riderName
    self.points = regularPassengerRide.points
    self.pickupAddress = regularPassengerRide.pickupAddress
    self.dropAddress = regularPassengerRide.dropAddress
    self.pickupLatitude = regularPassengerRide.pickupLatitude
    self.pickupLongitude = regularPassengerRide.pickupLongitude
    self.dropLatitude = regularPassengerRide.dropLatitude
    self.dropLongitude = regularPassengerRide.dropLongitude
    self.pickupTime = regularPassengerRide.pickupTime
    self.dropTime = regularPassengerRide.dropTime
   
    self.rideType = Ride.REGULAR_PASSENGER_RIDE
    
  }
    required public init?(map: Map) {
        super.init(map: map)
    }
    

    init(userId : Double, userName : String, startAddress : String, startLatitude : Double, startLongitude : Double, endAddress : String, endLatitude : Double, endLongitude : Double, dayType : String, startTime : Double, fromDate : Double, toDate : Double?, sunday : String?, monday : String?, tuesday : String?, wednesday : String?, thursday : String?, friday : String?, saturday : String?){
        super.init(userId: userId, userName : userName, startAddress : startAddress, startLatitude : startLatitude, startLongitude : startLongitude, endAddress : endAddress, endLatitude : endLatitude, endLongitude : endLongitude, dayType : dayType, startTime : startTime, fromDate : fromDate, toDate : toDate, sunday : sunday, monday : monday, tuesday : tuesday, wednesday : wednesday, thursday : thursday, friday : friday, saturday : saturday, rideType : Ride.REGULAR_PASSENGER_RIDE)
    }
    override public func mapping(map: Map) {
        super.mapping(map: map)
        self.regularRiderRideId <- map["regularRiderRideId"]
        self.riderId <- map["riderId"]
        self.riderName <- map["riderName"]
        self.points <- map["points"]
        self.pickupAddress <- map["pickupAddress"]
        self.dropAddress <- map["dropAddress"]
        self.pickupLatitude <- map["pickupLatitude"]
        self.pickupLongitude <- map["pickupLongitude"]
        self.dropLatitude <- map["dropLatitude"]
        self.dropLongitude <- map["dropLatitude"]
        self.pickupTime <- map["pickupTime"]
        self.dropTime <- map["dropTime"]
        if rideType == nil{
          rideType = Ride.REGULAR_PASSENGER_RIDE
        }
    }
    override func getParams() -> [String : String]{
      AppDelegate.getAppDelegate().log.debug("getParams()")
        return super.getParams()
    }
  
    
    override func updateWithValuesFromNewRide( newRide : Ride) {
      AppDelegate.getAppDelegate().log.debug("updateWithValuesFromNewRide()")
        super.updateWithValuesFromNewRide(newRide : newRide)
        let newRegularPassengerRide = newRide as! RegularPassengerRide
        self.regularRiderRideId = newRegularPassengerRide.regularRiderRideId
        self.riderId = newRegularPassengerRide.riderId
        self.riderName = newRegularPassengerRide.riderName
        self.points = newRegularPassengerRide.points
        self.pickupAddress = newRegularPassengerRide.pickupAddress
        self.pickupLatitude = newRegularPassengerRide.pickupLatitude
        self.pickupLongitude = newRegularPassengerRide.pickupLongitude
        self.dropAddress = newRegularPassengerRide.dropAddress
        self.dropLatitude = newRegularPassengerRide.dropLatitude
        self.dropLongitude = newRegularPassengerRide.dropLongitude
        self.pickupTime = newRegularPassengerRide.pickupTime
        self.dropTime = newRegularPassengerRide.dropTime
        self.rideType = Ride.REGULAR_PASSENGER_RIDE
    }
  public override func copy(with zone: NSZone? = nil) -> Any {
    let regularPassengerRide =  RegularPassengerRide(regularPassengerRide: self)
    regularPassengerRide.rideType = Ride.REGULAR_PASSENGER_RIDE
    return regularPassengerRide
  }
    override func prepareRideStatusObject() -> RideStatus{
        
        let statusObj:RideStatus  = RideStatus(rideId: rideId, userId: userId, status: status, rideType: Ride.REGULAR_PASSENGER_RIDE)
        return statusObj
    }
}
