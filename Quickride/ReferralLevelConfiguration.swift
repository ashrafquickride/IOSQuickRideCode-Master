//
//  ReferralLevelConfiguration.swift
//  Quickride
//
//  Created by Halesh on 11/05/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ReferralLevelConfiguration: Mappable {
    
    var level = 0
    var minReferrals = 0
    var referralBenefits = [String]()
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        level <- map["level"]
        minReferrals <- map["minReferrals"]
        referralBenefits <- map["referralBenefits"]
    }
    
    public var description: String {
        return "level: \(String(describing: self.level))," + " minReferrals: \( String(describing: self.minReferrals))," + " referralBenefits: \(String(describing: self.referralBenefits)),"
    }
}
