//
//  ReferralLeader.swift
//  Quickride
//
//  Created by Halesh on 24/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ReferralLeader: Mappable{
    
    var userId = 0.0
    var leaderRank = 0
    var userName: String?
    var imageUrl: String?
    var gender: String?
    var companyName: String?
    var bonusEarned = 0
    var activatedReferralCount = 0
    var createdAt: NSDate?
    var profileVerificationData: ProfileVerificationData?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        userId <- map["userId"]
        leaderRank <- map["leaderRank"]
        userName <- map["userName"]
        imageUrl <- map["imageUrl"]
        gender <- map["gender"]
        companyName <- map["companyName"]
        bonusEarned <- map["bonusEarned"]
        activatedReferralCount <- map["activatedReferralCount"]
        createdAt <- map["createdAt"]
        profileVerificationData <- map["profileVerificationData"]
    }
}
