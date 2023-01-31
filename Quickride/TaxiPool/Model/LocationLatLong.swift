//
//  LocationLatLong.swift
//  Quickride
//
//  Created by Ashutos on 9/3/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class LocationLatLong : NSObject, Mappable {
    
    var lat = 0.0
    var lng = 0.0
    var radius = 0.0
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        lat <- map["lat"]
        lng <- map["lng"]
        radius <- map["radius"]
    }
    
    public override var description: String {
        return "lat: \(String(describing: self.lat)),"
            + " lng: \(String(describing: self.lng)),"
            + " radius: \(String(describing: self.radius))"
    }
}
