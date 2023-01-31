//
//  GroupConversationMessage.swift
//  Quickride
//
//  Created by QuickRideMac on 3/19/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class GroupConversationMessage: QuickRideMessageEntity {
    var id : Double = 0
    var groupId : Double = 0
    var senderId : Double = 0
    var senderName : String?
    var message : String?
    var time : Double = 0
    
    static let FLD_ID = "id"
    static let FLD_GROUP_ID = "groupId"
    static let FLD_SENDER_ID = "senderId"
    static let FLD_SENDER_NAME = "senderName"
    static let FLD_MESSAGE = "message"
    static let FLD_TIME = "time"
    
    public init (groupId : Double, senderId : Double, senderName : String,  message : String, time : Double) {
        super.init()
        
        self.groupId = groupId
        self.senderId = senderId
        self.senderName = senderName
        self.message = message
        self.time = time
    }
    override init(){
        super.init()
    }
   
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    override func getParams() -> [String : String]{
        var params = super.getParams()
        params[GroupConversationMessage.FLD_ID] = StringUtils.getStringFromDouble(decimalNumber: id)
        params[GroupConversationMessage.FLD_GROUP_ID] = StringUtils.getStringFromDouble(decimalNumber: groupId)
        params[GroupConversationMessage.FLD_SENDER_ID] =  StringUtils.getStringFromDouble(decimalNumber:senderId)
        params[GroupConversationMessage.FLD_SENDER_NAME] = senderName
        params[GroupConversationMessage.FLD_MESSAGE] = message
        params[GroupConversationMessage.FLD_TIME] = StringUtils.getStringFromDouble(decimalNumber: time)
        return params
    }
    override func mapping(map: Map) {
        super.mapping(map: map)
        self.id <- map["id"]
        self.groupId <- map["groupId"]
        self.senderId <- map["senderId"]
        self.senderName <- map["senderName"]
        self.message <- map["message"]
        self.time <- map["time"]

    }
}
