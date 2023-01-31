//
//  SocialUserStatus.swift
//  Quickride
//
//  Created by Admin on 04/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct SocialUserStatus : Mappable{
    
    
    var status : String?
    var phone : Double?
    var password : String?
    var contactNo : Double?
    
    static let socialNetworkId = "socialnetworkid"
    static let socialNetworkType = "socialnetworktype"
    static let status_new = "NEW"
    static let status_registered = "REGISTERED"
    static let status_activated = "ACTIVATED"
 
    init?(map: Map) {
    }
     
     mutating func mapping(map: Map) {
         status <- map["status"]
         phone <- map["phone"]
         password <- map["pwd"]
         contactNo <- map["contactNo"]
     }
}
