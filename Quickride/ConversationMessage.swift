//
//  ConversationMessage.swift
//  Quickride
//
//  Created by QuickRideMac on 07/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ConversationMessage : QuickRideMessageEntity{
    
    var sourceId : Double?
    var message : String?
    var time : Double?
    var destId : Double?
    var msgStatus : Int?
    var msgType : Int?
    var actualMessageId : String?
    var latitude : Double = 0
    var longitude : Double = 0
    var address : String?
    var sourceName: String?
    var sourceApplication: String?
    
    static let SOURCE_APPLICATION_P2P = "P2P"

  static let MSG_TYPE_NEW = 1
  static let MSG_TYPE_STATUS = 2
  static let MSG_STATUS_FAILED = 1
  static let MSG_STATUS_DELIVERED = 2
  static let MSG_STATUS_NEW = 3
  static let MSG_STATUS_SENT = 5
  static let MSG_STATUS_READ = 4
  static let SOURCE_ID = "sourceId"
  static let DEST_ID = "destId"
  static let TIME = "time"
  static let MESSAGE = "message"
  static let MESSAGE_STATUS = "msgStatus"
  static let MESSAGE_TYPE = "msgType"
  init(sourceId : Double,destId : Double,time : Double,msgStatus : Int,msgType : Int)
  {
    self.sourceId = sourceId
    self.destId = destId
    self.time = time
    self.msgStatus = msgStatus
    self.msgType = msgType
    super.init()
  }
  
    override init(){
        super.init()
    }
    required init?(_ map: Map) {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    override var debugDescription: String {
        return "sourceId: \(sourceId),destId: \(destId), message: \(message), uniqueId: \(uniqueID) "
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        self.sourceId <- map["sourceId"]
        self.message <- map["message"]
        self.time <- map["time"]
        self.destId <- map["destId"]
        self.msgType <- map["msgType"]
        self.msgStatus <- map["msgStatus"]
        self.actualMessageId <- map["actualMessageId"]
        self.latitude <- map["latitude"]
        self.longitude <- map["longitude"]
        self.address <- map["address"]
        self.sourceName <- map["sourceName"]
        self.sourceApplication <- map["sourceApplication"]
    }
    override func getParams() -> [String : String] {
      AppDelegate.getAppDelegate().log.debug("")
        var params = super.getParams()
        params["sourceId"] = StringUtils.getStringFromDouble(decimalNumber : self.sourceId)
        params["message"] = self.message
        params["destId"] =  StringUtils.getStringFromDouble(decimalNumber : self.destId)
        params["msgStatus"] = String(self.msgStatus!)
        params["msgType"] = String(self.msgType!)
        params["time"] = StringUtils.getStringFromDouble(decimalNumber : self.time)
        params["actualMessageId"] = self.actualMessageId
        if self.latitude != 0 && self.longitude != 0
        {
            params["latitude"] = String(self.latitude)
            params["longitude"] = String(self.longitude)
            params["address"] = self.address
        }
        params["sourceName"] = self.sourceName
        params["sourceApplication"] = self.sourceApplication
        return params
    }
}
