//
//  PaymentStatusUpdate.swift
//  Quickride
//
//  Created by Rajesab on 27/07/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct PaymentStatusUpdate: Mappable {
    
    var userId: Double?
    var refId: String?
    var sourceApplication: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        self.userId <- map["userId"]
        self.refId <- map["refId"]
        self.sourceApplication <- map["sourceApplication"]
    }
    
    var description: String{
        return "userId: \(String(describing: self.userId))"
        + "refId: \(String(describing: self.refId))"
        + "sourceApplication: \(String(describing: self.sourceApplication))"
    }
}
