//
//  RmqBrokerConnectInfo.swift
//  Quickride
//
//  Created by Admin on 27/12/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct RmqBrokerConnectInfo : Mappable {
    
    var brokerIp : String?
    var brokerPort : Int?
    
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        brokerIp <- map["brokerIp"]
        brokerPort <- map["brokerPort"]
    }
    
    
}
