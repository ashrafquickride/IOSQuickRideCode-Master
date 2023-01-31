//
//  RideParticipant.swift
//  Quickride
//
//  Created by KNM Rao on 11/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RideParticipant : NSObject, Mappable {
    
    var riderRideId : Double = 0
    var userId : Double = 0
    var rideId : Double = 0
    var name : String?
    var imageURI : String?
    var rider : Bool = false
    var startPoint : LatLng?
    var endPoint : LatLng?
    var startAddress : String?
    var endAddress : String?
    var status = Ride.RIDE_STATUS_SCHEDULED
    var gender : String?
    var callSupport : String?
    var noOfSeats: Int = 1
    var pickUpTime : Double?
    var dropTime : Double?
    var points : Double?
    var crossedPickup = false
    var rideNote : String?
    var noOfRidesShared : Int?
    var enableChatAndCall : Bool = true   
    var autoConfirm : String?
    var insurancePoints : Double?
    var insurancePolicyUrl : String?
    var rideModerationEnabled = false
    var pickupNote: String?
    var distanceFromRiderStartToPickUp: Double = 0
    var hasOverlappingRoute = true
    var otpRequiredToPickup = false
    
    public static let DRIVER : Bool = true
    public static let PASSENGER : Bool = false
    
    public static let PARTICIPANT_TYPE : String = "PARTICIPANT_TYPE";
    public static let PARTICIPANT_TYPE_PASSENGER : String = "PASSENGER";
    public static let PARTICIPANT_TYPE_RIDER : String = "RIDER";
    public static let RIDE_PARTICIPANT_ID : String = "RIDE_PARTICIPANT_ID";
    public static let RIDE_PARTICIPANT_STATUS : String = "RIDE_PARTICIPANT_STATUS";
    
    override init(){
        
    }
    
    public required init?(map: Map) {
        
    }
    public init(rideId : Double, participantId : Double, participantName : String, gender : String,isDriver :Bool, pickupLocation : String?, dropLocation : String?, imageURI: String?, status: String?, startPoint : LatLng?,endPoint :LatLng?, callSupport : String, noOfSeats: Int) {
        self.rideId = rideId
        self.userId = participantId
        self.name = participantName
        self.gender = gender
        self.rider = isDriver
        self.startAddress = pickupLocation
        self.endAddress = dropLocation
        self.imageURI = imageURI
        if status != nil{
            self.status = status!
        }
        
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.callSupport = callSupport
        self.noOfSeats = noOfSeats
    }
    
    public func mapping(map: Map) {
        userId <- map["userId"]
        rideId <- map["rideId"]
        name <- map["name"]
        imageURI <- map["imageURI"]
        rider <- map["rider"]
        startPoint <- map["startPoint"]
        endPoint <- map["endPoint"]
        startAddress <- map["startAddress"]
        endAddress <- map["endAddress"]
        status <- map["status"]
        gender <- map["gender"]
        callSupport <- map["callSupport"]
        noOfSeats <- map["noOfSeats"]
        points <- map["points"]
        pickUpTime <- map["pickUpTime"]
        dropTime <- map["dropTime"]
        riderRideId <- map["riderRideId"]
        rideNote <- map["rideNote"]
        noOfRidesShared <- map["noOfRidesShared"]
        enableChatAndCall <- map["enableChatAndCall"]
        if UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus != 0 && enableChatAndCall{
            enableChatAndCall = true
        }
        autoConfirm <- map["autoConfirmRides"]
        insurancePoints <- map["insurancePoints"]
        insurancePolicyUrl <- map["insurancePolicyUrl"]
        rideModerationEnabled <- map["rideModerationEnabled"]
        pickupNote <- map["pickupNote"]
        hasOverlappingRoute <- map["hasOverlappingRoute"]
        otpRequiredToPickup <- map["otpRequiredToPickup"]
        
    }
    func getRideStatus() -> RideStatus{
        
        let rideStatus = RideStatus()
        rideStatus.rideId = rideId
        rideStatus.userId = userId
        rideStatus.status = status
        if rider{
            rideStatus.rideType = Ride.RIDER_RIDE
        }else{
            rideStatus.rideType = Ride.PASSENGER_RIDE
        }
        return rideStatus
    }
    func isCallOptionEnabled() -> Bool
    {
        if !enableChatAndCall {
            return false
        }
        if UserProfile.SUPPORT_CALL_NEVER == callSupport {
            return false
        } else {
            return true
        }
    }
    public override var description: String {
        return "riderRideId: \(String(describing: self.riderRideId))," + "userId: \(String(describing: self.userId))," + " rideId: \( String(describing: self.rideId))," + " name: \(String(describing: self.name))," + " imageURI: \(String(describing: self.imageURI))," + " rider: \(String(describing: self.rider))," + "startPoint: \(String(describing: self.startPoint))," + "endPoint:\(String(describing: self.endPoint))," + "startAddress:\(String(describing: self.startAddress))," + "endAddress:\(String(describing: self.endAddress))," + "status:\(String(describing: self.status))," + "gender: \(String(describing: self.gender))," + "callSupport: \( String(describing: self.callSupport))," + "noOfSeats: \(String(describing: self.noOfSeats))," + "pickUpTime: \( String(describing: self.pickUpTime))," + "points: \(String(describing: self.points))," + "crossedPickup: \( String(describing: self.crossedPickup))," + "rideNote:\(String(describing: self.rideNote))," + "noOfRidesShared: \(String(describing: self.noOfRidesShared))," + "enableChatAndCall: \( String(describing: self.enableChatAndCall))," + "autoConfirm: \(String(describing: self.autoConfirm))," + "pickupNote: \(String(describing: pickupNote))," + "rideModerationEnabled: \(String(describing: rideModerationEnabled))," + "otpRequiredToPickup: \(String(describing: otpRequiredToPickup))," + "hasOverlappingRoute: \(String(describing: hasOverlappingRoute))"
    }
}
