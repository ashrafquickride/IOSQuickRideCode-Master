//
//  OrderInvoice.swift
//  Quickride
//
//  Created by QR Mac 1 on 10/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct OrderInvoice: Mappable {
    
    var creationDate = 0.0
    var fromUserId = 0
    var invoiceId: String?
    var listingId: String?
    var modifiedDate = 0.0
    var orderId: String?
    var requestId: String?
    var status = "OPEN"
    var toUserId = 0
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.creationDate <- map["creationDate"]
        self.fromUserId <- map["fromUserId"]
        self.invoiceId <- map["invoiceId"]
        self.listingId <- map["listingId"]
        self.modifiedDate <- map["modifiedDate"]
        self.orderId <- map["orderId"]
        self.requestId <- map["requestId"]
        self.status <- map["status"]
        self.toUserId <- map["toUserId"]
    }
}
