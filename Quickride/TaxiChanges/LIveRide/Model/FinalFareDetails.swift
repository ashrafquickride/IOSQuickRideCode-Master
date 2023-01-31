//
//  FinalFareDetails.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/09/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct FinalFareDetails: Mappable{
    
    var totalFare = 0.0
    var serviceTax = 0.0
    var advancePayment = 0.0
    var distanceBasedFare = 0.0
    var tollCharges = 0.0
    var parkingCharges = 0.0
    var nightCharges = 0.0
    var stateTaxCharges = 0.0
    var interStateTaxCharges = 0.0
    var driverAllowance = 0.0
    var additionalCharges = 0.0
    var baseFare = 0.0
    var baseKmFare = 0.0
    var extraKmFare = 0.0
    var extraTravelledKm = 0.0
    var extraTravelledFare = 0.0
    var durationBasedFare = 0.0
    var extraHourFare = 0.0
    var extraHoursSpent = 0.0
    var extraTimeFare = 0.0
    var penaltyAmount = 0.0
    var balanceDueAmount = 0.0
    var cashAmount = 0.0
    var finalDistance = 0.0
    var isPeakHourRide = false
    var driverTotalFare = 0.0
    var baseFareFreeKm = 0.0
    var extraPickUpCharges = 0.0
    var extraPickUpDistance = 0.0
    var scheduleConvenienceFee = 0.0
    var scheduleConvenienceFeeTax = 0.0
    var taxiTnCSummary: TaxiTnCSummary?
    var platformFee = 0.0
    var platformFeeTax = 0.0
    
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.totalFare <- map["totalFare"]
        self.serviceTax <- map["serviceTax"]
        self.advancePayment <- map["advancePayment"]
        self.distanceBasedFare <- map["distanceBasedFare"]
        self.tollCharges <- map["tollCharges"]
        self.parkingCharges <- map["parkingCharges"]
        self.nightCharges <- map["nightCharges"]
        self.stateTaxCharges <- map["stateTaxCharges"]
        self.interStateTaxCharges <- map["interStateTaxCharges"]
        self.driverAllowance <- map["driverAllowance"]
        self.additionalCharges <- map["additionalCharges"]
        self.baseFare <- map["baseFare"]
        self.baseKmFare <- map["baseKmFare"]
        self.extraKmFare <- map["extraKmFare"]
        self.extraTravelledKm <- map["extraTravelledKm"]
        self.extraTravelledFare <- map["extraTravelledFare"]
        self.durationBasedFare <- map["durationBasedFare"]
        self.extraHourFare <- map["extraHourFare"]
        self.extraHoursSpent <- map["extraHoursSpent"]
        self.extraTimeFare <- map["extraTimeFare"]
        self.penaltyAmount <- map["penaltyAmount"]
        self.balanceDueAmount <- map["balanceDueAmount"]
        self.cashAmount <- map["cashAmount"]
        self.finalDistance <- map["finalDistance"]
        self.isPeakHourRide <- map["isPeakHourRide"]
        self.driverTotalFare <- map["driverTotalFare"]
        self.baseFareFreeKm <- map["baseFareFreeKm"]
        self.extraPickUpCharges <- map["extraPickUpCharges"]
        self.extraPickUpDistance <- map["extraPickUpDistance"]
        self.scheduleConvenienceFee <- map["scheduleConvenienceFee"]
        self.scheduleConvenienceFeeTax <- map["scheduleConvenienceFeeTax"]
        self.taxiTnCSummary <- map["taxiTnCSummary"]
        self.platformFee <- map["platformFee"]
        self.platformFeeTax <- map["platformFeeTax"]
    }
}
