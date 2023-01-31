//
//  ShortDynamicLinkParams.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 03/05/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ShortDynamicLinkParams : Mappable {
    
    var dynamicLinkInfo : DynamicLinkInfo?
    init() {
        
    }
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        self.dynamicLinkInfo <- map["dynamicLinkInfo"]
    }
}
