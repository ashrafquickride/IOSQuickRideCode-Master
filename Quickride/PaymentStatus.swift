//
//  PaymentStatus.swift
//  Quickride
//
//  Created by QR Mac 1 on 13/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct PaymentStatus: Mappable{ 
    
    var amount = 0.0
    var paid = 0.0
    var payingUserId = 0
    var pending = 0.0
    var status: String?
    var type: String?
    var paymentInProgress = false
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.amount <- map["amount"]
        self.paid <- map["paid"]
        self.payingUserId <- map["payingUserId"]
        self.pending <- map["pending"]
        self.status <- map["status"]
        self.type <- map["type"]
        self.paymentInProgress <- map["paymentInProgress"]
    }
}
