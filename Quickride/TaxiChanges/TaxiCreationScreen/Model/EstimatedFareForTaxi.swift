//
//  EstimatedFareForTaxi.swift
//  Quickride
//
//  Created by Ashutos on 19/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EstimatedFareForTaxi: NSObject, Mappable {
    var taxiType: String?
    var fares = [FareForVehicleClass]()
    
    required init?(map: Map) {
        
    }
    
    override init() {
        
    }
    
    func mapping(map: Map) {
        taxiType <- map["taxiType"]
        fares <- map["fares"]
    }
    
    public override var description: String {
        return "taxiType: \(String(describing: self.taxiType)),"
            + "fares: \(String(describing: self.fares))"
    }
}
