//
//  AvailableItems.swift
//  Quickride
//
//  Created by Halesh on 20/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct AvailableItems: Mappable{
    
    var matchedProductListings = [AvailableProduct]()
    var offSet = 0
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.matchedProductListings <- map["matchedProductListings"]
        self.offSet <- map["offSet"]
    }
}
