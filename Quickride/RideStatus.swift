//
//  RideStatus.swift
//  Quickride
//
//  Created by KNM Rao on 11/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideStatus :QuickRideMessageEntity{

    var rideId : Double = 0
    var userId : Double = 0
    var status : String?
    var rideType : String?
    var joinedRideId : Double = 0
    var joinedRideStatus : String?
    var joinedRideType: String?
    var scheduleTime : Double?
    var rescheduleTime : Double?
    var pickupTime : Double?
    var dropTime : Double?
    var noOfSeats : Int = 1
    var distanceJoined = 0.0
 
    
    override init(){
        super.init()
    }
    
    init(rideId : Double, userId : Double, status : String, rideType : String){
        super.init()
        self.rideId = rideId
        self.userId = userId
        self.status = status
        self.rideType = rideType
    }
    
    init(rideId : Double, userId : Double, status : String, rideType : String, joinedRideId : Double?, joinedRideStatus : String?){
        super.init()
        self.rideId = rideId
        self.userId = userId
        self.status = status
        self.rideType = rideType
        if joinedRideId != nil{
            self.joinedRideId = joinedRideId!
        }
        
        self.joinedRideStatus = joinedRideStatus
    }
    init( rideId :Double, userId:Double,  status : String, rideType : String, scheduleTime : Double, rescheduledTime :Double) {
        super.init()
        self.rideId = rideId
        self.userId = userId
        self.status = status
        self.rideType = rideType
        self.scheduleTime = scheduleTime
        self.rescheduleTime = rescheduledTime
        
    }
    init( ride :Ride) {
        super.init()
        self.rideId = ride.rideId
        self.userId = ride.userId
        self.status = ride.status
        self.rideType = ride.rideType
        if let passengerRide = ride as? PassengerRide{
            self.joinedRideId = passengerRide.riderRideId
            self.pickupTime = passengerRide.pickupTime
            self.dropTime = passengerRide.dropTime
            self.noOfSeats = passengerRide.noOfSeats

        }
    }

    required init?(_ map: Map) {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        rideId <- map["rideId"]
        userId <- map["userId"]
        status <- map["status"]
        rideType <- map["rideType"]
        joinedRideId <- map["joinedRideId"]
        noOfSeats <- map["noOfSeats"]
        scheduleTime <- map["scheduleTime"]
        rescheduleTime <- map["rescheduleTime"]
        distanceJoined <- map["distanceJoined"]
        pickupTime <- map["pickupTime"]
        dropTime <- map["dropTime"]
        joinedRideType <- map["joinedRideType"]
        
    }
    
    func isCheckInRideAllowed() -> Bool{
        
        AppDelegate.getAppDelegate().log.debug("isCheckInRideAllowed()")
        return ((Ride.PASSENGER_RIDE == self.rideType) && ((Ride.RIDE_STATUS_SCHEDULED == self.status) || Ride.RIDE_STATUS_DELAYED == self.status))
    }
    
    func isCancelRideAllowed() -> Bool{
        AppDelegate.getAppDelegate().log.debug("isCancelRideAllowed()")
        return  !( Ride.RIDE_STATUS_CANCELLED == self.status
            || Ride.RIDE_STATUS_COMPLETED == self.status
            || Ride.RIDE_STATUS_ARCHIVED == self.status )
        
    }
    func isRescheduleAllowed() -> Bool{
        AppDelegate.getAppDelegate().log.debug("isRescheduleAllowed()")
        return  !( Ride.RIDE_STATUS_CANCELLED == self.status
            || Ride.RIDE_STATUS_COMPLETED == self.status
            || Ride.RIDE_STATUS_ARCHIVED == self.status
            || Ride.RIDE_STATUS_STARTED == self.status || ((Ride.RIDE_STATUS_SCHEDULED == self.status || Ride.RIDE_STATUS_DELAYED == self.status) && rideType == Ride.PASSENGER_RIDE))
    }
    
    func isCheckOutRideAllowed() -> Bool{
        AppDelegate.getAppDelegate().log.debug("isCheckOutRideAllowed()")
        return ( Ride.PASSENGER_RIDE == self.rideType
            && Ride.RIDE_STATUS_STARTED == self.status)
        
    }
    
    func isStartRideAllowed() -> Bool{
        AppDelegate.getAppDelegate().log.debug("isStartRideAllowed()")
        if Ride.RIDER_RIDE != self.rideType{
            return false
        }
        if (Ride.RIDE_STATUS_SCHEDULED == self.status
            ||  Ride.RIDE_STATUS_DELAYED == self.status){
            return true
        }else{
            return false
        }
    }
    
    func isStopRideAllowed() -> Bool{
        AppDelegate.getAppDelegate().log.debug("isStopRideAllowed()")
        if Ride.RIDER_RIDE != self.rideType {
            return false
        }
        if Ride.RIDE_STATUS_STARTED == self.status{
            return true
        }else{
            return false
        }
    }
    
    func isDelayedCheckinAllowed() -> Bool{
        AppDelegate.getAppDelegate().log.debug("isDelayedCheckinAllowed()")
        return (  Ride.PASSENGER_RIDE == self.rideType
            && (Ride.RIDE_STATUS_SCHEDULED == self.status
                || Ride.RIDE_STATUS_DELAYED == self.status)
            && ( Ride.RIDE_STATUS_SCHEDULED == self.joinedRideStatus
                || Ride.RIDE_STATUS_DELAYED == self.joinedRideStatus))
    }
    
