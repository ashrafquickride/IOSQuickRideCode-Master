//
//  GreetingDetails.swift
//  Quickride
//
//  Created by iDisha on 21/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class GreetingDetails: NSObject, Mappable {
    
    var type: String?
    var message: String?
    var displayedCount = 0
    var gifImageUrl: String?
    var greetingDetails : [GreetingDetails]?
    
    required init?(map: Map) { }
    
    override init() { }
    
    func mapping(map: Map) {
        self.type <- map["type"]
        self.message <- map["message"]
        self.gifImageUrl <- map["gifImageUrl"]
        self.greetingDetails <- map["GreetingDetails"]
    }
    
    
}
