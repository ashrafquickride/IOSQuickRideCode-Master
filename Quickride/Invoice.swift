//
//  Invoice.swift
//  Quickride
//
//  Created by QR Mac 1 on 25/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct Invoice: Mappable{
    var id: Int?
    var fromUserId: Int?
    var fromUserName: String?
    var refId: String? // passengerRide
    var sourceRefId: String? // riderRide
    var creationTime: NSDate?
    var toUserId: Int?
    var toUserName: String?
    var amount: Double? // cancellation amount 
    var serviceFee: Double?
    var netAmountPaid: Double?
    var tax: Double?
    
    var description: String?
    var status: String?
    var type: String?
    var action: String?
    
    //Ride related details
    var startLocation: String?
    var endLocation: String?
    var startTime: NSDate?
    var endTime: NSDate?
    var distance: Double?
    var unitFare: Double?
    var noOfSeats: Int?
    var updatedTime: NSDate?
        
    //Used for refund txn
    var parentId: Int?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map:Map){
        id <- map["id"]
        fromUserId <- map["fromUserId"]
        fromUserName <- map["fromUserName"]
        refId <- map["refId"]
        sourceRefId <- map["sourceRefId"]
        creationTime <- map["creationTime"]
        toUserId <- map["toUserId"]
        toUserName <- map["toUserName"]
        amount <- map["amount"]
        serviceFee <- map["serviceFee"]
        netAmountPaid <- map["netAmountPaid"]
        tax <- map["tax"]
        description <- map["description"]
        status <- map["status"]
        type <- map["type"]
        action <- map["action"]
        startLocation <- map["startLocation"]
        endLocation <- map["endLocation"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        distance <- map["distance"]
        unitFare <- map["unitFare"]
        noOfSeats <- map["noOfSeats"]
        updatedTime <- map["updatedTime"]
    }
}
