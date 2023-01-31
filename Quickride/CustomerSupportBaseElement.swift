//
//  CustomerSupportBaseElement.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 18/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import  ObjectMapper

class CustomerSupportBaseElement: NSObject, Mappable
{
    var customerSupportElement : CustomerSupportElement?
    init(customerSupportElement : CustomerSupportElement?)
    {
        self.customerSupportElement = customerSupportElement
    }
    required init?(map: Map) {
        
    }
     public func mapping(map: Map)
     {
        customerSupportElement <- map["customerSupportElement"]
     }
}