//    func joinedRiderRide(joinedRideId : Double,joinedRideStatus : String){
//        AppDelegate.getAppDelegate().log.debug("joinedRiderRide() \(joinedRideId) \(joinedRideStatus)")
//        self.joinedRideId = joinedRideId
//        self.joinedRideStatus = joinedRideStatus
//    }
    
//    func unJoinedRiderRide() {
//        AppDelegate.getAppDelegate().log.debug("unJoinedRiderRide()")
//        self.joinedRideId = 0
//        self.joinedRideStatus = nil
//    }
    
    func isValidStatusChange( newStatus : String) -> Bool
    {
        var isValidTransition = false
        switch (status!) {
        case Ride.RIDE_STATUS_REQUESTED,PassengerRide.RIDE_STATUS_PENDING_TAXI_JOIN :
            if newStatus == Ride.RIDE_STATUS_SCHEDULED ||
                newStatus == Ride.RIDE_STATUS_CANCELLED {
                isValidTransition = true
            }
            break;
        case Ride.RIDE_STATUS_SCHEDULED :
            if newStatus == Ride.RIDE_STATUS_STARTED ||
                newStatus == Ride.RIDE_STATUS_DELAYED ||
                newStatus == Ride.RIDE_STATUS_CANCELLED ||
                newStatus == Ride.RIDE_STATUS_BREAKDOWN {
                isValidTransition = true
            }
            else if newStatus == Ride.RIDE_STATUS_REQUESTED &&
                rideType == Ride.PASSENGER_RIDE {
                isValidTransition = true
            }
            break;
        case Ride.RIDE_STATUS_STARTED :
            if newStatus == Ride.RIDE_STATUS_COMPLETED ||
                newStatus == Ride.RIDE_STATUS_BREAKDOWN {
                isValidTransition = true
            }
            else if newStatus == Ride.RIDE_STATUS_REQUESTED || newStatus == Ride.RIDE_STATUS_CANCELLED {
                isValidTransition = true
            }
            break;
        case Ride.RIDE_STATUS_DELAYED :
            if newStatus == Ride.RIDE_STATUS_STARTED ||
                newStatus == Ride.RIDE_STATUS_CANCELLED ||
                newStatus == Ride.RIDE_STATUS_BREAKDOWN {
                isValidTransition = true
            }
            else if newStatus == Ride.RIDE_STATUS_REQUESTED &&
                rideType == Ride.PASSENGER_RIDE {
                isValidTransition = true
            }
            break;
        case Ride.RIDE_STATUS_BREAKDOWN :
            if newStatus == Ride.RIDE_STATUS_STARTED ||
                newStatus == Ride.RIDE_STATUS_CANCELLED {
                isValidTransition = true;
            }
        case Ride.RIDE_STATUS_CANCELLED :
            if newStatus == Ride.RIDE_STATUS_ARCHIVED ||
                newStatus == Ride.RIDE_STATUS_ARCHIVE_CANCELLED {
                isValidTransition = true;
            }
            break;
        case Ride.RIDE_STATUS_COMPLETED :
            if newStatus == Ride.RIDE_STATUS_ARCHIVED ||
                newStatus == Ride.RIDE_STATUS_ARCHIVE_COMPLETED {
                isValidTransition = true;
            }
            break;
            
        default :
            break;
        }
        return isValidTransition;
    }
}


