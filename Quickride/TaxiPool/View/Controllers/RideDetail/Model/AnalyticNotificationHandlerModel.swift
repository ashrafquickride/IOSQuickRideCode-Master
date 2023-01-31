//
//  AnalyticNotificationHandlerModel.swift
//  Quickride
//
//  Created by Ashutos on 8/4/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AnalyticNotificationHandlerModel: NSObject, Mappable  {
    
    var passengerRideId: Double?
    var taxiShareRideId: Double?
    var minFare: Double?
    var maxFare: Double?
    var rating: Double?
    var shareType: String?
    var maxShareType: String?
    var startAddress: String?
    var fromLat: Double?
    var fromLng: Double?
    var endAddress: String?
    var toLat: Double?
    var toLng: Double?
    var routeId: Double?
    var routepathPolyline: String?
    var rideStartTime: Double?
    var limitedUserProfile : [PotentialRiderDetails]?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        passengerRideId <- map["passengerRideId"]
        taxiShareRideId <- map["taxiShareRideId"]
        minFare <- map["minFare"]
        maxFare <- map["maxFare"]
        rating <- map["rating"]
        shareType <- map["shareType"]
        maxShareType <- map["maxShareType"]
        startAddress <- map["startAddress"]
        fromLat <- map["fromLat"]
        fromLng <- map["fromLng"]
        endAddress <- map["endAddress"]
        toLat <- map["toLat"]
        toLng <- map["toLng"]
        routeId <- map["routeId"]
        routepathPolyline <- map["routepathPolyline"]
        rideStartTime <- map["rideStartTime"]
        limitedUserProfile <- map["limitedUserProfile"]
    }
    
    public override var description: String {
        return "passengerRideId: \(String(describing: self.passengerRideId)),"
            + " taxiShareRideId: \(String(describing: self.taxiShareRideId)),"
            + "minFare: \(String(describing: self.minFare)),"
            + "maxFare: \(String(describing: self.maxFare)),"
            + "rating: \(String(describing: self.rating)),"
            + "shareType: \(String(describing: self.shareType)),"
            + "shareType: \(String(describing: self.shareType)),"
            + "maxShareType: \(String(describing: self.maxShareType)),"
            + "startAddress: \(String(describing: self.startAddress)),"
            + "fromLat: \(String(describing: self.fromLat)),"
            + "fromLng: \(String(describing: self.fromLng)),"
            + "endAddress: \(String(describing: self.endAddress)),"
            + "toLat: \(String(describing: self.toLat)),"
            + "toLng: \(String(describing: self.toLng)),"
            + "routeId: \(String(describing: self.routeId)),"
            + "routepathPolyline: \(String(describing: self.routepathPolyline)),"
            + "rideStartTime: \(String(describing: self.rideStartTime)),"
            + "limitedUserProfile: \(String(describing: self.limitedUserProfile))"
    }
    
}
