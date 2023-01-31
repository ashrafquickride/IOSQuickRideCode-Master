//
//  RideMatchAlertRegistration.swift
//  Quickride
//
//  Created by Vinutha on 30/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct RideMatchAlertRegistration: Mappable {
    
    var id = 0
    var userId = 0.0
    var startLatitude = 0.0
    var startLongitude = 0.0
    var endLatitude = 0.0
    var endLongitude = 0.0
    var rideType: String?
    var rideStartTime = 0.0
    var routeId = 0
    var startAddr: String?
    var endAddr: String?
    var distance = 0.0
    var status: String?
    
    static let ACTIVE = "Active"
    static let INACTIVE = "InActive"
    
    static let status = "status"
    static let userId = "userId"
    static let rideMatchAlertId = "id"
    
    init?(map: Map) {
        
    }
    init() {}
    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.userId <- map["userId"]
        self.startLatitude <- map["startLat"]
        self.startLongitude <- map["startLng"]
        self.endLatitude <- map["endLat"]
        self.endLongitude <- map["endLng"]
        self.rideType <- map["rideType"]
        self.rideStartTime <- map["rideStartTime"]
        self.routeId <- map["routeId"]
        self.startAddr <- map["startAddr"]
        self.endAddr <- map["endAddr"]
        self.distance <- map["distance"]
        self.status <- map["status"]
    }
    
    init(userId: Double,startLatitude: Double,startLongitude: Double,endLatitude: Double,endLongitude: Double,rideType: String,rideStartTime: Double,routeId: Int,startAddr: String,endAddr: String, distance: Double) {
        self.userId = userId
        self.startLatitude = startLatitude
        self.startLongitude = startLongitude
        self.endLatitude = endLatitude
        self.endLongitude = endLongitude
        self.rideType = rideType
        self.rideStartTime = rideStartTime
        self.routeId = routeId
        self.startAddr = startAddr
        self.endAddr = endAddr
        self.distance = distance
    }
    
    func  getParamsMap() -> [String : String] {
        var params : [String : String] = [String : String]()
        params["userId"] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params["startLat"] = String(startLatitude)
        params["startLng"] = String(startLongitude)
        params["endLat"] = String(endLatitude)
        params["endLng"] = String(endLongitude)
        params["rideType"] =  rideType
        params["rideStartTime"] = AppUtil.getDateStringFromTimeIntervalInMillis(milliSeconds: DateUtils.getTimeInUTC(time: rideStartTime))
        params["routeId"] = String(routeId)
        params["startAddr"] = startAddr
        params["endAddr"] = endAddr
        params["distance"] = String(distance)
        params["status"] = status
        return params
    }
    
    public var description: String {
           return "id: \(String(describing: self.id))," + "userId: \(String(describing: self.userId))," + "startLatitude: \(String(describing: self.startLatitude))," + "startLongitude: \(String(describing: self.startLongitude))," + "startLatitude: \(String(describing: self.startLatitude))," + "endLatitude: \(String(describing: self.endLatitude))," + "rideType: \(String(describing: self.rideType))," + "rideStartTime: \(String(describing: self.rideStartTime))," + "routeId: \(String(describing: self.routeId))," + "startAddr: \(String(describing: self.startAddr))," + "endAddr: \(String(describing: self.endAddr))," + "distance: \(String(describing: self.distance))," + "status: \(String(describing: self.status)),"
       }
}
