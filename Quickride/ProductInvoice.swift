//
//  ProductInvoice.swift
//  Quickride
//
//  Created by QR Mac 1 on 10/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ProductInvoice: Mappable {
    
    var amount = 0.0
    var creationDate = 0.0
    var errorCode: String?
    var invoiceId: String?
    var invoiceItemId: String?
    var modifiedDate = 0.0
    var operation = "CREDIT"
    var orderId = 0
    var payload: String?
    var paymentDate = 0.0
    var status = "OPEN"
    var transactionId: String?
    var type = "BOOKING"
    var userId = 0
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.amount <- map["amount"]
        self.creationDate <- map["creationDate"]
        self.errorCode <- map["errorCode"]
        self.invoiceId <- map["invoiceId"]
        self.invoiceItemId <- map["invoiceItemId"]
        self.modifiedDate <- map["modifiedDate"]
        self.operation <- map["operation"]
        self.orderId <- map["orderId"]
        self.payload <- map["payload"]
        self.paymentDate <- map["paymentDate"]
        self.status <- map["status"]
        self.transactionId <- map["transactionId"]
        self.type <- map["type"]
        self.userId <- map["userId"]
    }
    
}
