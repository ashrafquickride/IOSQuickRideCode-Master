//
//  FareForVehicleClass.swift
//  Quickride
//
//  Created by Ashutos on 19/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class FareForVehicleClass: NSObject, Mappable {
    var taxiType: String?
    var vehicleClass: String?
    var vehicleDescription: String?
    var shareType: String?
    var fixedFareId: String?
    var minTotalFare: Double?
    var maxTotalFare: Double?
    var minMeteredFare: Double?
    var maxMeteredFare: Double?
    var minGst: Double?
    var maxGst: Double?
    var tollCharges: Double?
    var durationBasedFare: Double?
    var parkingCharges: Double?
    var driverBata: Double?
    var nightCharges: Double?
    var interStateCharges: Double?
    var additionalCharges: Double?
    var additionalChargesDescription: Double?
    var includedTollCharges: Bool?
    var includedInterStateTaxes: Bool?
    var minBaseKmFare: Double?
    var maxBaseKmFare: Double?
    var extraKmFare: Double?
    var extraHourFare: Double?
    var scheduledRide: Bool?
    var peakHourRide: Bool?
    var tollChargesForTaxi: Double? // For taxi
    var parkingChargesForTaxi: Double?
    var driverBataForTaxi: Double?
    var nightChargesForTaxi: Double?
    var interStateChargesForTaxi: Double?
    var additionalChargesForTaxi: Double?
    var specialFixedFare: Bool?
    var seatCapacity: Int?
    var luggageCapacity: Int?
    var taxiTnCSummary: TaxiTnCSummary?
    var routeId: String?
    var startTime: Double?
    var endTime: Double?
    var distance: Double = 0.0
    var timeDuration: Int = 0
    var creationDate: Double?
    var modifiedDate: Double?
    var selectedMaxFare: Double?
    var baseFareFreeKm: Double?
    var baseFare: Double?
    var extraPickUpChargesCanBeApplied = false //extra pick up charges
    var overviewPolyline: String?
    var destinationCity: String?
    var appliedTollsForTaxiTrip: String?
    var  minPlatformFee: Double?
    var  minPlatformFeeTax: Double?
    var  maxPlatformFee: Double?
    var  maxPlatformFeeTax: Double?
    override init(){
        
    }
    
    required init?(map: Map) {
        
    }
    
    init(taxiType: String,fixedFareId: String,vehicleClass: String,selectedMaxFare: Double,shareType: String) {
        self.taxiType = taxiType
        self.fixedFareId = fixedFareId
        self.vehicleClass = vehicleClass
        self.shareType = shareType
        self.selectedMaxFare = selectedMaxFare
    }
    
    func mapping(map: Map) {
        taxiType <- map["taxiType"]
        vehicleClass <- map["vehicleClass"]
        vehicleDescription <- map["vehicleDescription"]
        shareType <- map["shareType"]
        fixedFareId <- map["fixedFareId"]
        minTotalFare <- map["minTotalFare"]
        maxTotalFare <- map["maxTotalFare"]
        minMeteredFare <- map["minMeteredFare"]
        maxMeteredFare <- map["maxMeteredFare"]
        minGst <- map["minGst"]
        maxGst <- map["maxGst"]
        tollCharges <- map["tollCharges"]
        durationBasedFare <- map["durationBasedFare"]
        parkingCharges <- map["parkingCharges"]
        driverBata <- map["driverBata"]
        nightCharges <- map["nightCharges"]
        interStateCharges <- map["interStateCharges"]
        additionalCharges <- map["additionalCharges"]
        additionalChargesDescription <- map["additionalChargesDescription"]
        includedTollCharges <- map["includedTollCharges"]
        includedInterStateTaxes <- map["includedInterStateTaxes"]
        minBaseKmFare <- map["minBaseKmFare"]
        maxBaseKmFare <- map["maxBaseKmFare"]
        extraKmFare <- map["extraKmFare"]
        extraHourFare <- map["extraHourFare"]
        scheduledRide <- map["scheduledRide"]
        peakHourRide <- map["peakHourRide"]
        tollChargesForTaxi <- map["tollChargesForTaxi"]
        parkingChargesForTaxi <- map["parkingChargesForTaxi"]
        driverBataForTaxi <- map["driverBataForTaxi"]
        nightChargesForTaxi <- map["nightChargesForTaxi"]
        interStateChargesForTaxi <- map["interStateChargesForTaxi"]
        additionalChargesForTaxi <- map["additionalChargesForTaxi"]
        specialFixedFare <- map["specialFixedFare"]
        seatCapacity <- map["seatCapacity"]
        luggageCapacity <- map["luggageCapacity"]
        taxiTnCSummary <- map["taxiTnCSummary"]
        routeId <- map["routeId"]
        startTime <- map["startTimeMs"]
        endTime <- map["endTime"]
        distance <- map["distance"]
        timeDuration <- map["timeDuration"]
        creationDate <- map["creationDate"]
        modifiedDate <- map["modifiedDate"]
        baseFareFreeKm <- map["baseFareFreeKm"]
        baseFare <- map["baseFare"]
        extraPickUpChargesCanBeApplied <- map["extraPickUpChargesCanBeApplied"]
        overviewPolyline <- map["overviewPolyline"]
        destinationCity <- map["destinationCity"]
        appliedTollsForTaxiTrip <- map["appliedTollsForTaxiTrip"]
        minPlatformFee <- map["minPlatformFee"]
        minPlatformFeeTax <- map["minPlatformFeeTax"]
        maxPlatformFee <- map["maxPlatformFee"]
        maxPlatformFeeTax <- map["maxPlatformFeeTax"]
    }
    
    public override var description: String {
        return "taxiType: \(String(describing: self.taxiType)),"
            + "vehicleClass: \(String(describing: self.vehicleClass)),"
            + "vehicleDescription: \(String(describing: self.vehicleDescription)),"
            + "shareType: \(String(describing: self.shareType)),"
            + "fixedFareId: \(String(describing: self.fixedFareId)),"
            + "minTotalFare: \(String(describing: self.minTotalFare)),"
            + "maxTotalFare: \(String(describing: self.maxTotalFare)),"
            + "minMeteredFare: \(String(describing: self.minMeteredFare)),"
            + "maxMeteredFare: \(String(describing: self.maxMeteredFare)),"
            + "minGst: \(String(describing: self.minGst)),"
            + "maxGst: \(String(describing: self.maxGst)),"
            + "tollCharges: \(String(describing: self.tollCharges)),"
            + "durationBasedFare: \(String(describing: self.durationBasedFare)),"
            + "parkingCharges: \(String(describing: self.parkingCharges)),"
            + "driverBata: \(String(describing: self.driverBata)),"
            + "nightCharges: \(String(describing: self.nightCharges)),"
            + "interStateCharges: \(String(describing: self.interStateCharges)),"
            + "additionalCharges: \(String(describing: self.additionalCharges)),"
            + "additionalChargesDescription: \(String(describing: self.additionalChargesDescription)),"
            + "includedTollCharges: \(String(describing: self.includedTollCharges)),"
            + "includedInterStateTaxes: \(String(describing: self.includedInterStateTaxes)),"
            + "minBaseKmFare: \(String(describing: self.minBaseKmFare)),"
            + "maxBaseKmFare: \(String(describing: self.maxBaseKmFare)),"
            + "extraKmFare: \(String(describing: self.extraKmFare)),"
            + "extraHourFare: \(String(describing: self.extraHourFare)),"
            + "scheduledRide: \(String(describing: self.scheduledRide)),"
            + "peakHourRide: \(String(describing: self.peakHourRide)),"
            + "tollChargesForTaxi: \(String(describing: self.tollChargesForTaxi))"
            + "parkingChargesForTaxi: \(String(describing: self.parkingChargesForTaxi)),"
            + "driverBataForTaxi: \(String(describing: self.driverBataForTaxi)),"
            + "nightChargesForTaxi: \(String(describing: self.nightChargesForTaxi)),"
            + "interStateChargesForTaxi: \(String(describing: self.interStateChargesForTaxi)),"
            + "additionalChargesForTaxi: \(String(describing: self.additionalChargesForTaxi)),"
            + "specialFixedFare: \(String(describing: self.specialFixedFare)),"
            + "seatCapacity: \(String(describing: self.seatCapacity)),"
            + "luggageCapacity: \(String(describing: self.luggageCapacity)),"
            + "taxiTnCSummary: \(String(describing: self.taxiTnCSummary)),"            
            + "routeId: \(String(describing: self.routeId)),"
            + "startTime: \(String(describing: self.startTime)),"
            + "endTime: \(String(describing: self.endTime)),"
            + "distance: \(String(describing: self.distance)),"
            + "timeDuration: \(String(describing: self.timeDuration)),"
            + "creationDate: \(String(describing: self.creationDate)),"
            + "modifiedDate: \(String(describing: self.modifiedDate))"
            + "baseFareFreeKm: \(String(describing: self.baseFareFreeKm))"
            + "baseFare: \(String(describing: self.baseFare))"
            + "extraPickUpChargesCanBeApplied: \(String(describing: self.extraPickUpChargesCanBeApplied))"
            + "overviewPolyline: \(String(describing: self.overviewPolyline))"
            + "destinationCity: \(String(describing: self.destinationCity))"
            + "appliedTollsForTaxiTrip: \(String(describing: self.appliedTollsForTaxiTrip))"
            + "minPlatformFee: \(String(describing: self.minPlatformFee))"
            + "minPlatformFeeTax: \(String(describing: self.minPlatformFeeTax))"
            + "maxPlatformFee: \(String(describing: self.maxPlatformFee))"
            + "maxPlatformFeeTax: \(String(describing: self.maxPlatformFeeTax))"
    }
}

