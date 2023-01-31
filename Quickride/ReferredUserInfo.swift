//
//  ReferredUserInfo.swift
//  Quickride
//
//  Created by Halesh on 24/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ReferredUserInfo: Mappable {
    
    var userId = 0
    var referredUserId = 0
    var referredUserName: String?
    var gender: String?
    var referredUserImageUri: String?
    var referredUserCompany: String?
    var verificationBonus = 0.0
    var firstRideBonus = 0.0
    var serviceFeeShare = 0.0
    var co2SavedByReferredUser = 0.0
    var profileVerificationData: ProfileVerificationData?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        userId <- map["userId"]
        referredUserName <- map["referredUserName"]
        referredUserId <- map["referredUserId"]
        gender <- map["gender"]
        referredUserImageUri <- map["referredUserImageUri"]
        referredUserCompany <- map["referredUserCompany"]
        verificationBonus <- map["verificationBonus"]
        firstRideBonus <- map["firstRideBonus"]
        serviceFeeShare <- map["serviceFeeShare"]
        co2SavedByReferredUser <- map["co2SavedByReferredUser"]
        profileVerificationData <- map["profileVerificationData"]
    }
    public var description: String {
        return "userId: \(String(describing: self.userId))," + "referredUserId: \(String(describing: self.referredUserId))," + " gender: \( String(describing: self.gender))," + " referredUserImageUri: \(String(describing: self.referredUserImageUri))," + " referredUserCompany: \(String(describing: self.referredUserCompany)),"
            + " verificationBonus: \(String(describing: self.verificationBonus))," + " firstRideBonus: \(String(describing: self.firstRideBonus))," + " serviceFeeShare: \(String(describing: self.serviceFeeShare)),"
            + " co2SavedByReferredUser: \(String(describing: self.co2SavedByReferredUser))," + " profileVerificationData: \(String(describing: self.profileVerificationData)),"
    }
}
