//
//  PendingDue.swift
//  Quickride
//
//  Created by QR Mac 1 on 04/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct PendingDue: Mappable{
    
    var id = 0
    var userId = 0
    var date = 0
    var dueAmount = 0.0
    var paidAmount = 0.0
    var dueStatus: String?
    var addedBy: String?
    var remarks: String?
    var dueType: String?
    var refId: String?
    var dataObject: String?
    var creationDate = 0
    var modifiedDate = 0

    static let TXN_PREFIX = "DuePymt-"
    
    static let paymentType = "paymentType"
    static let dueIds = "dueIds"
    static let UPI_PAYMENT_ERROR_CODE = 1408
    
    static let Subscription = "Subscription"
    static let RidePayment = "RidePayment"
    static let TaxiPayment = "TaxiPayment"
    static let RideCompensationPayment  = "RideCompensationPayment"
    static let TaxiCompensationPayment  = "TaxiCompensationPayment"
    static let Recovery = "Recovery"
    
    init?(map: Map) {
        
    }
    
    init() {
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.userId <- map["userId"]
        self.date <- map["date"]
        self.dueAmount <- map["dueAmount"]
        self.paidAmount <- map["paidAmount"]
        self.dueStatus <- map["dueStatus"]
        self.addedBy <- map["addedBy"]
        self.remarks <- map["remarks"]
        self.dueType <- map["dueType"]
        self.refId <- map["refId"]
        self.dataObject <- map["dataObject"]
        self.creationDate <- map["creationDate"]
        self.modifiedDate <- map["modifiedDate"]
    }
    
    func getDueAmount() -> Double{
        return dueAmount - paidAmount
    }
}
