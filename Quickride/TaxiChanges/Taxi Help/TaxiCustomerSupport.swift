//
//  TaxiCustomerSupport.swift
//  Quickride
//
//  Created by HK on 17/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiCustomerSupport: Mappable {
    
    var taxiHelp = [TaxiHelpFaqCategory]()
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        self.taxiHelp <- map["taxiHelp"]
    }
}
