//
//  TaxiHelpFaq.swift
//  Quickride
//
//  Created by HK on 17/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class TaxiHelpFaq: Mappable {
    
    var question: String?
    var answer: String?
    var statusApplicable = [String]()
    var tripTypeApplicable = [String]()
    var sharing = [String]()
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.question <- map["question"]
        self.answer <- map["answer"]
        self.statusApplicable <- map["statusApplicable"]
        self.tripTypeApplicable <- map["tripTypeApplicable"]
        self.sharing <- map["sharing"]
    }
}
