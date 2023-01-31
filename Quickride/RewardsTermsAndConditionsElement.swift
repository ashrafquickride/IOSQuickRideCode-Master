//
//  RewardsTermsAndConditionElement.swift
//  Quickride
//
//  Created by Halesh on 03/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RewardsTermsAndConditionsElement : NSObject, Mappable{
    
    var type : String?
    var terms_and_conditions : [String]?
    
    
    
   required init?(map: Map) {
        
    }
    
    
    func mapping(map: Map) {
        self.type <- map["type"]
        self.terms_and_conditions <- map["terms and conditions"]
    }
    public override var description: String {
        return "type: \(String(describing: self.type))," + "terms_and_conditions: \(String(describing: self.terms_and_conditions)),"
    }
    
}
