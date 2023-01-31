//
//  RewardsTermsAndConditions.swift
//  Quickride
//
//  Created by Halesh on 03/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RewardsTermsAndConditions: NSObject, Mappable {
    
    var referAndRewardsTermsAndConditions : [RewardsTermsAndConditionsElement]?
    
    static let REFER_FRIENDS = "REFER_FRIENDS"
    static let PHONEBOOK_REFERRAL = "PHONEBOOK_REFERRAL"
    static let REFER_ORGANIZATION = "REFER_ORGANIZATION"
    static let REFER_COMMUNITY = "REFER_COMMUNITY"
    
    required init?(map: Map) {
    
    }
    
    func mapping(map: Map) {
        referAndRewardsTermsAndConditions <- map["ReferAndRewardsTermsAndConditions"]
    }
    
    
 
}
