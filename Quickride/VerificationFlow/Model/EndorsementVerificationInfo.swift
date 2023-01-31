//
//  EndorsementVerificationInfo.swift
//  Quickride
//
//  Created by Vinutha on 07/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EndorsementVerificationInfo: NSObject, Mappable {
    
    var userId: Double?
    var endorsedBy: Double?
    var endorsementStatus: String?
    var name = ""
    var imageURI: String?
    var companyName: String?
    var gender: String?
    
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        userId <- map["userId"]
        endorsedBy <- map["endorsedBy"]
        endorsementStatus <- map["endorsementStatus"]
        name <- map["name"]
        imageURI <- map["imageURI"]
        companyName <- map["companyName"]
        gender <- map["gender"]
    }
}
