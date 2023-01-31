//
//  RefundNotification.swift
//  Quickride
//
//  Created by Vinutha on 23/07/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct RefundNotification: Mappable{
    
    var accountId: String?
    var riderId: String?
    var points: String?
    var invoiceId: String?
    var name: String?
    var passengerRideId:String?
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        accountId <- map["accountid"]
        riderId <- map["riderId"]
        points <- map["points"]
        invoiceId <- map["invoiceId"]
        name <- map["name"]
        passengerRideId <- map["passengerRideId"]
    }
}
