//
//  PersonalIdVerificationResultData.swift
//  Quickride
//
//  Created by Vinutha on 11/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PersonalIdVerificationResultData: NSObject,Mappable {
   
    var details: PersonalIdVerificationDetail?
    var type = ""
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        self.details <- map["details"]
        self.type <- map["type"]
    }
}
