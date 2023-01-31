//
//  RouteMetrics.swift
//  Quickride
//
//  Created by KNM Rao on 28/10/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CoreLocation

class RouteMetrics: NSObject,Mappable,NSCopying {

    var originAddress : String?
    var destinationAddress : String?
    var fromLat : Double = 0
    var fromLng : Double = 0
    var toLat : Double = 0
    var toLng : Double = 0
    var routeDistance : Double = 0
    var journeyDuration :Int = 0
    var journeyDurationInTraffic : Int = 0
    var departureTime : Double = 0
    var arrivalTime : Double = 0
    var creationTime : Double = 0
    var error : ResponseError?
    static let FLD_ORIGIN = "origin"
    static let FLD_DESTINATION = "destination"
    static let FLD_USE_CASE = "useCase"
    static let FLD_DEPARTURE_TIME = "departureTime"

    override init(){ }

    init(routeMetrics : RouteMetrics){
        
        self.originAddress = routeMetrics.originAddress
        self.destinationAddress = routeMetrics.destinationAddress
        self.fromLat = routeMetrics.fromLat
        self.fromLng = routeMetrics.fromLng
        self.toLat = routeMetrics.toLat
        self.toLng = routeMetrics.toLng
        self.routeDistance = routeMetrics.routeDistance
        self.journeyDuration = routeMetrics.journeyDuration
        self.journeyDurationInTraffic = routeMetrics.journeyDurationInTraffic
        self.departureTime = routeMetrics.departureTime
        self.arrivalTime = routeMetrics.arrivalTime
        self.creationTime = routeMetrics.creationTime

    }
    init(originAddress: String?,destinationAddress: String,fromLat: Double,fromLng: Double,toLat: Double,toLng: Double,routeDistance: Double,journeyDuration: Int,journeyDurationInTraffic: Int,departureTime: Double,arrivalTime: Double,creationTime: Double,error: ResponseError?) {
        self.originAddress = originAddress
        self.destinationAddress = destinationAddress
        self.fromLat = fromLat
        self.fromLng = fromLng
        self.toLat = toLat
        self.toLng = toLng
        self.routeDistance = routeDistance
        self.journeyDuration = journeyDuration
        self.journeyDurationInTraffic = journeyDurationInTraffic
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.creationTime = creationTime
        self.error = error
    }
    
    required init?(map: Map) {

    }
    func mapping(map: Map) {
        self.originAddress <- map["originAddress"]
        self.destinationAddress <- map["destinationAddress"]
        self.routeDistance <- map["routeDistance"]
        self.journeyDuration <- map["journeyDuration"]
        self.journeyDurationInTraffic <- map["journeyDurationInTraffic"]
        self.departureTime <- map["departureTimeMillis"]
        self.arrivalTime <- map["arrivalTimeMillis"]
        self.creationTime <- map["creationTimeMillis"]
        self.fromLat <- map["fromLat"]
        self.fromLng <- map["fromLng"]
        self.toLat <- map["toLat"]
        self.toLng <- map["toLng"]
        self.error <- map["error"]
    }

    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RouteMetrics()
        copy.originAddress = self.originAddress
        copy.destinationAddress = self.destinationAddress
        copy.routeDistance = self.routeDistance
        copy.journeyDuration = self.journeyDuration
        copy.journeyDurationInTraffic = self.journeyDurationInTraffic
        copy.departureTime = self.departureTime
        copy.arrivalTime = self.arrivalTime
        copy.fromLat = self.fromLat
        copy.fromLng = self.fromLng
        copy.toLat = self.toLat
        copy.toLng = self.toLng
        copy.creationTime = self.creationTime
        copy.error = self.error

        return copy
    }

    public override var description: String {
        return "originAddress: \(String(describing: self.originAddress))," + "destinationAddress: \(String(describing: self.destinationAddress))," + " routeDistance: \( String(describing: self.routeDistance))," + " journeyDuration: \(String(describing: self.journeyDuration))," + " journeyDurationInTraffic: \(String(describing: self.journeyDurationInTraffic)),"
            + " departureTime: \(String(describing: self.departureTime))," + "arrivalTime: \(String(describing: self.arrivalTime)),"
    }
}
