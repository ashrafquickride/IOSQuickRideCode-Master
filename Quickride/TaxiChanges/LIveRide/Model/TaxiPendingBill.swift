//
//  TaxiPendingBill.swift
//  Quickride
//
//  Created by QR Mac 1 on 29/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiPendingBill: Mappable {
    
    var amountPending = 0.0
    var customerId = 0.0
    var totalAmount = 0.0
    
    init?(map: Map) {
        
    }
    init(amountPending: Double,customerId: Double,totalAmount: Double) {
        self.amountPending = amountPending
        self.customerId = customerId
        self.totalAmount = totalAmount
    }
    mutating func mapping(map: Map) {
        self.amountPending <- map["amountPending"]
        self.customerId <- map["customerId"]
        self.totalAmount <- map["totalAmount"]
    }
    var description: String {
        return "amountPending: \(String(describing: self.amountPending)),"
            + "customerId: \(String(describing: self.customerId)),"
            + "totalAmount: \(String(describing: self.totalAmount)),"
    }
}
