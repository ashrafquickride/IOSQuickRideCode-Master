//
//  InstantTaxiEnabledLocation.swift
//  Quickride
//
//  Created by Quick Ride on 5/25/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class InstantTaxiEnabledLocation: Mappable {
    var location : LocationLatLong?
    var tripType : String?
    var advanceTimeInMinsForBookingToBeAllowed = 0
    var enableTaxiSharing = false
    
    required  init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.location <- map["location"]
        self.tripType <- map["tripType"]
        self.advanceTimeInMinsForBookingToBeAllowed <- map["advanceTimeInMinsForBookingToBeAllowed"]
        self.enableTaxiSharing <- map["enableTaxiSharing"]
    }
}
