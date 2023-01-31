//
//  LinkedWalletBalance.swift
//  Quickride
//
//  Created by rakesh on 10/2/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class LinkedWalletBalance : NSObject, Mappable{
    
    var userId : Double?
    var type : String?
    var balance = 0.0
    var expired : Bool?
    
    required init?(map: Map) {
        
    }
    init(userId: Double?,type: String?,balance: Double) {
        self.userId = userId
        self.type = type
        self.balance = balance
    }
    func mapping(map: Map) {
        self.userId <- map["userId"]
        self.type <- map["type"]
        self.balance <- map["balance"]
        self.expired <- map["expired"]
    }
    public override var description: String {
        return "balance: \(String(describing: self.balance))," + "userId: \(String(describing: self.userId))," + "type: \(String(describing: self.type))," + "expired: \(String(describing: self.expired))"
    }
}
