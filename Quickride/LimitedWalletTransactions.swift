//
//  LimitedWalletTransactions.swift
//  Quickride
//
//  Created by QR Mac 1 on 25/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct LimitedWalletTransactions: Mappable {
    
    var userId: Int?
    var walletType: String? //QRWALLET
    var walletProvider: String? //OTHER WALLETS
    var amount: Double? // contains reserverd amount released amount
    var txnType: String? // RESERVED, RELEASED
    
    static let QRWALLET = "QRWALLET"
    static let RESERVED = "RESERVE"
    static let RELEASED = "RELEASE"
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map:Map){
        userId <- map["userId"]
        walletType <- map["walletType"]
        walletProvider <- map["walletProvider"]
        amount <- map["amount"]
        txnType <- map["txnType"]
    }
}
