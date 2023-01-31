//
//  TaxiUserAdditionalPaymentDetails.swift
//  Quickride
//
//  Created by HK on 12/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiUserAdditionalPaymentDetails: Mappable {
    
    var id: String?
    var taxiGroupId = 0
    var customerId = 0
    var status: String?
    var amount = 0.0
    var paymentType: String?
    var fareType: String?
    var description: String?
    var creationDateMs = 0
    var modifiedDateMs = 0
    var taxiBookingId: String?
    
    static let STATUS_OPEN = "OPEN"
    static let STATUS_CANCELLED = "CANCELLED"
    static let STATUS_ACCEPTED = "ACCEPTED"
    static let STATUS_REJECTED = "REJECTED"
    static let STATUS_OPERATOR_ACCEPTED = "OPERATOR_ACCEPTED"
    static let STATUS_OPERATOR_REJECTED = "OPERATOR_REJECTED"
    
    static let PAYMENT_TYPE_CASH = "CASH"
    
    static let FIELD_ID = "id"
    static let FIELD_TAXI_GROUP_ID = "taxiGroupId"
    static let FIELD_CUSTOMER_ID = "customerId"
    static let FIELD_PARTNER_ID = "partnerId"
    static let FIELD_STATUS = "status"
    static let FIELD_AMOUNT = "amount"
    static let FIELD_PAYMENT_TYPE = "paymentType"
    static let FIELD_FARE_TYPE = "fareType"
    static let FIELD_DESCRIPTION = "description"
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.taxiGroupId <- map["taxiGroupId"]
        self.customerId <- map["customerId"]
        self.status <- map["status"]
        self.amount <- map["amount"]
        self.paymentType <- map["paymentType"]
        self.fareType <- map["fareType"]
        self.description <- map["description"]
        self.creationDateMs <- map["creationDateMs"]
        self.modifiedDateMs <- map["modifiedDateMs"]
        self.taxiBookingId <- map["taxiBookingId"]
    }
    
    var classDescription: String {
        return "id: \(String(describing: self.id)),"
            + "taxiGroupId: \(String(describing: self.taxiGroupId)),"
            + "customerId: \(String(describing: self.customerId))," + "status: \(String(describing: self.status)),"
            + "status: \(String(describing: self.status))," + "amount: \(String(describing: self.amount)),"
            + "fareType: \(String(describing: self.fareType))," + "description: \(String(describing: self.description)),"
            + "creationDateMs: \(String(describing: self.creationDateMs))," + "modifiedDateMs: \(String(describing: self.modifiedDateMs)),"
            + "taxiBookingId: \(String(describing: self.taxiBookingId)),"
    }
}
