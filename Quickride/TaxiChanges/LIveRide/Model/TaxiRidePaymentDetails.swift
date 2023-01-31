//
//  TaxiRidePaymentDetails.swift
//  Quickride
//
//  Created by QR Mac 1 on 21/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiRidePaymentDetails: Mappable {
    
    var rideId: String?
    var amount = 0.0
    var walletType: String?
    var walletInfo: String?
    var userId = 0
    var txnTimeMs = 0
    var txnUpdatedTimeMs = 0
    
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        self.rideId <- map["rideId"]
        self.amount <- map["amount"]
        self.walletType <- map["walletType"]
        self.walletInfo <- map["walletInfo"]
        self.userId <- map["userId"]
        self.txnTimeMs <- map["userId"]
        self.txnUpdatedTimeMs <- map["txnUpdatedTimeMs"]
    }
    
    var classDescription: String {
        return "rideId: \(String(describing: self.rideId)),"
            + "amount: \(String(describing: self.amount)),"
            + "walletType: \(String(describing: self.walletType))," + "walletInfo: \(String(describing: self.walletInfo)),"
            + "userId: \(String(describing: self.userId))," + "txnTimeMs: \(String(describing: self.txnTimeMs)),"
            + "txnUpdatedTimeMs: \(String(describing: self.txnUpdatedTimeMs)),"
    }
}
