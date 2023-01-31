//
//  PersonalIdVerificationData.swift
//  Quickride
//
//  Created by Vinutha on 11/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PersonalIdVerificationData: NSObject, Mappable {
    
    var value: String?
    var addressForDL: AddressValueForDL?
    var conf: Int?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        value <- map["value"]
        addressForDL <- map["value"]
        conf <- map["conf"]
    }
    
}

class AddressValueForDL: NSObject, Mappable  {
    
    var value: String?
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        value <- map["value"]
    }
    
    
}

