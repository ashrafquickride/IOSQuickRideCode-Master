//
//  FreechargeResponse.swift
//  Quickride
//
//  Created by Halesh on 10/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct FreechargeResponse : Mappable{
    
    var status: String?
    var signUp: String?
    var otpId: String?
    
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map){
        status <- map["status"]
        signUp <- map["signUp"]
        otpId <- map["otpId"]
    }
    public var description: String {
        return "status: \(String(describing: self.status))," + "signUp: \(String(describing: self.signUp))," + "otpId: \(String(describing: self.otpId)),"
    }
}
