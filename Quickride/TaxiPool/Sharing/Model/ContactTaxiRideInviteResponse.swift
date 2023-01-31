//
//  ContactTaxiRideInviteResponse.swift
//  Quickride
//
//  Created by HK on 29/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ContactTaxiRideInviteResponse: Mappable {
    
    var contactId: String?
    var success = false
    var taxiRideInvite: TaxiPoolInvite?
    var error: ResponseError?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        self.contactId <- map["contactId"]
        self.success <- map["success"]
        self.taxiRideInvite <- map["taxiRideInvite"]
        self.error <- map["error"]
    }
}
