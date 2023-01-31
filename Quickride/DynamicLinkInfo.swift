//
//  DynamicLinkInfo.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 03/05/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
public class DynamicLinkInfo : Mappable{
    
    var dynamicLinkDomain : String?
    var link : String?
    init() {
        
    }
    public required init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        self.dynamicLinkDomain <- map["dynamicLinkDomain"]
        self.link <- map["link"]
    }
}
