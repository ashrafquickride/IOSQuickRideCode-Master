//
//  LinkedWalletPendingTransaction.swift
//  Quickride
//
//  Created by Admin on 05/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct LinkedWalletPendingTransaction : Mappable{
   
    
    var rideId : Double?
    var transactionId : String?
    var riderName : String?
    var startTime : Double?
    var amount : Double?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
      rideId <- map["rideId"]
      transactionId <- map["transactionId"]
      riderName <- map["riderName"]
      startTime <- map["startTime"]
      amount <- map["amount"]
    }
    public var description: String {
        return "rideId: \(String(describing: self.rideId))," + "transactionId: \(String(describing: self.transactionId))," + " riderName: \( String(describing: self.riderName))," + " startTime: \(String(describing: self.startTime))," + " amount: \(String(describing: self.amount)),"
    }
}


