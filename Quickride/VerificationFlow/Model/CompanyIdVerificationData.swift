//
//  CompanyIdVerificationData.swift
//  Quickride
//
//  Created by Vinutha on 07/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class CompanyIdVerificationData: NSObject, Mappable {
    
    var id: Double?
    var email: String?
    var userId: Double?
    var imgUrlList: String?
    var approverId: String?
    var approverName: String?
    var rejectReason: String?
    
    static let FLD_FRONT_SIDE_IMAGE_URL = "frontSideImageUri"
    static let FLD_BACK_SIDE_IMAGE_URL = "backSideImageUri"
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        userId <- map["userId"]
        imgUrlList <- map["imgUrlList"]
        approverId <- map["approverId"]
        approverName <- map["approverName"]
        rejectReason <- map["rejectReason"]
    }
}
