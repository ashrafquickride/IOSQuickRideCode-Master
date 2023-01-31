//
//  ProductRating.swift
//  Quickride
//
//  Created by QR Mac 1 on 27/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ProductRating: Mappable{
    
    var count = 0
    var rating = 0
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.count <- map["count"]
        self.rating <- map["rating"]
    }
}
