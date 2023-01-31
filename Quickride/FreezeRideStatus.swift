//
//  FreezeRideStatus.swift
//  Quickride
//
//  Created by Admin on 29/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class FreezeRideStatus : NSObject,Mappable{
   
    var rideId : Double?
    var freezeRideStatus = false
    
    override init(){
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.rideId <- map["rideId"]
        self.freezeRideStatus  <- map["freezeRideStatus"]
    }
    public override var description: String {
        return "rideId: \(String(describing: self.rideId))," + "freezeRideStatus: \(String(describing: self.freezeRideStatus)),"
    }
    
}
