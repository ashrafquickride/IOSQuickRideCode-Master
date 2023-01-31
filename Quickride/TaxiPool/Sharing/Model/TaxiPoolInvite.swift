//
//  TaxiPoolInvite.swift
//  Quickride
//
//  Created by HK on 18/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiPoolInvite: Mappable{
    
    var id: String?
    var taxiRideGroupId = 0
    var invitingUserId = 0
    var invitingRideId = 0
    var invitingRideType: String?
    var invitedUserId = 0
    var invitedRideId = 0
    var invitedRideType: String?
    var status: String?
    var invitingUserName: String?
    var invitedUserName: String?
    var invitingUserImageURI: String?
    var invitedUserImageURI: String?
    var invitingUserGender: String?
    var invitedUserGender: String?
    var fromLat = 0.0
    var fromLng = 0.0
    var toLat = 0.0
    var toLng = 0.0
    var overviewPolyLine: String?
    var minFare = 0.0
    var maxFare = 0.0
    var fixedFareRefId: String?
    var distance = 0.0
    var pickupTimeMs = 0
    var noOfSeats = 1
    
    static let TAXI_INVITE_STATUS_OPEN = "OPEN"
    static let TAXI_INVITE_STATUS_RECEIVED = "RECEIVED"
    static let TAXI_INVITE_STATUS_READ = "READ"
    static let TAXI_INVITE_STATUS_CANCEL = "CANCELLED"
    static let TAXI_INVITE_STATUS_ACCEPTED = "ACCEPTED"
    static let TAXI_INVITE_STATUS_REJECTED = "REJECTED"
    static let TAXI_INVITE_STATUS_JOINED_OTHER = "JOINED_OTHER"
    static let TAXI_INVITE_STATUS_JOINED_SAME = "JOINED_SAME"
    
    static let TAXI = "Taxi"
    
    init?(map: Map) {
        
    }
    
    init(taxiRideGroupId: Int,invitingUserId: Int,invitingRideId: Int,invitingRideType: String,invitedUserId: Int,invitedRideId: Int,invitedRideType: String,invitingUserName: String?,invitedUserName: String?,invitingUserImageURI: String?,invitedUserImageURI: String?,invitingUserGender: String?,invitedUserGender: String?,fromLat: Double,fromLng: Double,toLat: Double,toLng: Double,distance: Double,pickupTimeMs: Int,overviewPolyLine: String,minFare: Double,maxFare: Double) {
        self.taxiRideGroupId = taxiRideGroupId
        self.invitingUserId = invitingUserId
        self.invitingRideId = invitingRideId
        self.invitingRideType = invitingRideType
        self.invitedUserId = invitedUserId
        self.invitedRideId = invitedRideId
        self.invitedRideType = invitedRideType
        self.invitingUserName =  invitingUserName
        self.invitedUserName = invitedUserName
        self.invitingUserImageURI = invitingUserImageURI
        self.invitedUserImageURI = invitedUserImageURI
        self.invitingUserGender = invitingUserGender
        self.invitedUserGender = invitedUserGender
        self.fromLat = fromLat
        self.fromLng = fromLng
        self.toLat = toLat
        self.toLng = toLng
        self.distance = distance
        self.pickupTimeMs = pickupTimeMs
        self.overviewPolyLine = overviewPolyLine
        self.maxFare = maxFare
        self.minFare = minFare
    }
    
    init(taxiRideGroupId: Int,invitingUserId: Int,invitingRideId: Int,invitingRideType: String,invitedUserId: Int,invitedRideId: Int,invitedRideType: String,fromLat: Double,fromLng: Double,toLat: Double,toLng: Double,distance: Double,pickupTimeMs: Int,overviewPolyLine: String) {
        self.taxiRideGroupId = taxiRideGroupId
        self.invitingUserId = invitingUserId
        self.invitingRideId = invitingRideId
        self.invitingRideType = invitingRideType
        self.invitedUserId = invitedUserId
        self.invitedRideId = invitedRideId
        self.invitedRideType = invitedRideType
        self.fromLat = fromLat
        self.fromLng = fromLng
        self.toLat = toLat
        self.toLng = toLng
        self.distance = distance
        self.pickupTimeMs = pickupTimeMs
        self.overviewPolyLine = overviewPolyLine
    }
    
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.taxiRideGroupId <- map["taxiRideGroupId"]
        self.invitingUserId <- map["invitingUserId"]
        self.invitingRideId <- map["invitingRideId"]
        self.invitingRideType <- map["invitingRideType"]
        self.invitedUserId <- map["invitedUserId"]
        self.invitedRideId <- map["invitedRideId"]
        self.invitedRideType <- map["invitedRideType"]
        self.status <- map["status"]
        self.invitingUserName <- map["invitingUserName"]
        self.invitedUserName <- map["invitedUserName"]
        self.invitingUserImageURI <- map["invitingUserImageURI"]
        self.invitedUserImageURI <- map["invitedUserImageURI"]
        self.invitingUserGender <- map["invitingUserGender"]
        self.invitedUserGender <- map["invitedUserGender"]
        self.fromLat <- map["fromLat"]
        self.fromLng <- map["fromLng"]
        self.toLat <- map["toLat"]
        self.toLng <- map["toLng"]
        self.overviewPolyLine <- map["overviewPolyLine"]
        self.minFare <- map["minFare"]
        self.maxFare <- map["maxFare"]
        self.fixedFareRefId <- map["fixedFareRefId"]
        self.distance <- map["distance"]
        self.pickupTimeMs <- map["pickupTimeMs"]
        self.noOfSeats <- map["noOfSeats"]
    }
}
