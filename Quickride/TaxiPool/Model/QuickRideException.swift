//
//  QuickRideException.swift
//  Quickride
//
//  Created by Ashutos on 06/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class QuickRideException: NSObject, Mappable {
    var error : ResponseError?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.error <- map["error"]
    }
    
    public override var description: String {
        return "error: \(String(describing: self.error))"
    }
}
