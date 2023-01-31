//
//  UserSession.swift
//  Quickride
//
//  Created by KNM Rao on 24/10/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public enum UserSessionStatus {
  
  case Unknown
  case User
  case Guest
}

public class UserSession {
  
  var userId : String = "0"
  var userPassword : String = ""
  var userSessionStatus : UserSessionStatus?
  var contactNo : String = ""
  var otp = ""
  var countryCode : String?
   = (Locale.current as NSLocale).object(forKey: .countryCode) as? String

    
init(){
    self.userSessionStatus = .Unknown
  }
  
  init(userId : String, userPassword  : String, userSessionStatus: UserSessionStatus,contactNo : String,countryCode : String?){
    self.userId = userId
    self.userPassword = userPassword
    self.userSessionStatus = userSessionStatus
    self.contactNo = contactNo
    self.countryCode = countryCode
  }
  
}
