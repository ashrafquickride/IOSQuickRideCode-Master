//
//  RegularRiderRide.swift
//  Quickride
//
//  Created by KNM Rao on 25/01/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RegularRiderRide : RegularRide{
  
    var vehicleNumber : String?
    var vehicleModel : String?
    var vehicleType : String?
    var farePerKm : Int = 0
    var availableSeats : Int = 0
    var noOfPassengers : Int = 0
    var additionalFacilities : String?
    var riderHasHelmet = false
    
    override init() {
        super.init()
        self.rideType = Ride.REGULAR_RIDER_RIDE
    }
    init(riderRide : RiderRide) {
        super.init(ride: riderRide)
        self.rideType = Ride.REGULAR_RIDER_RIDE
        self.vehicleModel = riderRide.vehicleModel
        self.vehicleType = riderRide.vehicleType
        self.vehicleNumber = riderRide.vehicleNumber
        self.riderHasHelmet = riderRide.riderHasHelmet
    }

    override init(ride: Ride) {
        super.init(ride: ride)
        self.rideType = Ride.REGULAR_RIDER_RIDE
    }
    
    init(regularRiderRide : RegularRiderRide) {
    super.init(ride: regularRiderRide)
    self.rideType = Ride.REGULAR_RIDER_RIDE
    
  }
    init(userId : Double, userName : String, startAddress : String, startLatitude : Double, startLongitude : Double, endAddress : String, endLatitude : Double, endLongitude : Double, dayType : String, startTime : Double, fromDate : Double, toDate : Double?, sunday : String?, monday : String?, tuesday : String?, wednesday : String?, thursday : String?, friday : String?, saturday : String?, vehicle : Vehicle){
        super.init(userId: userId, userName : userName, startAddress : startAddress, startLatitude : startLatitude, startLongitude : startLongitude, endAddress : endAddress, endLatitude : endLatitude, endLongitude : endLongitude, dayType : dayType, startTime : startTime, fromDate : fromDate, toDate : toDate, sunday : sunday, monday : monday, tuesday : tuesday, wednesday : wednesday, thursday : thursday, friday : friday, saturday : saturday, rideType : Ride.REGULAR_RIDER_RIDE)
        self.vehicleNumber = vehicle.registrationNumber
        self.vehicleModel = vehicle.vehicleModel
        self.availableSeats = vehicle.capacity
        self.farePerKm = Int(vehicle.fare)
        self.vehicleType = vehicle.vehicleType
        self.riderHasHelmet = vehicle.riderHasHelmet
    }
    required public init?(_ map: Map) {
       super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    override public func mapping(map: Map) {
        super.mapping(map: map)
        self.vehicleNumber <- map["vehicleNumber"]
        self.vehicleModel <- map["vehicleModel"]
        self.farePerKm <- map["farePerKm"]
        self.availableSeats <- map["availableSeats"]
        self.noOfPassengers <- map["noOfPassengers"]
        self.additionalFacilities <- map["additionalFacilities"]
        self.vehicleType <- map["vehicleType"]
        self.riderHasHelmet <- map["riderHasHelmet"]
      if vehicleType == nil || vehicleType!.isEmpty{
        vehicleType = Vehicle.checkVehicleTypeFromModel(vehicleModel: vehicleModel)
      }
        if rideType == nil{
          rideType = Ride.REGULAR_RIDER_RIDE
        }
    }
    override func getParams() -> [String : String] {
      AppDelegate.getAppDelegate().log.debug("getParams()")
        var params = super.getParams()
        params[Ride.FLD_VEHICLE_NUMBER] = vehicleNumber
        params[Ride.FLD_VEHICLE_MODEL] = vehicleModel
        params[Ride.FLD_AVAILABLE_SEATS] = String(availableSeats)
        params[Ride.FLD_FARE_KM] = String(farePerKm)
        params[Ride.FLD_VEHICLE_TYPE] = vehicleType
        params["riderHasHelmet"] = String(self.riderHasHelmet)
        return params
    }
  public override func copy(with zone: NSZone? = nil) -> Any
 {
    let regularRiderRide =  RegularRiderRide(regularRiderRide: self)
    regularRiderRide.vehicleNumber  = self.vehicleNumber
    regularRiderRide.vehicleModel = self.vehicleModel
    regularRiderRide.vehicleType = self.vehicleType
    regularRiderRide.farePerKm = self.farePerKm
    regularRiderRide.noOfPassengers = self.noOfPassengers
    regularRiderRide.availableSeats = self.availableSeats
    regularRiderRide.riderHasHelmet = self.riderHasHelmet
    regularRiderRide.rideType = Ride.REGULAR_RIDER_RIDE
    return regularRiderRide
  }
//    
//    override func prepareRideStatusObject() -> RideStatus{
//     
//        let statusObj:RideStatus  = RideStatus(rideId: rideId, userId: userId, status: status, rideType: Ride.REGULAR_RIDER_RIDE)
//        return statusObj
//    }
}
