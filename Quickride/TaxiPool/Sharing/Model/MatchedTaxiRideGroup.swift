//
//  MatchedTaxiRideGroup.swift
//  Quickride
//
//  Created by HK on 26/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct MatchedTaxiRideGroup: Mappable {
    
    var taxiRideGroupId = 0
    var startTimeMs = 0
    var startAddress: String?
    var startLat = 0.0
    var startLng = 0.0
    var endTimeMs = 0
    var endAddress: String?
    var endLat = 0.0
    var endLng = 0.0
    var pickupAddress: String?
    var pickupLat = 0.0
    var pickupLng = 0.0
    var pickupTimeMs = 0
    var dropAddress: String?
    var dropLat = 0.0
    var dropLng = 0.0
    var dropTimeMs = 0
    var distance = 0.0
    var minPoints = 0.0
    var maxPoints = 0.0
    var routePolyline: String?
    var routeId = 0
    var shareType: String?
    var capacity = 0
    var status: String?
    var availableSeats = 0
    var noOfPassengers = 0
    var pickupSequenceOrder = 0
    var dropSequenceOrder = 0
    var deviatedFromOriginalRoute = false
    var totalDistance = 0.0
    var fixedFareRefId: String?
    var joinedPassengers = [TaxiRidePassenger]()
    var lastUpdatedTime: NSDate? // using appside
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.taxiRideGroupId <- map["taxiRideGroupId"]
        self.startTimeMs <- map["startTimeMs"]
        self.startAddress <- map["startAddress"]
        self.startLat <- map["startLat"]
        self.startLng <- map["startLng"]
        self.endTimeMs <- map["endTimeMs"]
        self.endAddress <- map["endAddress"]
        self.endLat <- map["endLat"]
        self.endLng <- map["endLng"]
        self.pickupAddress <- map["pickupAddress"]
        self.pickupLat <- map["pickupLat"]
        self.pickupLng <- map["pickupLng"]
        self.pickupTimeMs <- map["pickupTimeMs"]
        self.dropAddress <- map["dropAddress"]
        self.dropLat <- map["dropLat"]
        self.dropLng <- map["dropLng"]
        self.dropTimeMs <- map["dropTimeMs"]
        self.distance <- map["distance"]
        self.minPoints <- map["minPoints"]
        self.maxPoints <- map["maxPoints"]
        self.routePolyline <- map["routePolyline"]
        self.routeId <- map["routeId"]
        self.shareType <- map["shareType"]
        self.capacity <- map["capacity"]
        self.status <- map["status"]
        self.availableSeats <- map["availableSeats"]
        self.noOfPassengers <- map["noOfPassengers"]
        self.pickupSequenceOrder <- map["pickupSequenceOrder"]
        self.dropSequenceOrder <- map["dropSequenceOrder"]
        self.deviatedFromOriginalRoute <- map["deviatedFromOriginalRoute"]
        self.totalDistance <- map["totalDistance"]
        self.fixedFareRefId <- map["fixedFareRefId"]
        self.joinedPassengers <- map["joinedPassengers"]
    }
}
