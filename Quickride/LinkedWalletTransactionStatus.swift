//
//  LinkedWalletTransactionStatus.swift
//  Quickride
//
//  Created by Vinutha on 15/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class LinkedWalletTransactionStatus: NSObject,Mappable{
    
    var rideId: Double?
    var transactionId: String?
    var status: String?
    
    static var LINKED_WALLLET_TRANSACTION_RESERVE = "RESERVE"
    
    override init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
       self.rideId <- map["rideId"]
       self.transactionId <- map["transactionId"]
       self.status <- map["status"]
    }
    
    public override var description: String {
        return "rideId: \(String(describing: self.rideId))," + " transactionId: \(String(describing: self.transactionId))," + " status: \(String(describing: self.status))"
    }
}
