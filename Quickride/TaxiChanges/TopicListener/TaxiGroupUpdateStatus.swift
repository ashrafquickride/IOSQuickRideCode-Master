//
//  TaxiGroupUpdateStatus.swift
//  Quickride
//
//  Created by Quick Ride on 2/4/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class TaxiGroupUpdateStatus : Mappable{
    var taxiRideGroupId = 0.0
    var status : String?
    var bookingStatus : String?
    var pickupOtp : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.taxiRideGroupId <- map["taxiRideGroupId"]
        self.status <- map["status"]
        self.bookingStatus <- map["bookingStatus"]
        self.pickupOtp <- map["pickupOtp"]
    }
    
    var description: String {
        return "taxiRideGroupId: \(String(describing: self.taxiRideGroupId)),"
            + "status: \(String(describing: self.status)),"
            + "bookingStatus: \(String(describing: self.bookingStatus)),"
            + "pickupOtp: \(String(describing: self.pickupOtp))"
    }
}
