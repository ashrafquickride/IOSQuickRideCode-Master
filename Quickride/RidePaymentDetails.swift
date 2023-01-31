//
//  RidePaymentDetails.swift
//  Quickride
//
//  Created by Rajesab on 12/11/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RidePaymentDetails: NSObject, Mappable {
    var rideId: String?
    var amount: Double?
    var walletType: String?
    var walletInfo: String?
    var userId: Int64 = 0
    var txnTimeMs: Int64?
    var txnUpdatedTimeMs: Int64?
    var status: String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        rideId <- map["rideId"]
        amount <- map["amount"]
        walletType <- map["walletType"]
        walletInfo <- map["walletInfo"]
        userId <- map["userId"]
        txnTimeMs <- map["txnTimeMs"]
        txnUpdatedTimeMs <- map["txnUpdatedTimeMs"]
        status <- map["status"]
    }
    
    public override var description: String {
        return "rideId: \(String(describing: self.rideId))," +
        "amount: \(String(describing: self.amount))," +
        "walletType: \(String(describing: self.walletType))," +
        "walletInfo: \(String(describing: self.walletInfo))," +
        "userId: \(String(describing: self.userId))," +
        "txnTimeMs: \(String(describing: self.txnTimeMs))," +
        "txnUpdatedTimeMs: \(String(describing: self.txnUpdatedTimeMs))," +
        "status: \(String(describing: self.status)),"
    }
}

