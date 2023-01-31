//
//  SMSPreferences.swift
//  Quickride
//
//  Created by KNM Rao on 07/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class SMSPreferences: NSObject, Mappable,NSCopying {
  
  var userId : Double?
  var receiveRideInvites = false
  var receiveRideMatches = false
  var receiveRideStatus = false
  var receiveAutoConfirm = false
    
  static let USER_ID = "userId"
  static let RECEIVE_RIDE_INVITES = "receiveRideInvites"
  static let RECEIVE_RIDE_MATCHES = "receiveRideMatches"
  static let RECEIVE_RIDE_STATUS = "receiveRideStatus"
  static let RECEIVE_AUTO_CONFIRM_STATUS = "receiveAutoConfirm"
    
  func mapping(map: Map) {
    self.userId <- map["userId"]
    self.receiveRideInvites <- map["receiveRideInvites"]
    self.receiveRideMatches <- map["receiveRideMatches"]
    self.receiveRideStatus <- map["receiveRideStatus"]
    self.receiveAutoConfirm <- map["receiveAutoConfirm"]
  }
  required init?(map: Map) {
    
  }
  override init(){
    if QRSessionManager.getInstance()?.getUserId() != nil{
        userId = Double(QRSessionManager.getInstance()!.getUserId())
    }
    receiveRideInvites = false
    receiveRideMatches = false
    receiveRideStatus = false
    receiveAutoConfirm = false
  }
  
  func  getParamsMap() -> [String : String] {
    var params : [String : String] = [String : String]()
    params["userId"] =  StringUtils.getStringFromDouble(decimalNumber: userId)
    params["receiveRideInvites"] = String(receiveRideInvites)
    params["receiveRideMatches"] = String(receiveRideMatches)
    params["receiveRideStatus"] = String(receiveRideStatus)
    params["receiveAutoConfirm"] = String(receiveAutoConfirm)
    return params
  }
   public func copy(with zone: NSZone? = nil) -> Any
   {
    let smsPreferences = SMSPreferences()
    smsPreferences.userId = self.userId
    smsPreferences.receiveRideInvites = self.receiveRideInvites
    smsPreferences.receiveRideMatches = self.receiveRideMatches
    smsPreferences.receiveRideStatus = self.receiveRideStatus
    smsPreferences.receiveAutoConfirm = self.receiveAutoConfirm
    return smsPreferences
  }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "receiveRideInvites: \(String(describing: self.receiveRideInvites))," + " receiveRideMatches: \(String(describing: self.receiveRideMatches))," + " receiveRideStatus: \(String(describing: self.receiveRideStatus))," + " receiveAutoConfirm: \(String(describing: self.receiveAutoConfirm)),"
    }
}
