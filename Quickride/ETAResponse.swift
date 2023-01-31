//
//  ETAResponse.swift
//  Quickride
//
//  Created by QR Mac 1 on 17/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


struct ETAResponse: Mappable {
    
    var source: LatLng?
    var destination: LatLng?
    var timeTakenInSec = 0
    var distanceInKM = 0.0
    var routeId = 0.0
    var error: ResponseError?
    var lastUpdateTime : Double?
    var overViewPolyline: String?
    var speed: Double?


    static let routeId = "routeId"
    static let startTime = "startTime"
    static let startLatLngListJson = "startLatLngListJson"
    static let endLatLngListJson = "endLatLngListJson"
    static let vehicleType = "vehicleType"
    static let startLatitude = "startLatitude"
    static let startLongitude = "startLongitude"
    static let endLatitude = "endLatitude"
    static let endLangitude = "endLongitude"
    static let userId = "userId"
    static let rideId = "rideId"
    static let useCase = "useCase"
    static let snapToRoute = "snapToRoute"
    
    init( source : LatLng, destination : LatLng, timeTakenInSec :Int, distanceInKM : Double,routeId : Double, error : ResponseError?) {
        self.source = source
        self.destination = destination
        self.timeTakenInSec = timeTakenInSec
        self.distanceInKM = distanceInKM
        self.error = error
        self.routeId = routeId
        lastUpdateTime = NSDate().getTimeStamp()
    }
    

    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        self.source <- map["source"]
        self.destination <- map["destination"]
        self.timeTakenInSec <- map["timeTakenInSec"]
        self.distanceInKM <- map["distanceInKM"]
        self.routeId <- map["routeId"]
        self.error <- map["error"]
        self.overViewPolyline <- map["overViewPolyline"]
        lastUpdateTime = NSDate().getTimeStamp()
    }
}
