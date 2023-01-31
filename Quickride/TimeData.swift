//
//  TimeData.swift
//  Quickride
//
//  Created by QuickRideMac on 18/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TimeData : NSObject,Mappable{
    var pickupTime : String?
    var startTime : String?
    var dropTime : String?
    required init?(map: Map) {
        
    }
    func mapping(map: Map) {
        self.pickupTime <- map["pickupTime"]
        self.dropTime <- map["dropTime"]
        self.startTime <- map["startTime"]
    }
    public override var description: String {
        return "pickupTime: \(String(describing: self.pickupTime))," + "startTime: \(String(describing: self.startTime))," + " dropTime: \( String(describing: self.dropTime)),"
    }
}
