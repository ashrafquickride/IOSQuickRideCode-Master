//
//  CustomerSupport.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 17/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class  CustomerSupport : NSObject, Mappable{
    required init?(map: Map) {
    }
    
    var customerSupportGroup : [CustomerSupportGroup]?
    var customerSupportElement : CustomerSupportElement?
    
    init(customerSupportGroup : [CustomerSupportGroup]? , customerSupportElement : CustomerSupportElement?)
    {
        self.customerSupportGroup = customerSupportGroup
        self.customerSupportElement = customerSupportElement
    }
    
    public func mapping(map: Map) {
        customerSupportGroup <- map["customerSupportGroup"]
        customerSupportElement <- map["customerSupportElement"]

    }
}
