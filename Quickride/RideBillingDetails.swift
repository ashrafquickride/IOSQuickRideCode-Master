//
//  RideBillingDetails.swift
//  Quickride
//
//  Created by Rajesab on 05/04/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideBillingDetails: NSObject, Mappable {
    var rideInvoiceNo: Int?
    var rideTakerCommissionInvoiceNo: Int?
    var rideGiverCommissionInvoiceNo: Int?
    
    var fromUserId: Int? // Passenger user id
    var toUserId: Int? // Rider user id
    var fromUserName: String?
    var toUserName: String?
    
    var refId: String? // Passenger ride id
    var sourceRefId: String? // Rider ride id
    
    var rideFare: Double? // Actual ride fare charged by the ride giver
    var rideFareGst: Double? // GST on the ride fare paid to be paid by passenger
    var rideTakerPlatformFee: Double? // Platform usage fee for passenger
    var rideTakerPlatformFeeGst: Double? // GST on the platform usage fee for passenger
    var rideTakerTotalAmount: Double? // Total amount paid by the passenger (rideFare + rideFareGst + rideTakerPlatformFee + rideTakerPlatformFeeGst)
    var rideGiverPlatformFee: Double? // Platform usage fee for ride giver
    var rideGiverPlatformFeeGst: Double? // GST on the platform usage fee for ride giver
    var rideGiverNetAmount: Double? // Net amount received by the rider (rideFare - platformFee - platformFeeGst)
    var status: String?
    var type: String? // Ride / RideRefund / Compensation / CompensationRefund / Transfer
    
    // Ride related details
    var  startLocation: String?
    var  endLocation: String?
    var  startTimeMs: Int?
    var  endTimeMs: Int?
    var  actualStartTimeMs: Int?
    var  actualEndTimeMs: Int?
    var  distance: Double?
    var  unitFare: Float?
    var  noOfSeat: Int?
    
    // Insurance related details - these are not stored in invoice table; should be read from ride insurance table
    var  claimRefId: String?
    var  insurancePolicyUrl: String?
//    private double insurancePoints;
    var  insuranceClaimed: Bool?
    var insurancePoints : Double = 0
    
    // Refund request
    var  refundRequest: RefundRequest?

    var  paymentType: String?
    
    static let bill_status_pending = "Pending"
    static let bill_id = "billId"
    
    required init?(map: Map) {
         
     }
    
    func mapping(map: Map) {
        rideInvoiceNo <- map["rideInvoiceNo"]
        rideTakerCommissionInvoiceNo <- map["rideTakerCommissionInvoiceNo"]
        rideGiverCommissionInvoiceNo <- map["rideGiverCommissionInvoiceNo"]
        fromUserId <- map["fromUserId"]
        toUserId <- map["toUserId"]
        fromUserName <- map["fromUserName"]
        toUserName <- map["toUserName"]
        refId <- map["refId"]
        sourceRefId <- map["sourceRefId"]
        rideFare <- map["rideFare"]
        rideFareGst <- map["rideFareGst"]
        rideTakerPlatformFee <- map["rideTakerPlatformFee"]
        rideTakerPlatformFeeGst <- map["rideTakerPlatformFeeGst"]
        rideTakerTotalAmount <- map["rideTakerTotalAmount"]
        rideGiverPlatformFee <- map["rideGiverPlatformFee"]
        rideGiverPlatformFeeGst <- map["rideGiverPlatformFeeGst"]
        rideGiverNetAmount <- map["rideGiverNetAmount"]
        status <- map["status"]
        type <- map["type"]
        startLocation <- map["startLocation"]
        endLocation <- map["endLocation"]
        startTimeMs <- map["startTimeMs"]
        endTimeMs <- map["endTimeMs"]
        actualStartTimeMs <- map["actualStartTimeMs"]
        actualEndTimeMs <- map["actualEndTimeMs"]
        distance <- map["distance"]
        unitFare <- map["unitFare"]
        noOfSeat <- map["noOfSeat"]
        claimRefId <- map["claimRefId"]
        insurancePolicyUrl <- map["insurancePolicyUrl"]
        insuranceClaimed <- map["insuranceClaimed"]
        insurancePoints <- map["insurancePoints"]
        refundRequest <- map["refundRequest"]
        paymentType <- map["paymentType"]
        
    }
    
    public override var description: String {
        return "rideInvoiceNo: \(String(describing: self.rideInvoiceNo))," +
        "rideTakerCommissionInvoiceNo: \(String(describing: self.rideTakerCommissionInvoiceNo))," +
        "rideGiverCommissionInvoiceNo: \(String(describing: self.rideGiverCommissionInvoiceNo))," +
        "refId: \(String(describing: self.refId))," +
        "sourceRefId: \(String(describing: self.sourceRefId))," +
        "rideFare: \(String(describing: self.rideFare))," +
        "rideFareGst: \(String(describing: self.rideFareGst))," +
        "rideTakerPlatformFee: \(String(describing: self.rideTakerPlatformFee))," +
        "rideTakerPlatformFeeGst: \(String(describing: self.rideTakerPlatformFeeGst))," +
        "rideTakerTotalAmount: \(String(describing: self.rideTakerTotalAmount))," +
        "rideGiverPlatformFee: \(String(describing: self.rideGiverPlatformFee))," +
        "rideGiverPlatformFeeGst: \(String(describing: self.rideGiverPlatformFeeGst))," +
        "rideGiverNetAmount: \(String(describing: self.rideGiverNetAmount))," +
        "status: \(String(describing: self.status))," +
        "type: \(String(describing: self.type))," +
        "startLocation: \(String(describing: self.startLocation))," +
        "endLocation: \(String(describing: self.endLocation))," +
        "startTimeMs: \(String(describing: self.startTimeMs))," +
        "endTimeMs: \(String(describing: self.endTimeMs))," +
        "actualStartTimeMs: \(String(describing: self.actualStartTimeMs))," +
        "actualEndTimeMs: \(String(describing: self.actualEndTimeMs))," +
        "distance: \(String(describing: self.distance))," +
        "unitFare: \(String(describing: self.unitFare))," +
        "noOfSeat: \(String(describing: self.noOfSeat)),"
    }
}
