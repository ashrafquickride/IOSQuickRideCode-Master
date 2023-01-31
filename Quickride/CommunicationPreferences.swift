//
//  CommunicationPreferences.swift
//  Quickride
//
//  Created by KNM Rao on 07/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class CommunicationPreferences: NSObject, Mappable {
  var userNotificationSetting : UserNotificationSetting?
  var emailPreferences : EmailPreferences?
  var smsPreferences :SMSPreferences?
  var whatsAppPreferences: WhatsAppPreferences?
  var callPreferences: CallPreferences?
  func mapping(map: Map) {
    self.userNotificationSetting <- map["userNotificationSetting"]
    self.emailPreferences <- map["emailPreferences"]
    self.smsPreferences <- map["smsPreferences"]
    self.whatsAppPreferences <- map["whatsAppMessagePreferences"]
    self.callPreferences <- map["callPreferences"]
  }
    init(userNotificationSetting : UserNotificationSetting,emailPreferences : EmailPreferences,smsPreferences :SMSPreferences,whatsAppPreferences: WhatsAppPreferences,callPreferences: CallPreferences){
    self.userNotificationSetting = userNotificationSetting
    self.smsPreferences = smsPreferences
    self.emailPreferences = emailPreferences
    self.whatsAppPreferences = whatsAppPreferences
    self.callPreferences = callPreferences
  }
  required init?(map: Map) {
    
  }
    public override var description: String {
        return "userNotificationSetting: \(String(describing: self.userNotificationSetting))," + "emailPreferences: \(String(describing: self.emailPreferences))," + " smsPreferences: \(String(describing: self.smsPreferences))," + " whatsAppPreferences: \(String(describing: self.whatsAppPreferences))," + " callPreferences: \(String(describing: self.callPreferences)),"
    }
}
