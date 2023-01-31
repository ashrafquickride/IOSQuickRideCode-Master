//
//  CompanyVerificationStatus.swift
//  Quickride
//
//  Created by Halesh on 09/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct CompanyVerificationStatus: Mappable {
    
    var emailDomain: String?
    var status: String?
    var verifiedCount = 0
    var id = 0
    var companyName: String?
    var updatedAt = 0
    var registeredCount = 0
    var createdAt = 0
    var updatedBy: String?
    
    static let emailDomain = "emailDomain"
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.emailDomain <- map["emailDomain"]
        self.status <- map["status"]
        self.verifiedCount <- map["verifiedCount"]
        self.id <- map["id"]
        self.companyName <- map["companyName"]
        self.updatedAt <- map["updatedAt"]
        self.registeredCount <- map["registeredCount"]
        self.createdAt <- map["createdAt"]
        self.updatedBy <- map["updatedBy"]
    }
    
    public var description: String {
        return "emailDomain: \(String(describing: self.emailDomain))," + "status: \(String(describing: self.status))," + "verifiedCount: \(String(describing: verifiedCount))," + "id: \(String(describing: id))," + "companyName: \(String(describing: companyName))," + "updatedAt: \(String(describing: updatedAt))," + "registeredCount: \(String(describing: registeredCount))," + "updatedBy: \(String(describing: updatedBy))," + "createdAt: \(String(describing: createdAt)),"
    }
}
