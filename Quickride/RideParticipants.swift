//
//  RideParticipants.swift
//  Quickride
//
//  Created by KNM Rao on 11/17/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import ObjectMapper
import Foundation

public class RideParticipantser : NSObject,Mappable {
  
  var endAddress = ""
  var gender = ""
  var imageURI = ""
  var name = ""
  var rideId : Double = 0
  var riderid : Double = 0
  var rider : Double = 0
  var startAddress = ""
  var status = ""
  var userId : Double = 0
  
  required public init?(map: Map) {
    
  }
  
  public func mapping(map: Map) {
    
    endAddress <- map["endAddress"]
    gender  <- map["gender"]
    imageURI      <- map["imageURI"]
    rideId       <- map["rideId"]
    name  <- map["name"]
    riderid     <- map["riderid"]
    rider     <- map["rider"]
    startAddress     <- map["startAddress"]
    status     <- map["status"]
    userId     <- map["userId"]
    
  }
    public override var description: String {
        return "endAddress: \(String(describing: self.endAddress))," + "gender: \(String(describing: self.gender))," + " imageURI: \( String(describing: self.imageURI))," + " name: \(String(describing: self.name))," + " rideId: \(String(describing: self.rideId)),"
            + " riderid: \(String(describing: self.riderid))," + "rider: \(String(describing: self.rider))," + "startAddress:\(String(describing: self.startAddress))," + "status:\(String(describing: self.status))," + "userId:\(String(describing: self.userId)),"
    }
  
}
