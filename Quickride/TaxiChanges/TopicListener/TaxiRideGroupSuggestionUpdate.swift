//
//  TaxiRideGroupSuggestionUpdate.swift
//  Quickride
//
//  Created by QR Mac 1 on 26/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiRideGroupSuggestionUpdate: Mappable {
    
    var id = 0
    var action: String?
    var description: String?
    var newFare = 0.0
    var fixedFareId: String?
    var updatedTimeMs = 0
    var isSuggestionShowed = false // using app side
    
    static let DRIVER_WITH_HIGHER_FARE_AVAILABLE = "DRIVER_WITH_HIGHER_FARE_AVAILABLE"
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.id <- map["id"]
        self.action <- map["action"]
        self.description <- map["description"]
        self.newFare <- map["newFare"]
        self.fixedFareId <- map["fixedFareId"]
        self.updatedTimeMs <- map["updatedTimeMs"]
        self.isSuggestionShowed <- map["isSuggestionShowed"]
    }
    
    var modelDescription: String {
         "id: \(String(describing: self.id))," + "action: \(String(describing: self.action))," + "description: \(String(describing: self.description))," + "newFare: \(String(describing: self.newFare))" + "fixedFareId: \(String(describing: self.fixedFareId))" + "updatedTimeMs: \(String(describing: self.updatedTimeMs))" + "isSuggestionShowed: \(String(describing: self.isSuggestionShowed))"
    }
}
