//
//  UserSelfAssessmentCovid.swift
//  Quickride
//
//  Created by Vinutha on 20/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserSelfAssessmentCovid: NSObject, Mappable {
    
    var userId: Double?
    var assessmentResult: String?
    var createdDate: Double?
    var expiryDate: Double = 0
    
    static var PASS = "PASS"
    static var FAIL = "FAIL"
    
    override init() { }
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        userId <- map["userId"]
        assessmentResult <- map["assessmentResult"]
        createdDate <- map["assessmentTime"]
        expiryDate <- map["expiryTime"]
    }
}
