//
//  TaxiTripExtraFareDetails.swift
//  Quickride
//
//  Created by HK on 12/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiTripExtraFareDetails: Mappable {
    
    var id: String?
    var tripId: String?
    var customerId = 0
    var fareType: String?
    var amount = 0.0
    var status: String?
    var description: String?
    var creationDateMs = 0
    var modifiedDateMs = 0
    var location: String?
    
    static let FARE_TYPE_TOLL = "Toll"
    static let FARE_TYPE_PARKING = "Parking"
    static let FARE_TYPE_INTER_STATE_TAX = "InterStateTax"
    static let FARE_TYPE_NIGHT_CHARGES = "NightCharges"
    static let FARE_TYPE_OTHER = "Other"
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.tripId <- map["tripId"]
        self.customerId <- map["customerId"]
        self.fareType <- map["fareType"]
        self.amount <- map["amount"]
        self.status <- map["status"]
        self.description <- map["description"]
        self.creationDateMs <- map["creationDateMs"]
        self.modifiedDateMs <- map["modifiedDateMs"]
        self.location <- map["location"]
    }
    
    var classDescription: String {
        return "id: \(String(describing: self.id)),"
            + "tripId: \(String(describing: self.tripId)),"
            + "customerId: \(String(describing: self.customerId))," + "fareType: \(String(describing: self.fareType)),"
            + "amount: \(String(describing: self.amount))," + "status: \(String(describing: self.status)),"
            + "description: \(String(describing: self.description))," + "creationDateMs: \(String(describing: self.creationDateMs)),"  + "modifiedDateMs: \(String(describing: self.modifiedDateMs))," + "location: \(String(describing: self.location)),"
    }
}

