//
//  AWSIosConnectCredentials.swift
//  Quickride
//
//  Created by Admin on 27/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct AWSIosConnectCredentials : Mappable {
    
    var iotCoreEndPoint : String?
    var awsAccessId : String?
    var awsSecretAccessKey : String?
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        iotCoreEndPoint <- map["iotCoreEndPoint"]
        awsAccessId <- map["awsAccessId"]
        awsSecretAccessKey <- map["awsSecretAccessKey"]
    }
    
}
