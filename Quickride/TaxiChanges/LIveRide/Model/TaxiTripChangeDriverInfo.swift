//
//  TaxiTripChangeDriverInfo.swift
//  Quickride
//
//  Created by Rajesab on 26/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiTripChangeDriverInfo: Mappable{
    var id: Double?
    var customerId:Double?
    var taxiRideGroupId:Double?
    var taxiRidePassengerId:Double?
    var reason:String?
    var status:String?
    var driverChangeStatus:String?
    var allocationCount:Int?
    var creationTimeInMs:Double?
    var modifiedTimeInMs:Double?
    var maxTimesAllowed:Int?
    
     static let FIELD_DRIVER_CHANGE_STATUS_ACTIVE = "Active"
     static let FIELD_DRIVER_CHANGE_STATUS_CANCELLED = "Cancelled"
     static let DRIVER_CHANGE_STATUS_REQUESTED = "Requested"
     static let DRIVER_CHANGE_STATUS_NEW_DRIVER_ALLOTTED = "NewDriverAllotted"
    
     init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.customerId <- map["customerId"]
        self.taxiRideGroupId <- map["taxiRideGroupId"]
        self.taxiRidePassengerId <- map["taxiRidePassengerId"]
        self.reason <- map["reason"]
        self.status <- map["status"]
        self.driverChangeStatus <- map["driverChangeStatus"]
        self.allocationCount <- map["allocationCount"]
        self.creationTimeInMs <- map["creationTimeInMs"]
        self.modifiedTimeInMs <- map["modifiedTimeInMs"]
        self.maxTimesAllowed <- map["maxTimesAllowed"]
    }
    
    var description: String{
        return "id: \(String(describing: self.id))"
            + "customerId: \(String(describing: self.customerId))"
            + "taxiRideGroupId: \(String(describing: self.taxiRideGroupId))"
            + "taxiRidePassengerId: \(String(describing: self.taxiRidePassengerId))"
            + "reason: \(String(describing: self.reason))"
            + "status: \(String(describing: self.status))"
            + "driverChangeStatus: \(String(describing: self.driverChangeStatus))"
            + "allocationCount: \(String(describing: self.allocationCount))"
            + "creationTimeInMs: \(String(describing: self.creationTimeInMs))"
            + "modifiedTimeInMs: \(String(describing: self.modifiedTimeInMs))"
            + "maxTimesAllowed: \(String(describing: self.maxTimesAllowed))"
    }
}
