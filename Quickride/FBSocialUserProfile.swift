//
//  SocialUserProfile.swift
//  Quickride
//
//  Created by Admin on 04/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct FBSocialUserProfile : Mappable{
    
    
    var  firstName : String?
    var  lastName: String?
    var  fullName: String?
    var  providerId: String?
    var  id : String?
    var  email: String?
    
    static let socialNetworkTypeGoogle = "google"
    static let socialNetworkTypeFB = "facebook"
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        firstName <- map["first_name"]
        lastName <- map["last_name"]
        fullName <- map["name"]
        id <- map["id"]
        email <- map["email"]
    }
}
