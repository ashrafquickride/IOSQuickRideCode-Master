//
//  TaxiPassengerStatusUpdate.swift
//  Quickride
//
//  Created by Ashutos on 28/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiPassengerStatusUpdate: Mappable  {

    
    var taxiRidePassengerId = 0.0
    var userId = 0.0
    var userName : String?
    var status : String?
    var taxiRideGroupId = 0.0
    var taxiRideGroupStatus : String?
    var pickupTimeMs = 0.0
    var pickupOrder = 0
    var pickupOtp : String?
    var dropTimeMs = 0.0
    var dropOrder = 0
    var noOfSeats = 0

    init(taxiRidePassengerId: Double, taxiRideGroupId: Double) {
        self.taxiRidePassengerId = taxiRidePassengerId
        self.taxiRideGroupId = taxiRideGroupId
    }
    
    init(){ }
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.taxiRidePassengerId <- map["taxiRidePassengerId"]
        self.userId <- map["userId"]
        self.status <- map["status"]
        self.taxiRideGroupId <- map["taxiRideGroupId"]
        self.taxiRideGroupStatus <- map["taxiRideGroupStatus"]
        self.pickupTimeMs <- map["pickupTimeMs"]
        self.pickupOrder <- map["pickupOrder"]
        self.pickupOtp <- map["pickupOtp"]
        self.dropTimeMs <- map["dropTimeMs"]
        self.dropOrder <- map["dropOrder"]
        self.noOfSeats <- map["noOfSeats"]

    }
    
    var description: String {
        return "taxiRidePassengerId: \(String(describing: self.taxiRidePassengerId)),"
            + "userId: \(String(describing: self.userId)),"
            + "status: \(String(describing: self.status)),"
            + "taxiRideGroupId: \(String(describing: self.taxiRideGroupId)),"
            + "taxiRideGroupStatus: \(String(describing: self.taxiRideGroupStatus)),"
            + "pickupTimeMs: \(String(describing: self.pickupTimeMs)),"
            + "pickupOrder: \(String(describing: self.pickupOrder)),"
            + "pickupOtp: \(String(describing: self.pickupOtp)),"
            + "dropTimeMs: \(String(describing: self.dropTimeMs)),"
            + "dropOrder: \(String(describing: self.dropOrder)),"
            + "noOfSeats: \(String(describing: self.noOfSeats))"
    }
}
