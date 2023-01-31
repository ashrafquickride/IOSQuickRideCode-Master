//
//  ReferralStats.swift
//  Quickride
//
//  Created by Halesh on 24/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ReferralStats: Mappable {
    
    var userId = 0.0
    var level = 0
    var totalReferralCount = 0
    var activatedReferralCount = 0
    var bonusEarned = 0.0
    var co2SavedFromReferral = 0.0
    var noOfVehicleRemovedFromRoad = 0
    var potentialEarning = 0
    var referralLevelConfigList = [ReferralLevelConfiguration]()
    var termsAndConditions = [String]()
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        userId <- map["userId"]
        level <- map["level"]
        totalReferralCount <- map["totalReferralCount"]
        activatedReferralCount <- map["activatedReferralCount"]
        bonusEarned <- map["bonusEarned"]
        co2SavedFromReferral <- map["co2SavedFromReferral"]
        noOfVehicleRemovedFromRoad <- map["noOfVehicleRemovedFromRoad"]
        potentialEarning <- map["potentialEarning"]
        referralLevelConfigList <- map["referralLevelConfigList"]
        termsAndConditions <- map["termsAndConditions"]
    }
    
    public var description: String {
        return "userId: \(String(describing: self.userId))," + "level: \(String(describing: self.level))," + " totalReferralCount: \( String(describing: self.totalReferralCount))," + " activatedReferralCount: \(String(describing: self.activatedReferralCount))," + " bonusEarned: \(String(describing: self.bonusEarned)),"
            + " co2SavedFromReferral: \(String(describing: self.co2SavedFromReferral))," + " noOfVehicleRemovedFromRoad: \(String(describing: self.noOfVehicleRemovedFromRoad))," + " potentialEarning: \(String(describing: self.potentialEarning)),"
            + " referralLevelConfigList: \(String(describing: self.referralLevelConfigList))," + " termsAndConditions: \(String(describing: self.termsAndConditions)),"
    }
    
}
