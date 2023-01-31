//
//  MyPostedProduct.swift
//  Quickride
//
//  Created by QR Mac 1 on 10/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct MyPostedProduct: Mappable{

    var countOfActiveRequests = 0
    var postedProduct: PostedProduct?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.countOfActiveRequests <- map["countOfActiveRequests"]
        self.postedProduct <- map["productListingDto"]
    }
}
