//
//  TaxiShareRideResponse.swift
//  Quickride
//
//  Created by Ashutos on 06/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiShareRideResponse: NSObject, Mappable {
    
    var taxiShareRide: TaxiShareRide?
    var quickRideException: QuickRideException?
        
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.taxiShareRide <- map["taxiShareRide"]
        self.quickRideException <- map["quickRideException"]
    }
    
    public override var description: String {
        return "taxiShareRide: \(String(describing: self.taxiShareRide)),"
        + "quickRideException: \(String(describing: self.quickRideException))"
    }
}
