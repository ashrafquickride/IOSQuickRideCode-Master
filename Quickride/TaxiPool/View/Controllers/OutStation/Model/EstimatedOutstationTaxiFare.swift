//
//  EstimatedOutstationTaxiFare.swift
//  Quickride
//
//  Created by Ashutos on 10/18/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EstimatedOutstationTaxiFare: NSObject, Mappable {
    var distanceBasedFare: Double?
    var tollCharges: Double?
    var nightCharges: Double?
    var parkingCharges: Double?
    var stateTaxCharges: Double?
    var interStateTaxCharges: Double?
    var serviceTax: Double?
    var driverAllowance: Double?
    var estimatedFare: Double?
    var baseKmFare: Double?
    var extraKmFare: Double?
    var minKm: Double?
    var extraHourFare: Double?
    var fixedFareRefId: String?
    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        distanceBasedFare <- map["distanceBasedFare"]
        tollCharges <- map["tollCharges"]
        nightCharges <- map["nightCharges"]
        parkingCharges <- map["parkingCharges"]
        stateTaxCharges <- map["stateTaxCharges"]
        interStateTaxCharges <- map["interStateTaxCharges"]
        serviceTax <- map["serviceTax"]
        driverAllowance <- map["driverAllowance"]
        estimatedFare <- map["estimatedFare"]
        baseKmFare <- map["baseKmFare"]
        extraKmFare <- map["extraKmFare"]
        minKm <- map["minKm"]
        extraHourFare <- map["extraHourFare"]
        fixedFareRefId <- map["fixedFareRefId"]
    }
    
    public override var description: String {
        return "distanceBasedFare: \(String(describing: self.distanceBasedFare)),"
            + "tollCharges: \(String(describing: self.tollCharges)),"
            + "nightCharges: \(String(describing: self.nightCharges)),"
            + "parkingCharges: \(String(describing: self.parkingCharges)),"
            + "stateTaxCharges: \(String(describing: self.stateTaxCharges)),"
            + "interStateTaxCharges: \(String(describing: self.interStateTaxCharges)),"
            + " serviceTax: \( String(describing: self.serviceTax)),"
            + " driverAllowance: \(String(describing: self.driverAllowance)),"
            + " estimatedFare: \(String(describing: self.estimatedFare)),"
            + " baseKmFare: \(String(describing: self.baseKmFare)),"
            + " extraKmFare: \(String(describing: self.extraKmFare)),"
            + " minKm: \(String(describing: self.minKm)),"
            + " extraHourFare: \(String(describing: self.extraHourFare)),"
            + " fixedFareRefId: \(String(describing: self.fixedFareRefId))"
    }
}
