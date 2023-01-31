//
//  PassengerRide.swift
//  Quickride
//
//  Created by KNM Rao on 12/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class PassengerRide : Ride {
    
    var riderId : Double = 0.0
    var riderName : String = ""
    var points : Double = 0.0
    var newFare : Double = -1
    var pickupAddress : String = ""
    var pickupLatitude : Double = 0.0
    var pickupLongitude : Double = 0.0
    var overLappingDistance : Double = 0.0
    var pickupTime : Double = 0.0
    var dropAddress : String = ""
    var dropLatitude : Double = 0.0
    var dropLongitude : Double = 0.0
    var dropTime : Double = 0.0
    var pickupAndDropRoutePolyline : String = ""
    var riderRideId:Double = 0.0
    var noOfSeats: Int = 1
    var pickupNote: String?
    var taxiRideId: Double?
    var tempTaxiRideId: Double?
    var parentId = 0
    var relayLeg = 0
    static let RIDE_STATUS_PENDING_TAXI_JOIN = "PendingTaxiJoin"

    static let PREFERRED_RIDER = "preferredRider"
    
    override init() {
        super.init()
        self.rideType = Ride.PASSENGER_RIDE
    }
    override init(taxiRide: TaxiRidePassenger){
        super.init(taxiRide: taxiRide)
    }
    override init(ride : Ride) {
        super.init(ride : ride)
        self.rideType = Ride.PASSENGER_RIDE
    }
    
    required public init(_ map: Map) {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    override public func mapping(map: Map) {
        super.mapping(map: map)
        riderRideId    <- map["rideId"]
        riderId         <- map["riderId"]
        riderName      <- map["riderName"]
        points       <- map["points"]
        newFare <- map["newFare"]
        pickupAddress  <- map["pickupAddress"]
        pickupLatitude  <- map["pickupLatitude"]
        pickupLongitude     <- map["pickupLongitude"]
        overLappingDistance     <- map["overLappingDistance"]
        pickupTime     <- map["pickupTime"]
        dropAddress     <- map["dropAddress"]
        dropLatitude     <- map["dropLatitude"]
        dropLongitude     <- map["dropLongitude"]
        dropTime     <- map["dropTime"]
        pickupAndDropRoutePolyline     <- map["pickupAndDropRoutePolyline"]
        noOfSeats <- map["noOfSeats"]
        tempTaxiRideId <- map["taxiRideId"]
        parentId <- map["parentId"]
        relayLeg <- map["relayLeg"]
        if rideType == nil {
            rideType = Ride.PASSENGER_RIDE
        }
        self.pickupNote <- map["pickupNote"]
    }
    
    override func updateWithValuesFromNewRide( newRide : Ride) {
        AppDelegate.getAppDelegate().log.debug("updateWithValuesFromNewRide()")
        super.updateWithValuesFromNewRide(newRide: newRide)
        let newPsgrRide = newRide as! PassengerRide
        self.rideId = newPsgrRide.rideId
        self.riderId = newPsgrRide.riderId
        self.riderName = newPsgrRide.riderName
        self.points = newPsgrRide.points
        self.rideType = Ride.PASSENGER_RIDE
        self.noOfSeats = newPsgrRide.noOfSeats
        self.pickupAddress = newPsgrRide.pickupAddress
        self.pickupLatitude = newPsgrRide.pickupLatitude
        self.pickupLongitude = newPsgrRide.pickupLongitude
        self.pickupTime = newPsgrRide.pickupTime
        self.overLappingDistance = newPsgrRide.overLappingDistance
        self.dropAddress = newPsgrRide.dropAddress
        self.dropLatitude = newPsgrRide.dropLatitude
        self.dropLongitude = newPsgrRide.dropLongitude
        self.dropTime = newPsgrRide.dropTime
        self.pickupAndDropRoutePolyline = newPsgrRide.pickupAndDropRoutePolyline
        self.newFare = newPsgrRide.newFare
        self.taxiRideId = newPsgrRide.taxiRideId
        self.parentId = newPsgrRide.parentId
        self.relayLeg = newPsgrRide.relayLeg
    }
    public override func copy(with zone: NSZone? = nil) -> Any {
        let passengerRide =  PassengerRide(ride: self)
        passengerRide.riderId = self.riderId
        passengerRide.riderName = self.riderName
        passengerRide.points = self.points
        passengerRide.newFare = self.newFare
        passengerRide.pickupAddress = self.pickupAddress
        passengerRide.pickupLatitude = self.pickupLatitude
        passengerRide.pickupLongitude = self.pickupLongitude
        passengerRide.overLappingDistance = self.overLappingDistance
        passengerRide.pickupTime = self.pickupTime
        passengerRide.dropAddress = self.dropAddress
        passengerRide.dropLatitude  = self.dropLatitude
        passengerRide.dropLongitude  = self.dropLongitude
        passengerRide.dropTime  = self.dropTime
        passengerRide.pickupAndDropRoutePolyline  = self.pickupAndDropRoutePolyline
        passengerRide.riderRideId = self.riderRideId
        passengerRide.noOfSeats = self.noOfSeats
        passengerRide.promocode = nil
        passengerRide.rideType = Ride.PASSENGER_RIDE
        passengerRide.pickupNote = self.pickupNote
        passengerRide.taxiRideId = self.taxiRideId
        passengerRide.parentId = self.parentId
        passengerRide.relayLeg = self.relayLeg
        return passengerRide
    }
    
    override func  prepareRideStatusObject() -> RideStatus{
        
        let statusObj:RideStatus  = RideStatus(rideId: rideId, userId: userId, status: status, rideType:  Ride.PASSENGER_RIDE)
        return statusObj
    }
    
    public override var description: String {
        return "riderId: \(String(describing: self.riderId))," + "riderName: \(String(describing: self.riderName))," + " points: \(String(describing: self.points))," + " newFare: \(String(describing: self.newFare))," + " pickupAddress: \(String(describing: self.pickupAddress))," + " pickupLatitude: \(String(describing: self.pickupLatitude))," + "pickupLongitude: \(String(describing: self.pickupLongitude))," + "overLappingDistance:\(String(describing: self.overLappingDistance))," + "pickupTime:\(String(describing: self.pickupTime))," + "dropAddress:\(String(describing: self.dropAddress))," + "dropLatitude:\(String(describing: self.dropLatitude))," + "dropLongitude: \(String(describing: self.dropLongitude))," + "dropTime: \( String(describing: self.dropTime))," + "pickupAndDropRoutePolyline: \(String(describing: self.pickupAndDropRoutePolyline))," + "riderRideId: \( String(describing: self.riderRideId))," + "noOfSeats: \(String(describing: self.noOfSeats))," + "pickupNote: \(String(describing: self.pickupNote))" + "taxiRideId: \(String(describing: self.taxiRideId))" + "parentId: \(String(describing: self.parentId))" + "relayLeg: \(String(describing: self.relayLeg))"
    }
}
