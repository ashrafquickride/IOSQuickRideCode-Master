//
//  CallHistory.swift
//  Quickride
//
//  Created by Admin on 09/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct CallHistory : Mappable {
    
    //MARK: Properties
    var id: String?
    var fromUserId: Double?
    var toUserId: Double?
    var status: String?
    var imageUri: String?
    var partnerName: String?
    var calltime: Double?
    var gender: String?
    var totalRide: String?
    
    //MARK: Constants
    static let INCOMING = "INCOMING"
    static let OUTGOING = "OUTGOING"
    
    init?(map: Map) {
    }
    
    //MARK: Mapping Method
    mutating func mapping(map: Map) {
        id <- map["id"]
        fromUserId <- map["fromUserId"]
        toUserId <- map["toUserId"]
        status <- map["status"]
        imageUri <- map["imageUri"]
        partnerName <- map["partnerName"]
        calltime <- map["calltime"]
        gender <- map["gender"]
        totalRide <- map["totalRide"]
    }
    
    
}
