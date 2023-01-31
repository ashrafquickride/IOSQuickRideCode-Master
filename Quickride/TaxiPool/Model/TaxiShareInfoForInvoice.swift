//
//  TaxiShareInfoForInvoice.swift
//  Quickride
//
//  Created by Ashutos on 04/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiShareInfoForInvoice: NSObject, Mappable {
    
    var shareType: String?
    var tripType: String?
    var journeyType: String?
    var vehicleModel: String?
    var vehicleNumber: String?
    var driverImageURI: String?
    var driverName: String?
    var toTime: Double?
    var vehicleClass: String?
    var totalVendorFare: Double?
    var advanceAmount: Double?
    var distanceBasedFare: Double?
    var tollCharges: Double?
    var parkingCharges: Double?
    var nightCharges: Double?
    var serviceTax: Double?
    var stateTaxCharges: Double?
    var interStateTaxCharges: Double?
    var driverAllowance: Double?
    var baseKmFare: Double?
    var extraKmFare: Double?
    var extraTravelledKm: Double?
    var extraTravelledFare: Double?
    var seatCapacity: Int?
    var startCity: String?
    var endCity: String?
    var platformFee = 0.0
    var platformFeeTax = 0.0
    
    required init?(map: Map) {
        
    }
    
    override init() {
        super.init()
    }
    
    func mapping(map: Map) {
        shareType <- map["shareType"]
        tripType <- map["tripType"]
        journeyType <- map["journeyType"]
        vehicleModel <- map["vehicleModel"]
        vehicleNumber <- map["vehicleNumber"]
        driverImageURI <- map["driverImageURI"]
        driverName <- map["driverName"]
        toTime <- map["toTime"]
        vehicleClass <- map["vehicleClass"]
        totalVendorFare <- map["totalVendorFare"]
        advanceAmount <- map["advanceAmount"]
        distanceBasedFare <- map["distanceBasedFare"]
        tollCharges <- map["tollCharges"]
        parkingCharges <- map["parkingCharges"]
        nightCharges <- map["nightCharges"]
        serviceTax <- map["serviceTax"]
        stateTaxCharges <- map["stateTaxCharges"]
        interStateTaxCharges <- map["interStateTaxCharges"]
        driverAllowance <- map["driverAllowance"]
        baseKmFare <- map["baseKmFare"]
        extraKmFare <- map["extraKmFare"]
        extraTravelledKm <- map["extraTravelledKm"]
        extraTravelledFare <- map["extraTravelledFare"]
        seatCapacity <- map["seatCapacity"]
        startCity <- map["startCity"]
        endCity <- map["endCity"]
        platformFee <- map["platformFee"]
        platformFeeTax <- map["platformFeeTax"]
    }
    
    public override var description: String {
        return "shareType: \(String(describing: self.shareType)),"
            + " tripType: \(String(describing: self.tripType)),"
            + " journeyType: \(String(describing: self.journeyType)),"
            + " vehicleModel: \(String(describing: self.vehicleModel)),"
            + " vehicleNumber: \(String(describing: self.vehicleNumber)),"
            + " driverImageURI: \(String(describing: self.driverImageURI)),"
            + " driverName: \(String(describing: self.driverName)),"
            + " toTime: \(String(describing: self.toTime)),"
            + " vehicleClass: \(String(describing: self.vehicleClass)),"
            + " totalVendorFare: \(String(describing: self.totalVendorFare)),"
            + " advanceAmount: \(String(describing: self.advanceAmount)),"
            + " distanceBasedFare: \(String(describing: self.distanceBasedFare)),"
            + " tollCharges: \(String(describing: self.tollCharges)),"
            + " parkingCharges: \(String(describing: self.parkingCharges)),"
            + " nightCharges: \(String(describing: self.nightCharges)),"
            + " serviceTax: \(String(describing: self.serviceTax)),"
            + " stateTaxCharges: \(String(describing: self.stateTaxCharges)),"
            + " interStateTaxCharges: \(String(describing: self.interStateTaxCharges)),"
            + " driverAllowance: \(String(describing: self.driverAllowance)),"
            + " baseKmFare: \(String(describing: self.baseKmFare)),"
            + " extraKmFare: \(String(describing: self.extraKmFare)),"
            + " extraTravelledKm: \(String(describing: self.extraTravelledKm)),"
            + " extraTravelledFare: \(String(describing: self.extraTravelledFare)),"
            + " seatCapacity: \(String(describing: self.seatCapacity)),"
            + " startCity: \(String(describing: self.startCity)),"
            + " endCity: \(String(describing: self.endCity))"
    }
}
