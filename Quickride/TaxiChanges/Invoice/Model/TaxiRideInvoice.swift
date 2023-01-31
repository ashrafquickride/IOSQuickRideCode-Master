//
//  TaxiRideInvoice.swift
//  Quickride
//
//  Created by Ashutos on 29/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiRideInvoice: Mappable {
    
    var id: Double?
    var fromUserId: Double?
    var fromUserName: String?
    var refId: String?
    var sourceRefId: String?
    var toUserId:Double?
    var toUserName: String?
    var amount: Double?
    var serviceFee: Double?
    var netAmountPaid: Double?
    var tax: Double?
    var desc: String?
    var status: String?
    var type: String?
    var action: String?
    //Ride related details
    var startLocation: String?
    var endLocation: String?
    var startTimeMs: Double?
    var endTimeMs: Double?
    var distance: Double?
    var noOfSeats: Int?
    var shareType: String?
    var tripType: String?
    var journeyType: String?
    var vehicleModel: String?
    var vehicleNumber: String?
    var driverImageURI: String?
    var vehicleClass: String?
    var advanceAmount: Double?
    var distanceBasedFare: Double?
    var tollCharges: Double?
    var parkingCharges: Double?
    var nightCharges: Double?
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
    //Used for refund txn
    var parentId: Double?
    //Used for compensation txn
    var refInvoiceId: Double?
    var refundType: String?
    var creationTimeMs: Double?
    var updatedTimeMs: Double?
    var paymentType: String?
    var extraPickUpCharges = 0.0
    var extraPickUpDistance = 0.0
    var scheduleConvenienceFee = 0.0
    var scheduleConvenienceFeeTax = 0.0
    var couponCode: String?
    var couponDiscount = 0.0
    var extraTravelTimeFare: Double?
    var extraTravelTime: Double?
    var baseFare: Double?
    var platformFee = 0.0
    var platformFeeTax = 0.0
    
    static let invoiceId = "invoiceId"
    static let userId = "userId"
    
    static let INVOICE_STATUS_CAPTURED_FROM_USER = "CAPTURED_FROM_USER"
    static let INVOICE_STATUS_DEBITED_FROM_USER = "DEBITED_FROM_USER"
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        
        self.id <- map["id"]
        self.fromUserId <- map["fromUserId"]
        self.fromUserName <- map["fromUserName"]
        self.refId <- map["refId"]
        self.sourceRefId <- map["sourceRefId"]
        self.toUserId <- map["toUserId"]
        self.toUserName <- map["toUserName"]
        self.amount <- map["amount"]
        self.serviceFee <- map["serviceFee"]
        self.netAmountPaid <- map["netAmountPaid"]
        self.tax <- map["tax"]
        self.desc <- map["description"]
        self.status <- map["status"]
        self.type <- map["type"]
        self.action <- map["action"]
        self.startLocation <- map["startLocation"]
        self.endLocation <- map["endLocation"]
        self.startTimeMs <- map["startTimeMs"]
        self.endTimeMs <- map["endTimeMs"]
        self.distance <- map["distance"]
        self.noOfSeats <- map["noOfSeats"]
        self.shareType <- map["shareType"]
        self.tripType <- map["tripType"]
        self.journeyType <- map["journeyType"]
        self.vehicleModel <- map["vehicleModel"]
        self.vehicleNumber <- map["vehicleNumber"]
        self.driverImageURI <- map["driverImageURI"]
        self.vehicleClass <- map["vehicleClass"]
        self.advanceAmount <- map["advanceAmount"]
        self.distanceBasedFare <- map["distanceBasedFare"]
        self.tollCharges <- map["tollCharges"]
        self.parkingCharges <- map["parkingCharges"]
        self.nightCharges <- map["nightCharges"]
        self.stateTaxCharges <- map["stateTaxCharges"]
        self.interStateTaxCharges <- map["interStateTaxCharges"]
        self.driverAllowance <- map["driverAllowance"]
        self.baseKmFare <- map["baseKmFare"]
        self.extraKmFare <- map["extraKmFare"]
        self.extraTravelledKm <- map["extraTravelledKm"]
        self.extraTravelledFare <- map["extraTravelledFare"]
        self.seatCapacity <- map["seatCapacity"]
        self.startCity <- map["startCity"]
        self.endCity <- map["endCity"]
        self.parentId <- map["parentId"]
        self.refInvoiceId <- map["refInvoiceId"]
        self.refundType <- map["refundType"]
        self.creationTimeMs <- map["creationTimeMs"]
        self.updatedTimeMs <- map["updatedTimeMs"]
        self.paymentType <- map["paymentType"]
        self.extraPickUpCharges <- map["extraPickUpCharges"]
        self.extraPickUpDistance <- map["extraPickUpDistance"]
        self.scheduleConvenienceFee <- map["scheduleConvenienceFee"]
        self.scheduleConvenienceFeeTax <- map["scheduleConvenienceFeeTax"]
        self.couponCode <- map["couponCode"]
        self.couponDiscount <- map["couponDiscount"]
        self.extraTravelTimeFare <- map["extraTravelTimeFare"]
        self.extraTravelTime <- map["extraTravelTime"]
        self.baseFare <- map["baseFare"]
        self.platformFee <- map["platformFee"]
        self.platformFeeTax <- map["platformFeeTax"]
    }
    
    var description: String {
        return "id: \(String(describing: self.id)),"
            + "fromUserId: \(String(describing: self.fromUserId)),"
            + "fromUserName: \(String(describing: self.fromUserName)),"
            + "refId: \(String(describing: self.refId)),"
            + "sourceRefId: \(String(describing: self.sourceRefId)),"
            + "toUserId: \(String(describing: self.toUserId)),"
            + "toUserName: \(String(describing: self.toUserName)),"
            + "amount: \(String(describing: self.amount)),"
            + "serviceFee: \(String(describing: self.serviceFee)),"
            + "netAmountPaid: \(String(describing: self.netAmountPaid)),"
            + "tax: \(String(describing: self.tax)),"
            + "description: \(String(describing: self.desc)),"
            + "status: \(String(describing: self.status)),"
            + "type: \(String(describing: self.type)),"
            + "action: \(String(describing: self.action)),"
            + "startLocation: \(String(describing: self.startLocation)),"
            + "endLocation: \(String(describing: self.endLocation)),"
            + "startTimeMs: \(String(describing: self.startTimeMs)),"
            + "endTimeMs: \(String(describing: self.endTimeMs)),"
            + "distance: \(String(describing: self.distance)),"
            + "noOfSeats: \(String(describing: self.noOfSeats)),"
            + "shareType: \(String(describing: self.shareType)),"
            + "tripType: \(String(describing: self.tripType)),"
            + "journeyType: \(String(describing: self.journeyType)),"
            + "vehicleModel: \(String(describing: self.vehicleModel)),"        
            + "vehicleNumber: \(String(describing: self.vehicleNumber)),"
            + "driverImageURI: \(String(describing: self.driverImageURI)),"
            + "vehicleClass: \(String(describing: self.vehicleClass)),"
            + "advanceAmount: \(String(describing: self.advanceAmount)),"
            + "distanceBasedFare: \(String(describing: self.distanceBasedFare)),"
            + "tollCharges: \(String(describing: self.tollCharges)),"
            + "parkingCharges: \(String(describing: self.parkingCharges)),"
            + "nightCharges: \(String(describing: self.nightCharges)),"
            + "stateTaxCharges: \(String(describing: self.stateTaxCharges)),"
            + "interStateTaxCharges: \(String(describing: self.interStateTaxCharges)),"
            + "driverAllowance: \(String(describing: self.driverAllowance)),"
            + "baseKmFare: \(String(describing: self.baseKmFare)),"
            + "extraKmFare: \(String(describing: self.extraKmFare)),"
            + "extraTravelledKm: \(String(describing: self.extraTravelledKm)),"
            + "extraTravelledFare: \(String(describing: self.extraTravelledFare)),"
            + "seatCapacity: \(String(describing: self.seatCapacity)),"
            + "startCity: \(String(describing: self.startCity)),"
            + "endCity: \(String(describing: self.endCity)),"
            + "parentId: \(String(describing: self.parentId)),"
            + "refInvoiceId: \(String(describing: self.refInvoiceId)),"
            + "refundType: \(String(describing: self.refundType)),"
            + "creationTimeMs: \(String(describing: self.creationTimeMs)),"
            + "updatedTimeMs: \(String(describing: self.updatedTimeMs)),"
            + "paymentType: \(String(describing: self.paymentType))"
            + "extraPickUpCharges: \(String(describing: self.extraPickUpCharges))"
            + "extraPickUpDistance: \(String(describing: self.extraPickUpDistance))"
            + "scheduleConvenienceFee: \(String(describing: self.scheduleConvenienceFee))"
            + "scheduleConvenienceFeeTax: \(String(describing: self.scheduleConvenienceFeeTax))"
            + "couponCode: \(String(describing: self.couponCode))"
            + "couponDiscount: \(String(describing: self.couponDiscount))"
    }
}
