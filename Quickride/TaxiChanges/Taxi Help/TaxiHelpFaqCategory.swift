//
//  TaxiHelpFaqCategory.swift
//  Quickride
//
//  Created by HK on 17/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiHelpFaqCategory: Mappable{
    
    var name: String?
    var faqList = [TaxiHelpFaq]()
    
    required init?(map: Map) {}
    init() {}
    func mapping(map: Map) {
        self.name <- map["name"]
        self.faqList <- map["faqList"]
    }
}
