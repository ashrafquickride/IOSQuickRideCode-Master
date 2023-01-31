//
//  RideBasicInfo.swift
//  Quickride
//
//  Created by Anki on 13/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideBasicInfo:NSObject,Mappable{
  
  private var phonenumber:Double?
  private var ridebasicinfoid:Double?
  private var rideType: String?
  private var startAddress: String?
  private var endAddress: String?
  private var startTime: NSDate?
  private var expectedEndTime: NSDate?
  
  required init(map:Map){
    
  }
  
  func mapping(map:Map){
    phonenumber <- map["userId"]
    ridebasicinfoid <- map["id"]
    rideType <- map["rideType"]
    startAddress <- map["startAddress"]
    endAddress <- map["endAddress"]
    startTime <- map["startTime"]
    expectedEndTime <- map["expectedEndTime"]
  }
    public override var description: String {
        return "phonenumber: \(String(describing: self.phonenumber))," + "ridebasicinfoid: \(String(describing: self.ridebasicinfoid))," + " rideType: \( String(describing: self.rideType))," + " startAddress: \(String(describing: self.startAddress))," + " endAddress: \(String(describing: self.endAddress))," + " startTime: \( String(describing: self.startTime))," + " expectedEndTime: \(String(describing: self.expectedEndTime)),"
    }
}


