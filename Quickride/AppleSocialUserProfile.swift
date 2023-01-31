//
//  AppleSocialUserProfile.swift
//  Quickride
//
//  Created by Halesh on 01/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

struct AppleSocialUserProfile{
    
    var  firstName : String?
    var  lastName: String?
    var  fullName: String?
    var  providerId: String?
    var  id : String?
    var  email: String?
    
    static let socialNetworkTypeApple = "appleId"
    
    init(firstName : String,lastName: String,fullName: String,email: String,providerId: String,id: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.email = email
        self.providerId = providerId
        self.id = id
    }
}
