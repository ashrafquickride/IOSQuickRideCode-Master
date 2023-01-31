//
//  ContactRegistrationStatus.swift
//  Quickride
//
//  Created by Halesh on 24/04/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct ContactRegistrationStatus: Mappable{
    var contactName: String?
    var contactNo: String?
    var userStatus: String?
    var contactEmail: String?
    var registeredDate: NSDate?
    var lastRideDate: NSDate?
    var isContactSelected = true
    var userId: Double = 0
    static let NOT_REGISTERED = "NOT_REGISTERED"
    static let REGISTERED = "REGISTERED"
    
    
    init?(map: Map) {
        
    }
    init(){
        
    }
    
    mutating func mapping(map: Map) {
        contactName <- map["contactName"]
        contactNo <- map["contactNo"]
        userStatus <- map["userStatus"]
        contactEmail <- map["contactEmail"]
        registeredDate <- map["registeredDate"]
        lastRideDate <- map["lastRideDate"]
        userId <- map["userId"]
    }
}
