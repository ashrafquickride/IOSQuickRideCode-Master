//
//  AvailableOutstationTaxi.swift
//  Quickride
//
//  Created by Ashutos on 10/18/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AvailableOutstationTaxi:NSObject, Mappable  {
    
    var vehicleClass: String?
    var vehicleClassId: String?
    var estimatedOutstationTaxiFare: EstimatedOutstationTaxiFare?
    var totalDistance: Double?
    var seatCapacity: Int?
    var taxiTypeImageUri: String?
    var luggageCapacity: Int?
    var sourceCity: String?
    var destinationCity: String?
    var inclusions: [String] = []
    var exclusions: [String] = []
    var facilities: [String] = []
    var extras: [String] = []
    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        totalDistance <- map["totalDistance"]
        vehicleClass <- map["vehicleClass"]
        vehicleClassId <- map["vehicleClassId"]
        estimatedOutstationTaxiFare <- map["estimatedTaxiFare"]
        seatCapacity <- map["seatCapacity"]
        taxiTypeImageUri <- map["taxiTypeImageUri"]
        luggageCapacity <- map["luggageCapacity"]
        inclusions <- map["inclusions"]
        exclusions <- map["exclusions"]
        facilities <- map["facilities"]
        extras <- map["extras"]
        sourceCity <- map["sourceCity"]
        destinationCity <- map["destinationCity"]
    }
    
    public override var description: String {
        return "totalDistance: \(String(describing: self.totalDistance)),"
            + "vehicleClass: \(String(describing: self.vehicleClass)),"
            + "vehicleClassId: \(String(describing: self.vehicleClassId)),"
            + "estimatedOutstationTaxiFare: \(String(describing: self.estimatedOutstationTaxiFare)),"
            + "seatCapacity: \(String(describing: self.seatCapacity)),"
            + "taxiTypeImageUri: \(String(describing: self.taxiTypeImageUri)),"
            + "luggageCapacity: \(String(describing: self.luggageCapacity)),"
            + " inclusions: \( String(describing: self.inclusions)),"
            + " exclusions: \(String(describing: self.exclusions)),"
            + " facilities: \(String(describing: self.facilities)),"
            + " extras: \(String(describing: self.extras)),"
            + " sourceCity: \(String(describing: self.sourceCity)),"
            + " destinationCity: \(String(describing: self.destinationCity))"
    }
}
