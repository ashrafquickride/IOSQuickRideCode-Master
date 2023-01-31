//
//  TaxiRidePassengerStatus.swift
//  Quickride
//
//  Created by Ashutos on 23/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiRidePassengerStatus: Mappable {
    
    var taxiRidePassengerId: Double?
    var userId: Double?
    var userName: String?
    var status: String?
    var taxiRideGroupId: Double?
    var pickupTimeMs: Double?
    var pickupOrder: Int?
    var dropTimeMs: Double?
    var dropOrder: Int?
    var noOfSeats: Int?
    
    init() { }
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.taxiRidePassengerId <- map["taxiRidePassengerId"]
        self.userId <- map["userId"]
        self.userName <- map["userName"]
        self.status <- map["status"]
        self.taxiRideGroupId <- map["taxiRideGroupId"]
        self.pickupTimeMs <- map["pickupTimeMs"]
        self.pickupOrder <- map["pickupOrder"]
        self.dropTimeMs <- map["dropTimeMs"]
        self.dropOrder <- map["dropOrder"]
        self.noOfSeats <- map["noOfSeats"]
    }
    
    var description: String {
        return "taxiRidePassengerId: \(String(describing: self.taxiRidePassengerId)),"
            + "userId: \(String(describing: self.userId)),"
            + "userName: \(String(describing: self.userName)),"
            + "status: \(String(describing: self.status)),"
            + "taxiRideGroupId: \(String(describing: self.taxiRideGroupId)),"
            + "pickupTimeMs: \(String(describing: self.pickupTimeMs)),"
            + "pickupOrder: \(String(describing: self.pickupOrder)),"
            + "dropTimeMs: \(String(describing: self.dropTimeMs)),"
            + "dropOrder: \(String(describing: self.dropOrder)),"
            + "noOfSeats: \(String(describing: self.noOfSeats))"
    }
    
}
