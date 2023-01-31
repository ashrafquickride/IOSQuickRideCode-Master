//
//  RideUpdate.swift
//  Quickride
//
//  Created by Vinutha on 21/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideUpdate: Mappable {
    
    var rideId: Double?
    var rideType: String?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        rideId <- map["rideId"]
        rideType <- map["rideType"]
    }
    
}
