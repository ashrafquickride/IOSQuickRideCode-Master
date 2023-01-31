//
//  RideRiskAssessment.swift
//  Quickride
//
//  Created by QR Mac 1 on 30/07/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RideRiskAssessment: Mappable {
    
    var id: Double?
    var taxiRidePassengerId: Double?
    var taxiRideGroupId: Double?
    var type: String?
    var description: String?
    var status: String?
    var raisedTime: Double?
    var raisedBy: String?
    var raisedByRefId: Double?
    var resolvedTime: Double?
    var resolvedBy: String?
    var resolvedByRefId: Double?
    var resolveRemarks: String?
    var raisedUserType: String?
    
   static let customer = "Customer"
    
    init() {}
    
    init(type: String, description: String, taxiRideGroupId: Double, taxiRidePassengerId: Double, raisedBy: String, raisedByRefId: Double, raisedUserType: String){
        self.type = type
        self.description = description
        self.taxiRideGroupId = taxiRideGroupId
        self.taxiRidePassengerId = taxiRidePassengerId
        self.raisedBy = raisedBy
        self.raisedByRefId = raisedByRefId
        self.raisedUserType = raisedUserType
    }
    
    public required init?(map: Map) {
        
    }
    
    public func mapping(map: Map) {
        taxiRidePassengerId <- map["taxiRidePassengerId"]
        id <- map["id"]
        taxiRideGroupId <- map["taxiRideGroupId"]
        type <- map["type"]
        description <- map["description"]
        status <- map["status"]
        raisedTime <- map["raisedTime"]
        raisedBy <- map["raisedBy"]
        raisedByRefId <- map["raisedByRefId"]
        resolvedTime <- map["resolvedTime"]
        resolvedBy <- map["id"]
        resolvedByRefId <- map["resolvedByRefId"]
        resolveRemarks <- map["resolveRemarks"]
        raisedUserType <- map["raisedUserType"]
    }
    
    static let RISK_TYPE_DRIVER_NOT_ANSWRING = "DRIVER_NOT_ANSWRING"
    static let RISK_TYPE_DRIVER_REFUSAL = "DRIVER_REFUSAL"
    static let RISK_TYPE_CUSTOMER_RAISED = "CUSTOMER_RAISED_RISK"
    static let RISK_TYPE_DRIVER_DEMANDING_EXTRA_MONEY = "DRIVER_DEMANDING_EXTRA_MONEY"
    static let RISK_TYPE_CALL_ME_BACK_CUSTOMER = "CALL_ME_BACK_FROM_CUSTOMER"
    static let RISK_TYPE_AC_IS_NOT_ON = "AC_IS_NOT_ON"
    static let RISK_TYPE_DRIVER_DEVIATED_ROUTE = "DRIVER_DEVIATED_ROUTE"
    static let RISK_TYPE_DRIVER_NOT_MOVING = "DRIVER_NOT_MOVING"
    static let RISK_TYPE_DRIVER_ASKING_FOR_OFFLINE_BOOKING = "DRIVER_ASKING_FOR_DIRECT_OFFLINE_BOOKING"
    static let RISK_TYPE_PAYMENT_ISSUE = "PAYMENT_ISSUE"
    static let RISK_TYPE_CLARIFICATION = "I_NEED_CLARIFICATION"
    static let RISK_TYPE_ROUTE_CHANGE_REQUIRED = "ROUTE_CHANGE_REQUIRED"
    
}
