//
//  PassengerFareBreakUp.swift
//  Quickride
//
//  Created by Rajesab on 01/11/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct PassengerFareBreakUp: Mappable {
    
    var fareForVehicleClass: FareForVehicleClass?
    var advanceAmount = 0.0
    var initialFare = 0.0
    var totalFare = 0.0
    var cashAmount = 0.0
    var pendingAmount = 0.0
    var taxiUserAdditionalPaymentDetails = [TaxiUserAdditionalPaymentDetails]()
    var taxiTripExtraFareDetails = [TaxiTripExtraFareDetails]()
    var extraPickUpCharges = 0.0
    var extraPickUpDistance = 0.0
    var finalFareDetails: FinalFareDetails?
    var couponCode: String?
    var couponBenefit = 0.0
    var ridePaymentDetails = [TaxiRidePaymentDetails]()
    var taxiPartnerCode: String?
    var extraPickUpChargesGst: Double?
    var dropOtp: String?
    var startOdometerReading: Double?
    var endOdometerReading: Double?
    var taxiRideInvoiceRefundDetails = [TaxiRideInvoice]()
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.fareForVehicleClass <- map["fareForVehicleClass"]
        self.advanceAmount <- map["advanceAmount"]
        self.initialFare <- map["initialFare"]
        self.totalFare <- map[""]
        self.cashAmount <- map["cashAmount"]
        self.pendingAmount <- map["pendingAmount"]
        self.taxiUserAdditionalPaymentDetails <- map["taxiUserAdditionalPaymentDetails"]
        self.taxiTripExtraFareDetails <- map["taxiTripExtraFareDetails"]
        self.extraPickUpCharges <- map["extraPickUpCharges"]
        self.extraPickUpDistance <- map["extraPickUpDistance"]
        self.finalFareDetails <- map["finalFareDetails"]
        self.couponCode <- map["couponCode"]
        self.couponBenefit <- map["couponBenefit"]
        self.ridePaymentDetails <- map["ridePaymentDetails"]
        self.taxiPartnerCode <- map["taxiPartnerCode"]
        self.extraPickUpChargesGst <- map["extraPickUpChargesGst"]
        self.dropOtp <- map["dropOtp"]
        self.startOdometerReading <- map["startOdometerReading"]
        self.endOdometerReading <- map["endOdometerReading"]
        self.taxiRideInvoiceRefundDetails <- map["taxiRideInvoiceRefundDetails"]
        
    }
    
    var classDescription: String {
        return "fareForVehicleClass: \(String(describing: self.fareForVehicleClass)),"
        + "advanceAmount: \(String(describing: self.advanceAmount)),"
        + "initialFare: \(String(describing: self.initialFare))," + "totalFare: \(String(describing: self.totalFare)),"
        + "cashAmount: \(String(describing: self.cashAmount))," + "pendingAmount: \(String(describing: self.pendingAmount)),"
        + "taxiUserAdditionalPaymentDetails: \(String(describing: self.taxiUserAdditionalPaymentDetails)),"
        + "taxiTripExtraFareDetails: \(String(describing: self.taxiTripExtraFareDetails)),"
        + "extraPickUpCharges: \(String(describing: self.extraPickUpCharges)),"
        + "extraPickUpDistance: \(String(describing: self.extraPickUpDistance)),"
        + "finalFareDetails: \(String(describing: self.finalFareDetails)),"
        + "couponCode: \(String(describing: self.couponCode)),"
        + "couponBenefit: \(String(describing: self.couponBenefit)),"
        + "ridePaymentDetails: \(String(describing: self.ridePaymentDetails)),"
        + "taxiPartnerCode: \(String(describing: self.taxiPartnerCode)),"
        + "extraPickUpChargesGst: \(String(describing: self.extraPickUpChargesGst)),"
        + "dropOtp: \(String(describing: self.dropOtp)),"
        + "startOdometerReading: \(String(describing: self.startOdometerReading)),"
        + "endOdometerReading: \(String(describing: self.endOdometerReading)),"
        + "taxiRideInvoiceRefundDetails: \(String(describing: self.taxiRideInvoiceRefundDetails)),"
    }
}
