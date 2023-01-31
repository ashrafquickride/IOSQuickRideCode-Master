//
//  NearByRideOption.swift
//  Quickride
//
//  Created by QuickRideMac on 14/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class NearByRideOption: NSObject,Mappable {
    
    var latLng : LatLng?
    var userName : String?
    var userId : Double?
    var fromLocation : String?
    var toLocation : String?
    var uniqueID :String?
    var rideId : Double?
    var pickupTime : Double?
    var userType: String?
    var vehicleType: String?
  
  init( latLng : LatLng,  userName: String,  fromLocation : String,  toLocation : String, userId : Double,uniqueID :String?,rideId : Double?,pickupTime : Double?,userType :String,vehicleType:String?) {
        self.latLng = latLng
        self.userName = userName
        self.fromLocation = fromLocation
        self.toLocation = toLocation
        self.userId = userId
        self.uniqueID = uniqueID
        self.rideId = rideId
        self.pickupTime = pickupTime
        self.userType = userType
        self.vehicleType = vehicleType
    }
  
  
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.latLng <- map["latLng"]
        self.userName <- map["userName"]
        self.fromLocation <- map["fromLocation"]
        self.toLocation <- map["toLocation"]
        self.userId <- map["userId"]
        self.uniqueID <- map["uniqueID"]
        self.pickupTime <- map["pickupTime"]
      self.userType <- map["userType"]
      self.vehicleType <- map["vehicleType"]
    }
    public override var description: String {
        return "latLng: \(String(describing: self.latLng))," + "userName: \(String(describing: self.userName))," + " fromLocation: \( String(describing: self.fromLocation))," + "toLocation: \(String(describing: self.toLocation))," + "userId: \(String(describing: self.userId))," + "uniqueID: \(String(describing: self.uniqueID))," + "pickupTime: \(String(describing: self.pickupTime))," + "userType: \(String(describing: self.pickupTime))," +  "vehicleType: \(String(describing: self.vehicleType)),"
    }
}
