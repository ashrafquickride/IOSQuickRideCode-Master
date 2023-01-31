//
//  CustomerSupportGroup.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 17/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class CustomerSupportGroup : NSObject, Mappable {

    
    var groupName : String?
    var customerSupportItems : [CustomerSupport] = [CustomerSupport]()
    
    init(groupName : String? , customerSupportItems : [CustomerSupport]? ) {
        self.groupName = groupName
        self.customerSupportItems = customerSupportItems!
     
    }
    
    required init?(map: Map) {
        
    }
    public func mapping(map: Map) {
        
        groupName <- map["groupName"]
        customerSupportItems <- map["customerSupportItems"]
    
    }
    
}
