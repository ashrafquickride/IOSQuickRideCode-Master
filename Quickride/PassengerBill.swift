//
//  PassengerBill.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/9/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class Bill : NSObject,Mappable {
  
  var receiptno : Double?
  var userId : Double?
  var userName : String?
  var rideId : Double?
  var date : Double?
  var billByUserId : Double?
  var billByUserName : String?
  var startLocation  : String?
  var endLocation  : String?
  var startTime : Double?
  var endTime : Double?
  var distance : Double?
  var unitFare : Double?
  var amount : Double?
  var serviceFee : Double?
  var discount : Double?
  var netAmountPaid : Double?
  var noOfSeats : Int?
  var accountBalance :Double?
  var tax : Double?
  var claimRefId : String?
  var insurancePolicyUrl : String?
  var insurancePoints : Double = 0
  var insuranceClaimed = false
  var status : String?
  var passengerRideId : Double?
  var paymentType: String?
  var refundRequest: RefundRequest?
    
 static let bill_status_pending = "Pending"
 static let bill_id = "billId"

  
  required init?(map: Map) {
    
  }
  
  func mapping(map: Map) {
    receiptno    <- map["receiptno"]
    userId         <- map["userId"]
    userName      <- map["userName"]
    rideId       <- map["rideId"]
    date  <- map["date"]
    billByUserId  <- map["billByUserId"]
    billByUserName     <- map["billByUserName"]
    startLocation     <- map["startLocation"]
    endLocation     <- map["endLocation"]
    startTime     <- map["startTime"]
    endTime     <- map["endTime"]
    distance     <- map["distance"]
    unitFare     <- map["unitFare"]
    amount     <- map["amount"]
    serviceFee     <- map["serviceFee"]
    discount     <- map["discount"]
    netAmountPaid     <- map["netAmountPaid"]
    noOfSeats     <- map["noOfSeats"]
    accountBalance     <- map["accountBalance"]
    tax <- map["tax"]
    claimRefId <- map["claimRefId"]
    insurancePolicyUrl <- map["insurancePolicyUrl"]
    insurancePoints <- map["insurancePoints"]
    insuranceClaimed <- map["insuranceClaimed"]
    status <- map["status"]
    passengerRideId <- map["passengerRideId"]
    paymentType <- map["paymentType"]
    refundRequest <- map["refundRequest"]
  }
    public override var description: String {
        return "receiptno: \(String(describing: self.receiptno))," + "userId: \(String(describing: self.userId))," + " userName: \( String(describing: self.userName))," + " rideId: \(String(describing: self.rideId))," + " date: \(String(describing: self.date)),"
            + " billByUserId: \(String(describing: self.billByUserId))," + "billByUserName: \(String(describing: self.billByUserName))," + "startLocation:\(String(describing: self.startLocation))," + "endLocation:\(String(describing: self.endLocation))," + "startTime:\(String(describing: self.startTime))," + "endTime:\(String(describing: self.endTime))," + "distance: \(String(describing: self.distance))," + "unitFare: \( String(describing: self.unitFare))," + "amount: \(String(describing: self.amount))," + "serviceFee: \( String(describing: self.serviceFee))," + "discount: \(String(describing: self.discount))," + "netAmountPaid: \( String(describing: self.netAmountPaid))," + "noOfSeats:\(String(describing: self.noOfSeats))," + "accountBalance:\(String(describing: self.accountBalance))," + "tax: \(String(describing: self.tax))," + "paymentType: \(String(describing: self.paymentType))," + "refundRequest: \(String(describing: self.refundRequest)),"
    }
}
