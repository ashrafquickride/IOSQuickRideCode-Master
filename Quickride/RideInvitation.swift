//
//  RideInvitation.swift
//  Quickride
//
//  Created by Anki on 14/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RideInvitation:NSObject,Mappable {
  
    static let rideInviteMessageClassName = "com.disha.quickride.domain.model.RideInvite"
    var rideInvitationId :Double = 0
    var rideId:Double = 0
    var riderId:Double = 0
    var passenegerRideId:Double = 0
    var passengerId:Double = 0
    var fromLoc:String?
    var toLoc:String?
    var startTime:Double = 0
    var pickupAddress: String?
    var pickupLatitude:Double = 0
    var pickupLongitude:Double = 0
    var pickupTime: Double = 0
    var dropAddress:String?
    var dropLatitude:Double = 0
    var dropLongitude:Double = 0
    var dropTime:Double = 0
    var matchedDistance:Double = 0
    var points : Double = 0
    var newFare : Double = -1
    var fareChange = false
    var invitingUserGender:String?
    var noOfSeats:Int = 1
    var rideType: String?
    var fromDate: String?
    var toDate: String?
    var invitationStatus: String?
    var invitingUserName : String?
    var invitingUserId : Double = 0
    var senderImgUri : String?
    var allowFareChange = true
    var riderHasHelmet = false
    var pickupTimeRecalculationRequired = true
    var matchPercentageOnPassengerRoute = 0
    var matchPercentageOnRiderRoute = 0
    var autoInvite = false
    var invitationTime = 0.0
    var passengerRequiresHelmet = false
    var riderPoints: Double = 0
    var newRiderFare: Double = 0

    static let FLD_RIDE_INVITATION_ID = "Invitation_id"
    static let RIDE_INVITATION_STATUS = "Invitation_status"
  
    static let RIDE_INVITATION_REJECT_REASON = "rejectReason"
    
    static let RIDE_INVITATION_STATUS_NEW = "New"
    static let RIDE_INVITATION_STATUS_ACCEPTED="Accepted"
    static let RIDE_INVITATION_STATUS_REJECTED="Rejected"
    static let RIDE_INVITATION_STATUS_RECEIVED="Received"
    static let RIDE_INVITATION_STATUS_READ="Read"
    static let RIDE_INVITATION_STATUS_FAILED="Failed"
    static let RIDE_INVITATION_STATUS_USER_JOINED_OTHER_RIDE="JoinedOtherRide"
    static let RIDE_INVITATION_STATUS_USER_JOINED_SAME_RIDE="JoinedSameRide"
    static let RIDE_INVITATION_STATUS_CANCELLED_RIDE="RideCancelled"
    static let RIDE_INVITATION_STATUS_COMPLETED_RIDE="RideCompleted"
    static let RIDE_INVITATION_STATUS_CANCELLED = "Cancelled"
    static let RIDE_INVITATION_STATUS_UNJOINED = "UnJoined"
    static let RIDE_INVITATION_STATUS_JOINED_SAME_RIDE = "JoinedSameRide"
    static let RIDE_INVITATION_STATUS_ACCEPTED_AND_RIDE_CANCELLED = "AcceptedAndRideCancelled"
    static let RIDE_INVITATION_STATUS_ACCEPTED_AND_PAYMENT_PENDING = "AcceptedAndPaymentPending"
    
    static let RIDE_INVITATION_LAST_UPDATED_TIME = "lastUpdatedTime"
    static let RIDE_INVITE_BULK = "rideInvite"
    static let MATCH_PERCENTAGE_PSGR = "matchPerOfPassenger"
    static let MATCH_PERCENTAGE_RIDER = "matchPerOfRider"
    static let RIDE_MODERATOR_ID = "rideModeratorId"
    
    override init() {
        
    }
    required public init(map:Map){
        
    }
    
    public func mapping(map:Map){
        rideInvitationId <- map["id"]
        rideId <- map["rideId"]
        riderId <- map["riderId"]
        passenegerRideId <- map["passengerRideId"]
        passengerId <- map["passengerId"]
        fromLoc <- map["fromLoc"]
        toLoc <- map["toLoc"]
        startTime <- map["startTime"]
        pickupAddress <- map["pickupAddress"]
        pickupLatitude <- map["pickupLatitude"]
        pickupLongitude <- map["pickupLongitude"]
        pickupTime <- map["pickupTime"]
        dropAddress <- map["dropAddress"]
        dropLatitude <- map["dropLatitude"]
        dropLongitude <- map["dropLongitude"]
        dropTime <- map["dropTime"]
        matchedDistance <- map["matchedDistance"]
        points <- map["points"]
        newFare <- map["newFare"]
        invitingUserGender <- map["invitingUserGender"]
        noOfSeats <- map["noOfSeats"]
        rideType <- map["rideType"]
        fromDate <- map["fromDate"]
        toDate <- map["toDate"]
        invitationStatus <- map["invitationStatus"]
        invitingUserId <- map["invitingUserId"]
        invitingUserName <- map["invitingUserName"]
        senderImgUri <- map["senderImgUri"]
        allowFareChange <- map["allowFareChange"]
        fareChange <- map["fareChange"]
        riderHasHelmet <- map["riderHasHelmet"]
        pickupTimeRecalculationRequired <- map["pickupTimeRecalculationRequired"]
        matchPercentageOnPassengerRoute <- map["matchPercentageOnPassengerRoute"]
        matchPercentageOnRiderRoute <- map["matchPercentageOnRiderRoute"]
        autoInvite <- map["autoInvite"]
        invitationTime <- map["invitationTime"]
        passengerRequiresHelmet <- map["passengerRequiresHelmet"]
        riderPoints <- map["riderPoints"]
        newRiderFare <- map["newRiderFare"]
    }
    func getParams() -> [String: String]{
      AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String: String] = [String : String]()
        params["id"] = String(describing: self.rideId)
        params["userId"] = String(describing: self.riderId)
        params["passengerRideId"] = String(describing: self.passenegerRideId)
        params["passengerId"] = String(describing: self.passengerId)
        params["pickupAddress"] = self.pickupAddress
        params["pickupLatitude"] =  String(describing: self.pickupLatitude)
        params["pickupLongitude"] = String(describing: self.pickupLongitude)
        params["dropAddress"] =  self.dropAddress
        params["dropLatitude"] = String(describing: self.dropLatitude)
        params["dropLongitude"] = String(describing: self.dropLongitude)
        params["distance"] = String(describing: self.matchedDistance)
        params["points"] = String(describing: self.points)
        params["newFare"] = String(self.newFare)
        params["availableSeats"] = String(describing: self.noOfSeats)
        params["gender"] = self.invitingUserGender
        params["rideType"] = self.rideType
        params["invitationStatus"] = self.invitationStatus
        params["fareChange"] = String(self.fareChange)
        params["allowFareChange"] = String(self.allowFareChange)
        params["riderHasHelmet"] = String(self.riderHasHelmet)
        params["riderPoints"] = String(self.riderPoints)
        params["newRiderFare"] = String(self.newRiderFare)
        return params
    }
    public override var description: String {
        return "rideInvitationId: \(String(describing: self.rideInvitationId))," + "rideId: \(String(describing: self.rideId))," + " riderId: \( String(describing: self.riderId))," + " passenegerRideId: \(String(describing: self.passenegerRideId))," + " passengerId: \(String(describing: self.passengerId)),"
            + " fromLoc: \(String(describing: self.fromLoc))," + "startTime: \(String(describing: self.startTime))," + "pickupAddress:\(String(describing: self.pickupAddress))," + "pickupLatitude:\(String(describing: self.pickupLatitude))," + "pickupLongitude:\(String(describing: self.pickupLongitude))," + "pickupTime:\(String(describing: self.pickupTime))," + "dropLatitude: \(String(describing: self.dropLatitude))," + "dropLongitude: \( String(describing: self.dropLongitude))," + "dropAddress: \(String(describing: self.dropAddress))," + "dropTime: \( String(describing: self.dropTime))," + "matchedDistance: \(String(describing: self.matchedDistance))," + "points: \( String(describing: self.points))," + "newFare:\(String(describing: self.newFare))," + "fareChange:\(String(describing: self.fareChange))," + "invitingUserGender: \(String(describing: self.invitingUserGender))," + "noOfSeats: \( String(describing: self.noOfSeats))," + "rideType: \(String(describing: self.rideType))," + "fromDate: \( String(describing: self.fromDate))," + "toDate: \(String(describing: self.toDate))," + "invitationStatus: \( String(describing: self.invitationStatus))," + "invitingUserName: \(String(describing: self.invitingUserName))," + " invitingUserId: \( String(describing: self.invitingUserId))," + " senderImgUri: \(String(describing: self.senderImgUri))," + " allowFareChange: \(String(describing: self.allowFareChange)),"
            + " riderHasHelmet: \(String(describing: self.riderHasHelmet))," + "pickupTimeRecalculationRequired: \(String(describing: self.pickupTimeRecalculationRequired))," + "matchPercentageOnPassengerRoute:\(String(describing: self.matchPercentageOnPassengerRoute))," + "matchPercentageOnRiderRoute: \(String(describing: self.matchPercentageOnRiderRoute))," + "autoInvite:\(String(describing: self.autoInvite))," + " invitationTime: \(invitationTime)" + "passengerRequiresHelmet:\(String(describing: self.passengerRequiresHelmet))" + "riderPoints:\(String(describing: self.riderPoints))" + "newRiderFare:\(String(describing: self.newRiderFare))"
    }
}
