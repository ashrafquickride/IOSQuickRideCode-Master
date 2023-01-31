//
//  RiderRide.swift
//  Quickride
//
//  Created by KNM Rao on 11/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RiderRide : Ride {
    
    //var riderName : String?
    var vehicleNumber : String?
    var vehicleModel = Vehicle.VEHICLE_MODEL_HATCHBACK
    var farePerKm : Double = 0
    var noOfPassengers : Int = 0
    var availableSeats : Int = 0
    var capacity : Int = 0
    var riderPathTravelled : String?
    var additionalFacilities : String?
    var makeAndCategory : String?
    var riderHasHelmet = false
    var vehicleType : String?
    var vehicleId : Double = 0
    var vehicleImageURI : String?
    var freezeRide : Bool = false
    var cumulativeOverlapDistance : Double = 0
    var autoUnfreezeKey = false
    
    public static let NO_SEATS_AVAILABLE_IN_RIDE : Int = 2629;
    public static let PASSENGER_CANCELLED_RIDE_REQUEST : Int = 2630;
    public static let PASSENGER_ENGAGED_IN_OTHER_RIDE  : Int = 2631;
    public static let  FLD_FREEZE_Ride = "freezeRide";
    
    private var passengers  = [PassengerRide]()
    
    override init(){
        super.init()
        rideType = Ride.RIDER_RIDE
    }
    
    
    override init(ride:Ride) {
        super.init(ride: ride)
        self.rideType = Ride.RIDER_RIDE
    }
    
    required public init?(_ map: Map) {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    // Mappable
    override public func mapping(map: Map) {
        super.mapping(map: map)
        
        vehicleNumber <- map["vehicleNumber"]
        vehicleModel <- map["vehicleModel"]
        availableSeats <- map["availableSeats"]
        capacity <- map["capacity"]
        farePerKm  <- map["farePerKm"]
        noOfPassengers  <- map["noOfPassengers"]
        riderPathTravelled <- map["riderPathTravelled"]
        passengers <- map["passengers"]
        makeAndCategory <- map["vehicleMakeAndCategory"]
        additionalFacilities <- map["additionalFacilities"]
        vehicleType <- map["vehicleType"]
        if vehicleType == nil || vehicleType!.isEmpty{
            vehicleType = Vehicle.checkVehicleTypeFromModel(vehicleModel: vehicleModel)
        }
        checkVehicleTypeAndAssignFromModel()
        freezeRide <- map["freezeRide"]
        vehicleId <- map["vehicleId"]
        vehicleImageURI <- map["vehicleImageURI"]
        cumulativeOverlapDistance <- map["cumOverlapDist"]
        riderHasHelmet <- map["riderHasHelmet"]
        if rideType == nil{
            rideType = Ride.RIDER_RIDE
        }
    }
    func checkVehicleTypeAndAssignFromModel(){
        if vehicleType == nil || vehicleType!.isEmpty{
            
            if vehicleModel == Vehicle.BIKE_MODEL_CRUISE || vehicleModel == Vehicle.BIKE_MODEL_SPORTS || vehicleModel == Vehicle.BIKE_MODEL_REGULAR || vehicleModel == Vehicle.BIKE_MODEL_SCOOTER || vehicleModel == Vehicle.VEHICLE_TYPE_BIKE{
                vehicleType = Vehicle.VEHICLE_TYPE_BIKE
            }else{
                vehicleType = Vehicle.VEHICLE_TYPE_CAR
            }
        }
    }
    public override func copy(with zone: NSZone? = nil) -> Any
    {
        let riderRide =  RiderRide(ride: self)
        riderRide.promocode = nil
        riderRide.vehicleNumber  = self.vehicleNumber
        riderRide.vehicleModel = self.vehicleModel
        riderRide.farePerKm = self.farePerKm
        riderRide.noOfPassengers = self.noOfPassengers
        riderRide.availableSeats = self.availableSeats
        riderRide.capacity = self.capacity
        riderRide.vehicleType = self.vehicleType
        riderRide.freezeRide = self.freezeRide
        riderRide.vehicleId = self.vehicleId
        riderRide.vehicleImageURI = self.vehicleImageURI
        riderRide.cumulativeOverlapDistance = self.cumulativeOverlapDistance
        riderRide.riderPathTravelled = self.riderPathTravelled
        riderRide.additionalFacilities = self.additionalFacilities
        riderRide.makeAndCategory = self.makeAndCategory
        riderRide.riderHasHelmet = self.riderHasHelmet
        riderRide.rideType = Ride.RIDER_RIDE
        return riderRide
    }
    
    override func  prepareRideStatusObject() -> RideStatus{
        let statusObj:RideStatus  = RideStatus(rideId: rideId, userId: userId, status: status, rideType: Ride.RIDER_RIDE)
        return statusObj
    }
    public override var description: String {
        return "vehicleNumber: \(String(describing: self.vehicleNumber))," + "vehicleModel: \(String(describing: self.vehicleModel))," + " farePerKm: \( String(describing: self.farePerKm))," + " noOfPassengers: \(String(describing: self.noOfPassengers))," + " availableSeats: \(String(describing: self.availableSeats)),"
            + " capacity: \(String(describing: self.capacity))," + "riderPathTravelled: \(String(describing: self.riderPathTravelled))," + "additionalFacilities:\(String(describing: self.additionalFacilities))," + "makeAndCategory:\(String(describing: self.makeAndCategory))," + "riderHasHelmet:\(String(describing: self.riderHasHelmet))," + "vehicleType:\(String(describing: self.vehicleType))," + "vehicleId: \(String(describing: self.vehicleId))," + "vehicleImageURI: \( String(describing: self.vehicleImageURI))," + "freezeRide: \(String(describing: self.freezeRide))," + "cumulativeOverlapDistance: \( String(describing: self.cumulativeOverlapDistance))," + "autoUnfreezeKey: \(String(describing: self.autoUnfreezeKey)),"
    }
}
