//
//  TaxiTnCSummary.swift
//  Quickride
//
//  Created by Ashutos on 07/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiTnCSummary: Mappable {
    
    var inclusions: [TaxiTnCData] = []
    var exclusions: [TaxiTnCData] = []
    var facilities: [TaxiTnCData] = []
    var extras: [TaxiTnCData] = []
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.inclusions <- map["inclusions"]
        self.exclusions <- map["exclusions"]
        self.facilities <- map["facilities"]
        self.extras <- map["extras"]
    }
    
    var description: String {
        return "inclusions: \(String(describing: self.inclusions)),"
            + "exclusions: \(String(describing: self.exclusions)),"
            + "facilities: \(String(describing: self.facilities)),"
            + "extras: \(String(describing: self.extras))"
    }
}
