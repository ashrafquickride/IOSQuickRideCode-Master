//
//  OrderPayment.swift
//  Quickride
//
//  Created by QR Mac 1 on 13/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct OrderPayment: Mappable{
    
    var orderId: String?
    var paymentStatus = [PaymentStatus]()
    
    init() {}
    init?(map: Map) {
        
    }
    static let BOOKING = "BOOKING"
    static let DEPOSIT = "DEPOSIT"
    static let FINAL = "FINAL"
    static let DAMAGE = "DAMAGE"
    static let RENT = "RENT"
    static let SERVICE_FEE = "SERVICE_FEE"
    static let CANCELLATION_CHARGES = "CANCELLATION_CHARGES"
    static let REFUND = "REFUND"
    static let TAX = "TAX"
    static let CREDIT = "CREDIT"
    
    static let OPEN = "OPEN"
    static let COMPLETE = "COMPLETE"
    
    mutating func mapping(map: Map) {
        self.orderId <- map["orderId"]
        self.paymentStatus <- map["paymentStatus"]
    }
}
