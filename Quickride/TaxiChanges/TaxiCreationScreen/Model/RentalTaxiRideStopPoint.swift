//
//  RentalTaxiRideStopPoint.swift
//  Quickride
//
//  Created by Rajesab on 26/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RentalTaxiRideStopPoint: NSObject, Mappable{
    var id: String?
    var taxiGroupId: Double?
    var srcAddress: String?
    var srcLat: Double?
    var srcLng: Double?
    var stopPointAddress: String?
    var stopPointLat: Double?
    var stopPointLng: Double?
    var scheduledRouteId: Double?
    var estimatedDistance: Double?
    var estimatedDuration: Int?
    var actualTravelledDistance: Double?
    var scheduledTravelledPath: String?
    var actualStopPointLat: Double?
    var actualStopPointLng: Double?
    var actualRouteId: Double?
    var actualTravelledPath: String?
    var creationDateMs: Double?
    var modifiedDateMs: Double?
    var tripId: String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
    id <- map["id"]
    taxiGroupId <- map["taxiGroupId"]
    srcAddress <- map["srcAddress"]
    srcLat <- map["srcLat"]
    srcLng <- map["srcLng"]
    stopPointAddress <- map["stopPointAddress"]
    stopPointLat <- map["stopPointLat"]
    stopPointLng <- map["stopPointLng"]
    scheduledRouteId <- map["scheduledRouteId"]
    estimatedDistance <- map["estimatedDistance"]
    estimatedDuration <- map["estimatedDuration"]
    actualTravelledDistance <- map["actualTravelledDistance"]
    scheduledTravelledPath <- map["scheduledTravelledPath"]
    actualStopPointLat <- map["actualStopPointLat"]
    actualStopPointLng <- map["actualStopPointLng"]
    actualRouteId <- map["actualRouteId"]
    actualTravelledPath <- map["actualTravelledPath"]
    creationDateMs <- map["creationDateMs"]
    modifiedDateMs <- map["modifiedDateMs"]
    tripId <- map["tripId"]
    }
}
