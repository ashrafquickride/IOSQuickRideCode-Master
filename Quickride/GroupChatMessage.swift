//
//  GroupChatMessage.swift
//  Quickride
//
//  Created by Anki on 13/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class GroupChatMessage : QuickRideMessageEntity{
  
  var groupchatmessgeid:Double = 0.0
  var rideId:Double = 0.0
  var phonenumber:Double = 0.0
  var userName: String = ""
  var chatTime: Double = 0
  var message: String = ""
  var latitude : Double = 0.0
  var longitude : Double = 0.0
  var address : String = ""
  
  public override init() {
    super.init()
  }
  
  required public init(_ map:Map){
    super.init()
  }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
  
  public override func mapping(map: Map){
    super.mapping(map: map)
    groupchatmessgeid <- map["id"]
    rideId <- map["rideId"]
    phonenumber <- map["userId"]
    userName <- map["userName"]
    chatTime <- map["chatTime"]
    message <- map["message"]
    latitude <- map["latitude"]
    longitude <- map["longitude"]
    address <- map["address"]
  }
    override func getParams() -> [String : String]{
    AppDelegate.getAppDelegate().log.debug("")
        var params = super.getParams()
        params["riderRideId"] = StringUtils.getStringFromDouble(decimalNumber : rideId)
        params["userId"] = StringUtils.getStringFromDouble(decimalNumber : phonenumber)
        params["userName"] = userName
        params["chatTime"] = StringUtils.getStringFromDouble(decimalNumber : chatTime)
        params["message"] = message
        params["latitude"] = String(latitude)
        params["longitude"] = String(longitude)
        params["address"] = address
        return params

    }
}
