//
//  RoutePathData.swift
//  Quickride
//
//  Created by KNM Rao on 02/11/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RoutePathData: NSObject,Mappable {
    
    var routeSteps = [RouteStep]()
    var routeId : Double = 0
    var fromLatitude : Double?
    var fromLongitude : Double?
    var toLatitude : Double?
    var toLongitude : Double?
    var fromLocAddress : String?
    var toLocAddress : String?
    var overviewPolyline : String?
    var distance : Double = 0
    var duration : Int = 0
    var viaPoints : String?
    var creationDate : Double?
    var routeType : String?
    var defaultRouteDistance : Double?
    var routeContainLoops = false
    var durationInTraffic = 0
    var lastUpdateTime : Double?
    static let ROUTE_TYPE_DEFAULT = "Default"
    static let ROUTE_TYPE_MAIN = "Main"
    static let ROUTE_TYPE_ALTERNATE = "Alternate"
    static let ROUTE_TYPE_CUSTOM = "Custom"
    
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        self.routeSteps <- map["routeSteps"]
        self.routeId <- map["routeId"]
        self.fromLatitude <- map["fromLatitude"]
        self.fromLongitude <- map["fromLongitude"]
        self.toLatitude <- map["toLatitude"]
        self.toLongitude <- map["toLongitude"]
        self.fromLocAddress <- map["fromLocAddress"]
        self.toLocAddress <- map["toLocAddress"]
        self.overviewPolyline <- map["overviewPolyline"]
        self.distance <- map["distance"]
        self.duration <- map["duration"]
        self.viaPoints <- map["viaPoints"]
        self.creationDate <- map["creationDate"]
        self.routeType <- map["routeType"]
        self.defaultRouteDistance <- map["defaultRouteDistance"]
        self.routeContainLoops <- map["routeContainLoops"]
        self.durationInTraffic <- map["durationInTraffic"]
    }
    public override var description: String {
        return "routeId: \(String(describing: self.routeId))," + "fromLatitude: \(String(describing: self.fromLatitude))," + " fromLongitude: \( String(describing: self.fromLongitude))," + " toLatitude: \(String(describing: self.toLatitude))," + " toLongitude: \(String(describing: self.toLongitude)),"
            + " fromLocAddress: \(String(describing: self.fromLocAddress))," + "toLocAddress: \(String(describing: self.toLocAddress))," + "overviewPolyline:\(String(describing: self.overviewPolyline))," + "distance:\(String(describing: self.distance))," + "duration:\(String(describing: self.duration))," + "viaPoints:\(String(describing: self.viaPoints))," + "creationDate: \(String(describing: self.creationDate))," + "routeType: \( String(describing: self.routeType))," + "defaultRouteDistance: \(String(describing: self.defaultRouteDistance))," + "routeContainLoops: \( String(describing: self.routeContainLoops))," + "durationInTraffic: \(String(describing: self.durationInTraffic))," + "lastUpdateTime: \( String(describing: self.lastUpdateTime)),"
    }
}
