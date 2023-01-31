//
//  UserSystemCoupons.swift
//  Quickride
//
//  Created by QR Mac 1 on 04/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct UserSystemCoupons: Mappable{
    
    var systemCouponCodeListForRole = [SystemCouponCode]()
    var systemCouponCodeListForScheme = [SystemCouponCode]()
    
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.systemCouponCodeListForRole <- map["systemCouponCodeListForRole"]
        self.systemCouponCodeListForScheme <- map["systemCouponCodeListForScheme"]
    }
}
