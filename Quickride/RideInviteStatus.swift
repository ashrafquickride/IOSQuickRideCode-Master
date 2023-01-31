//
//  RideInviteStatus.swift
//  Quickride
//
//  Created by QuickRideMac on 10/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RideInviteStatus : NSObject,Mappable{
    
    public static let RIDE_INIVTE_STATUS = "rideInviteStatus"
    
    var invitationId : Double = 0
    var invitationStatus : String?
    var riderRideId : Double = 0
    var passengerRideId : Double = 0
    var riderUserId : Double = 0
    var passengerUserId : Double = 0
    var rideType : String?
    
    override init(){
        
    }
    init(rideInvitation : RideInvitation) {
    self.invitationId = rideInvitation.rideInvitationId
    self.invitationStatus = rideInvitation.invitationStatus
    self.riderRideId = rideInvitation.rideId
    self.passengerRideId = rideInvitation.passenegerRideId
    self.riderUserId = rideInvitation.riderId
    self.passengerUserId = rideInvitation.passengerId
    self.rideType = rideInvitation.rideType
    }
    
    init(invitationId : Double, invitationStatus : String?, riderRideId : Double, passengerRideId : Double, riderUserId : Double, passengerUserId : Double, rideType : String?){
        self.invitationId = invitationId
        self.invitationStatus = invitationStatus
        self.riderRideId = riderRideId
        self.passengerRideId = passengerRideId
        self.riderUserId = riderUserId
        self.passengerUserId = passengerUserId
        self.rideType = rideType
    }
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        self.invitationId <- map["invitationId"]
        self.invitationStatus <- map["invitationStatus"]
        self.riderRideId <- map["riderRideId"]
        self.passengerRideId <- map["passengerRideId"]
        self.riderUserId <- map["riderUserId"]
        self.passengerUserId <- map["passengerUserId"]
        self.rideType <- map["rideType"]
    }
    public override var description: String {
        return "invitationId: \(String(describing: self.invitationId))," + "invitationStatus: \(String(describing: self.invitationStatus))," + " riderRideId: \( String(describing: self.riderRideId))," + " passengerRideId: \(String(describing: self.passengerRideId))," + " riderUserId: \(String(describing: self.riderUserId)),"
            + " passengerUserId: \(String(describing: self.passengerUserId))," + "rideType: \(String(describing: self.rideType)),"
    }
}
