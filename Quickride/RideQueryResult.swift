//
//  RideQueryResult.swift
//  Quickride
//
//  Created by Anki on 14/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class RideQueryResult:NSObject,Mappable{
  
  var ridequeryresultid: Double?
  var phonenumber:Double?
  var startLatitude:Double?
  var startLogitude:Double?
  var endLatitude:Double?
  var endLongitude:Double?
  var rideStartTime:NSDate?
  var queryTime:NSDate?
  var noOfMatchedRides:Int?
  var rideType: String?
  
  required public init(map:Map){
    
  }
  
  public func mapping(map:Map){
    ridequeryresultid <- map["id"]
    phonenumber <- map["userId"]
    startLatitude <- map["startLatitude"]
    startLogitude <- map["startLogitude"]
    endLatitude <- map["endLatitude"]
    endLongitude <- map["endLongitude"]
    rideStartTime <- map["rideStartTime"]
    queryTime <- map["queryTime"]
    noOfMatchedRides <- map["noOfMatchedRides"]
    rideType <- map["rideType"]
  }
    public override var description: String {
        return "ridequeryresultid: \(String(describing: self.ridequeryresultid))," + "phonenumber: \(String(describing: self.phonenumber))," + " startLatitude: \( String(describing: self.startLatitude))," + " startLogitude: \(String(describing: self.startLogitude))," + " endLatitude: \(String(describing: self.endLatitude))," + " endLongitude: \( String(describing: self.endLongitude))," + " rideStartTime: \(String(describing: self.rideStartTime))," + " queryTime: \(String(describing: self.queryTime))," + " noOfMatchedRides: \(String(describing: self.noOfMatchedRides))," + " rideType: \(String(describing: self.rideType)),"
    }
}

