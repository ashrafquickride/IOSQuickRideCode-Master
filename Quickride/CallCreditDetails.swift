//
//  CallCreditDetails.swift
//  Quickride
//
//  Created by QR Mac 1 on 17/02/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
struct CallCreditDetails: Mappable {
    
    var id: String?
    var userID: Int = 0
    var callCredits : Int = 0
    var createdTimeMS: Int = 0
    var lastModifiedTimeMS: Int = 0
    
    init?(map: Map) {
        
    }

    mutating func mapping(map: Map) {
        self.id <- map["id"]
        self.createdTimeMS <- map["createdTimeMS"]
        self.lastModifiedTimeMS <- map["lastModifiedTimesMS"]
        self.callCredits <- map["callCredits"]
    }

}
