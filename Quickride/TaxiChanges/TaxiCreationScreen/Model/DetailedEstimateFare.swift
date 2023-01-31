//
//  DetailedEstimateFare.swift
//  Quickride
//
//  Created by Ashutos on 19/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class DetailedEstimateFare: NSObject, Mappable {
    
    var serviceableArea: Bool = false
    var routeId: Double?
    var startTime: Double?
    var endTime: Double?
    var fareForTaxis = [EstimatedFareForTaxi]()
    var error: ResponseError?
    var lastUpdateTime : Double = 0.0
    var tripType: String?
    var alternativeRoutes = [RideRoute]()
    
    static let TIME_NOT_MATCHING_ERROR_CODE = 3538
    
    static let PICKUP_LOCATION_ERROR_CODE = 3514
    static let DROP_LOCATION_ERROR_CODE = 3515
    static let SERVICE_DROP_LOCATION_ERROR_CODE = 3516
    static let ROUTE_ONEWAY_TRIP_ERROR_CODE = 3518
    static let ROUTE_OUTSTATION_TRIP_ERROR_CODE = 3519
    
    required init?(map: Map) {
        
    }
    
    override init() {
        
    }
    
    func mapping(map: Map) {
        serviceableArea <- map["serviceableArea"]
        routeId <- map["routeId"]
        startTime <- map["startTime"]
        endTime <- map["endTime"]
        fareForTaxis <- map["fareForTaxis"]
        error <- map["error"]
        tripType <- map["tripType"]
        alternativeRoutes <- map["alternativeRoutes"]
    }
    
    public override var description: String {
        return "serviceableArea: \(String(describing: self.serviceableArea)),"
            + "routeId: \(String(describing: self.routeId)),"
            + "startTime: \(String(describing: self.startTime)),"
            + "endTime: \(String(describing: self.endTime)),"
            + "fareForTaxis: \(String(describing: self.fareForTaxis)),"
            + "error: \(String(describing: self.error))"
            + "tripType: \(String(describing: self.tripType)),"
            + "alternativeRoutes: \(String(describing: self.alternativeRoutes))"
    }
}
