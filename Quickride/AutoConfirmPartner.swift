//
//  AutoConfirmPartner.swift
//  Quickride
//
//  Created by Ashutos on 29/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.

import Foundation
import ObjectMapper

struct AutoConfirmPartner: Mappable{
        
    static var AUTO_CONFIRM_STATUS_ENABLE = "ENABLE"
    static var AUTO_CONFIRM_STATUS_DISABLE = "DISABLE"
    
    var enableAutoConfirm = AUTO_CONFIRM_STATUS_DISABLE
    var userId : Double?
    var partnerId: String?
    var partnerName : String = ""
    var partnerGender = ""
    var partnerType = ""
    var imageURI: String?
    
    init(enableAutoConfirm: String, userId: Double, partnerId: String, partnerName: String, partnerGender: String, imageURI : String, partnerType: String) {
        self.userId = userId
        self.enableAutoConfirm = enableAutoConfirm
        self.partnerId = partnerId
        self.partnerName = partnerName
        self.partnerGender = partnerGender
        self.partnerType = partnerGender
        self.imageURI = imageURI
    }
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.userId <- map["userId"]
        self.enableAutoConfirm <- map["enableAutoConfirm"]
        self.partnerId <- map["partnerId"]
        self.partnerName <- map["partnerName"]
        self.partnerGender <- map["partnerGender"]
        self.partnerType <- map["partnerType"]
        self.imageURI <- map["imageURI"]
    }
    
    
}

