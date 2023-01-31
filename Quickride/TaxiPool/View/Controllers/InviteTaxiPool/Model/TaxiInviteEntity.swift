//
//  TaxiInviteEntity.swift
//  Quickride
//
//  Created by Ashutos on 8/6/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiInviteEntity : NSObject,Mappable {
    //mandatory for sending a invite
    var id: String?
    var taxiShareId: Double?
    var invitingUserId: Double?
    var invitingRideId: Double?
    var invitingRideType: String?
    var invitedUserId: Double?
    var invitedRideId: Double?
    var invitedRideType: String?
    var overviewPolyLine:String?
    var fare:Double?
    var distance:Double?
    var finalDistance:Double?
    var pickupTime: Double?
    //optional while sending invite
    var status: String?
    var invitingUserName: String?
    var invitedUserName: String?
    var invitingUserImageURI: String?
    var invitedUserImageURI:String?
    var fromLat:Double?
    var fromLng: Double?
    var toLat: Double?
    var toLng: Double?
    var noOfSeats:Int?
    
    public override init() {
        super.init()
    }
    
    required init?(map: Map) {
           
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        taxiShareId <- map["taxiShareId"]
        invitingUserId <- map["invitingUserId"]
        invitingRideId <- map["invitingRideId"]
        invitingRideType <- map["invitingRideType"]
        invitedUserId <- map["invitedUserId"]
        invitedRideId <- map["invitedRideId"]
        invitedRideType <- map["invitedRideType"]
        status <- map["status"]
        invitingUserName <- map["invitingUserName"]
        invitedUserName <- map["invitedUserName"]
        invitingUserImageURI <- map["invitingUserImageURI"]
        invitedUserImageURI <- map["invitedUserImageURI"]
        fromLat <- map["fromLat"]
        fromLng <- map["fromLng"]
        toLat <- map["toLat"]
        toLng <- map["toLng"]
        overviewPolyLine <- map["overviewPolyLine"]
        fare <- map["fare"]
        distance <- map["distance"]
        finalDistance <- map["finalDistance"]
        pickupTime <- map["pickupTime"]
        noOfSeats <- map["noOfSeats"]
    }
    
    public override var description: String {
        return  "id: \(String(describing: self.id)),"
            + " taxiShareId: \(String(describing: self.taxiShareId)),"
            + " invitingUserId: \(String(describing: self.invitingUserId)),"
            + " invitingRideId: \(String(describing: self.invitingRideId)),"
            + " invitingRideType: \(String(describing: self.invitingRideType)),"
            + " invitedUserId: \(String(describing: self.invitedUserId)),"
            + " invitedRideId: \(String(describing: self.invitedRideId)),"
            + " invitedRideType: \(String(describing: self.invitedRideType)),"
            + " status: \(String(describing: self.status)),"
            + " invitingUserName: \(String(describing: self.invitingUserName)),"
            + " invitedUserName: \(String(describing: self.invitedUserName)),"
            + " invitingUserImageURI: \(String(describing: self.invitingUserImageURI)),"
            + " invitedUserImageURI: \(String(describing: self.invitedUserImageURI)),"
            + " fromLat: \(String(describing: self.fromLat)),"
            + "fromLng: \(String(describing: self.fromLng)),"
            + " toLat: \(String(describing: self.toLat)),"
            + " toLng: \(String(describing: self.toLng)),"
            + " overviewPolyLine: \(String(describing: self.overviewPolyLine)),"
            + " fare: \(String(describing: self.fare)),"
            + " distance: \(String(describing: self.distance)),"
            + " finalDistance: \(String(describing: self.finalDistance)),"
            + " pickupTime: \(String(describing: self.pickupTime)),"
            + " noOfSeats: \(String(describing: self.noOfSeats))"
    }
    
}
