//
//  ProductOrderInvoice.swift
//  Quickride
//
//  Created by QR Mac 1 on 10/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ProductOrderInvoice: Mappable {
    var orderInvoice: OrderInvoice?
    var invoiceItems = [ProductInvoice]()
    
    static let CREDIT = "CREDIT"
    static let DEBIT = "DEBIT"
    init?(map: Map) {
        
    }
    init() {
        
    }
    mutating func mapping(map: Map) {
        self.orderInvoice <- map["invoiceDTO"]
        self.invoiceItems <- map["invoiceItems"]
    }
}
