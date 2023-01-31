//
//  PartnerRecentLocationInfo.swift
//  Quickride
//
//  Created by Rajesab on 09/05/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PartnerRecentLocationInfo: NSObject, Mappable {
    
    var partnerId: Int?
    var updatedTime: Double?
    var latitude: Double?
    var longitude: Double?
    var bearing: Double? = 0.0
    var cellId: Double? 
    var vehicleClass: String? = "Hatchback"
    var availabilityStatus: String? = "ONLINE"
    var onlineSuggestionNotifiedTime: Int = 0
    var speedInKmPerHr: Double? = 0.0
    var recentCumulativeSpeedInKmPerHr: Double? = 0.0
    var cumulativeTimeInMs: Int? = 0
    
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        partnerId <- map["partnerId"]
        updatedTime <- map["updatedTime"]
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        bearing <- map["bearing"]
        cellId <- map["cellId"]
        vehicleClass <- map["vehicleClass"]
        availabilityStatus <- map["availabilityStatus"]
        onlineSuggestionNotifiedTime <- map["onlineSuggestionNotifiedTime"]
        speedInKmPerHr <- map["speedInKmPerHr"]
        recentCumulativeSpeedInKmPerHr <- map["recentCumulativeSpeedInKmPerHr"]
        cumulativeTimeInMs <- map["cumulativeTimeInMs"]
    }
    
    
}
