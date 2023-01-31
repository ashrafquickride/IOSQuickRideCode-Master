//
//  EndorsementRequestNotificationData.swift
//  Quickride
//
//  Created by Vinutha on 09/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EndorsementRequestNotificationData: NSObject, Mappable {
    
    var name: String?
    var userId: String?
    var allowCallsFrom: String?
    var allowChatAndCallFromUnverifiedUsers: String?
    
    override init() {}
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        name <- map["name"]
        userId <- map["userId"]
        allowCallsFrom <- map["allowCallsFrom"]
        allowChatAndCallFromUnverifiedUsers <- map["allowChatAndCallFromUnverifiedUsers"]
    }
}
