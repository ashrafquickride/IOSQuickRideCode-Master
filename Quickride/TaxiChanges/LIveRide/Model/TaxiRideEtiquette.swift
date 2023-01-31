//
//  TaxiRideEtiquette.swift
//  Quickride
//
//  Created by HK on 19/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiRideEtiquette: Mappable {
    
    var id = 0
    var guideline: String?
    var feedbackMsg: String?
    var role: String?
    var severity = 0
    var imageUri: String?
    var unVerifiedToleranceCount = 0
    var ratings: String?
    var vehicleType: String?
    
    init?(map: Map){
        
    }
    
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.guideline <- map["guideline"]
        self.feedbackMsg <- map["feedbackMsg"]
        self.role <- map["role"]
        self.severity <- map["severity"]
        self.imageUri <- map["imageUri"]
        self.unVerifiedToleranceCount <- map["unVerifiedToleranceCount"]
        self.ratings <- map["ratings"]
        self.vehicleType <- map["vehicleType"]
    }
}
