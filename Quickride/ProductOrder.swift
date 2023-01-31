//
//  ProductOrder.swift
//  Quickride
//
//  Created by QR Mac 1 on 04/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ProductOrder: Mappable{
    
    var bookingFee = 0
    var borrowerId = 0
    var cancelReason: String?
    var durationInDays = 0
    var extraPaidAmount = 0
    var finalPrice = 0.0
    var handOverPic: String?
    var id: String?
    var initialPrice = 0
    var invoiceId: String?
    var listingId: String?
    var pickUpAddress: String?
    var pickUpLat = 0.0
    var pickUpLng = 0.0
    var pickUpOtp: String?
    var pricePerDay = 0.0
    var requestId: String?
    var returnOtp: String?
    var sellerId = 0
    var status: String?
    var tradeType: String?
    var returnHandOverPic: String?
    var deliveryType = RequestProduct.SELF_PICKUP
    var deposit = 0
    var paymentMode = RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE
    var serviceFeePercentage = 0
    var viewedBySeller = 0
    var damageAmount = 0.0
    var remainingAmount = 0.0 // app side calculation
    var fromTimeInMs = 0.0
    var toTimeInMs = 0.0
    var pickUpTimeInMs = 0.0
    var creationDateInMs = 0.0
    var modifiedDateInMs = 0.0
    var acceptedTimeInMs = 0.0
    var handOverTimeInMs = 0.0
    var returnHandOverTimeInMs = 0.0
    
    init?(map: Map) {
        
    }
    init() {
        
    }
    
    mutating func mapping(map: Map) {
        self.bookingFee <- map["bookingFee"]
        self.borrowerId <- map["borrowerId"]
        self.cancelReason <- map["cancelReason"]
        self.durationInDays <- map["durationInDays"]
        self.extraPaidAmount <- map["extraPaidAmount"]
        self.finalPrice <- map["finalPrice"]
        self.handOverPic <- map["handOverPic"]
        self.id <- map["id"]
        self.initialPrice <- map["initialPrice"]
        self.invoiceId <- map["invoiceId"]
        self.listingId <- map["listingId"]
        self.pickUpAddress <- map["pickUpAddress"]
        self.pickUpLat <- map["pickUpLat"]
        self.pickUpLng <- map["pickUpLng"]
        self.pickUpOtp <- map["pickUpOtp"]
        self.pricePerDay <- map["pricePerDay"]
        self.requestId <- map["requestId"]
        self.returnOtp <- map["returnOtp"]
        self.sellerId <- map["sellerId"]
        self.status <- map["status"]
        self.tradeType <- map["tradeType"]
        self.returnHandOverPic <- map["returnHandOverPic"]
        self.deliveryType <- map["deliveryType"]
        self.deposit <- map["deposit"]
        self.paymentMode <- map["paymentMode"]
        self.serviceFeePercentage <- map["serviceFeePercentage"]
        self.viewedBySeller <- map["viewedBySeller"]
        self.damageAmount <- map["damageAmount"]
        self.fromTimeInMs <- map["fromTimeInMs"]
        self.toTimeInMs <- map["toTimeInMs"]
        self.pickUpTimeInMs <- map["pickUpTimeInMs"]
        self.creationDateInMs <- map["creationDateInMs"]
        self.modifiedDateInMs <- map["modifiedDateInMs"]
        self.acceptedTimeInMs <- map["acceptedTimeInMs"]
        self.handOverTimeInMs <- map["handOverTimeInMs"]
        self.returnHandOverTimeInMs <- map["returnHandOverTimeInMs"]
    }
    
}
