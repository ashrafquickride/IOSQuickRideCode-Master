//
//  EndorsableUser.swift
//  Quickride
//
//  Created by Vinutha on 07/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EndorsableUser: NSObject, Mappable {
    
    var userId: Double?
    var name = ""
    var contactNo: Double?
    var endorsementStatus: String?
    var callSupport: String?
    var enableChatAndCall: Bool?
    var imageURI: String?
    var companyName: String?
    var gender: String?
    
    static let FLD_ENDORSABLE_USER = "FLD_ENDORSABLE_USER"
    static let FLD_REQUESTOR_USER_ID = "requestorUserId"
    static let FLD_REJECT_REASON = "rejectReason"
    static let STATUS_INITIATED = "Initiated"
    static let STATUS_VERIFIED = "Verified"
    static let STATUS_REJECTED = "Rejected"
    static let PENDING = "Pending"
    static let STATUS_VERIFIED_CAPS = "VERIFIED"
    
    override init() { }
    
    init(endorsementVerificationInfo: EndorsementVerificationInfo) {
        self.userId = endorsementVerificationInfo.endorsedBy
        self.name = endorsementVerificationInfo.name
        self.endorsementStatus = endorsementVerificationInfo.endorsementStatus
        self.companyName = endorsementVerificationInfo.companyName
        self.imageURI = endorsementVerificationInfo.imageURI
        self.gender = endorsementVerificationInfo.gender
    }
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        userId <- map["userId"]
        name <- map["name"]
        contactNo <- map["contactNo"]
        endorsementStatus <- map["endorsementStatus"]
        callSupport <- map["callSupport"]
        enableChatAndCall <- map["enableChatAndCall"]
        imageURI <- map["imageURI"]
        companyName <- map["companyName"]
        gender <- map["gender"]
    }
}
