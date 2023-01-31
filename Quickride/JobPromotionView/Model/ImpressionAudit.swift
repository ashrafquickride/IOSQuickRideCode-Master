//
//  ImpressionAudit.swift
//  Quickride
//
//  Created by Vinutha on 16/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ImpressionAudit {
    
    var id = 0
    var userId = 0
    var campaignId = 0
    var createdTime = 0
    var type: String?
    var deviceType: String?
    var screenName: String?
    
    static let IMPRESSION_AUDIT_DATA = "impressionAuditData"
    
    // Device types
    static let DEVICE_TYPE_IOS = "IOS"
    static let RideMatching = "RideMatching"
    static let Homepage = "Homepage"
    static let LiveRide = "LiveRide"
    static let TripReport = "TripReport"

    init(userId: Int, campaignId: Int, createdTime: Int,type: String,deviceType: String,screenName: String) {
        self.userId = userId
        self.campaignId = campaignId
        self.createdTime = createdTime
        self.type = type
        self.deviceType = deviceType
        self.screenName = screenName
    }
    
    func getParamsMap() -> [String: String] {
        var params = [String: String]()
        params["userId"] = String(userId)
        params["campaignId"] = String(campaignId)
        params["createdTime"] = String(createdTime)
        params["type"] = type
        params["deviceType"] = deviceType
        params["screenName"] = screenName
        return params
    }
}
