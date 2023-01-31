//
//  RideRoute.swift
//  Quickride
//
//  Created by QuickRideMac on 14/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideRoute : NSObject,Mappable,NSCopying {
    
    var overviewPolyline : String?
    var distance : Double?
    var duration : Double?
    var waypoints : String?
    var routeId : Double?
    var routeType : String?
    var defaultRouteDistance: Double?
    var fromLatitude : Double?
    var fromLongitude : Double?
    var toLatitude : Double?
    var toLongitude : Double?
    var routeContainLoops = false
    
    static let FLD_ROUTE_DEVIATION_STATUS = "FLD_ROUTE_DEVIATION_STATUS"
    static let ROUTE_DEVIATION_INITIATED = "ROUTE_DEVIATION_INITIATED"
    static let ROUTE_DEVIATION_REJECTED = "ROUTE_DEVIATION_REJECTED"
    static let FLD_DEPARTURE_TIME = "departureTime"
    static let FLD_TRAVEL_MODE = "travelMode"
    static let TRAVEL_MODE_WALKING = "walking"
    
    static let KEY = "key"
    static let DESTINATION = "destination"
    static let ADDRESS = "address"
    static let WAY_POINTS = "waypoints"
    static let MODE = "mode"
    static let ORIGINS = "origins"
    static let DESTINATIONS = "destinations"
    static let DEFAULT_TRAFFIC_MODEL = "best_guess"
    static let DEFAULT_TRAVEL_MODE = "driving"
    static let DEPARTURE_TIME = "departure_time"
    static let TRAFFIC_MODEL = "traffic_model"
    static let ORIGIN = "origin"
    static let ROUTE_START_LAT = "routeStartLatitude"
    static let ROUTE_START_LNG = "routeStartLongitude"
    static let ROUTE_END_LAT = "routeEndLatitude"
    static let ROUTE_END_LNG = "routeEndLongitude"
    static let ROUTE_WAY_POINTS = "routeWaypoints"
    static let ROUTE_OVERVIEW_POLYLINE = "routeOverviewPolyline"
  
    

    
    override init()
    {}
    
    init(routeId : Double,overviewPolyline : String,distance :Double,duration : Double, waypoints : String?){
        self.routeId = routeId
        self.overviewPolyline = overviewPolyline
        self.distance = distance
        self.duration = duration
        self.waypoints = waypoints
    }
    
    init(routeId : Double,overviewPolyline : String,distance :Double,duration : Double, waypoints : String?,routeType:String?, fromLatitude : Double?, fromLongitude : Double?,toLatitude : Double?, toLongitude : Double?)
    {
        self.routeId = routeId
        self.overviewPolyline = overviewPolyline
        self.distance = distance
        self.duration = duration
        self.waypoints = waypoints
        self.routeType = routeType
        self.fromLatitude = fromLatitude
        self.fromLongitude = fromLongitude
        self.toLatitude = toLatitude
        self.toLongitude = toLongitude
    }

    required init?(map:Map){
        
    }
    func mapping(map: Map) {
        overviewPolyline <- map["overviewPolyline"]
        distance <- map["distance"]
        duration <- map["duration"]
        waypoints <- map["waypoints"]
        routeId <- map["routeId"]
        defaultRouteDistance <- map["defaultRouteDistance"]
        routeContainLoops <- map["routeContainLoops"]
        routeType <- map["routeType"]
        fromLatitude <- map["fromLatitude"]
        fromLongitude <- map["fromLongitude"]
        toLatitude <- map["toLatitude"]
        toLongitude <- map["toLongitude"]
    }
    public func copy(with zone: NSZone? = nil) -> Any {
        let rideRoute = RideRoute()
        rideRoute.overviewPolyline = self.overviewPolyline
        rideRoute.distance = self.distance
        rideRoute.duration = self.duration
        rideRoute.waypoints = self.waypoints
        rideRoute.routeId = self.routeId
        rideRoute.routeType = self.routeType
        rideRoute.defaultRouteDistance = self.defaultRouteDistance
        rideRoute.fromLatitude = self.fromLatitude
        rideRoute.fromLongitude = self.fromLongitude
        rideRoute.toLatitude = self.toLatitude
        rideRoute.toLongitude = self.toLongitude
        rideRoute.routeContainLoops = self.routeContainLoops
        return rideRoute
    }
    public override var description: String {
        return "overviewPolyline: \(String(describing: self.overviewPolyline))," + "distance: \(String(describing: self.distance))," + " duration: \( String(describing: self.duration))," + " waypoints: \(String(describing: self.waypoints))," + " routeId: \(String(describing: self.routeId)),"
            + " routeType: \(String(describing: self.routeType))," + "defaultRouteDistance: \(String(describing: self.defaultRouteDistance))," + "fromLatitude:\(String(describing: self.fromLatitude))," + "fromLongitude:\(String(describing: self.fromLongitude))," + "toLatitude:\(String(describing: self.toLatitude))," + "toLongitude:\(String(describing: self.toLongitude))," + "routeContainLoops: \(String(describing: self.routeContainLoops)),"
    }
}
