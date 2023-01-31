//
//  GoogleSocialUserProfile.swift
//  Quickride
//
//  Created by Admin on 04/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

struct GoogleSocialUserProfile{
    
    var userId : String?
    var givenName : String?
    var familyName: String?
    var fullName: String?
    var providerId: String?
    var email: String?
    var imageUrl : String?
    
    static let socialNetworkTypeGoogle = "google"
   
}
