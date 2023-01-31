//
//  UserFullProfile.swift
//  Quickride
//
//  Created by Anki on 14/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

public class UserFullProfile: NSObject,Mappable{
  
    var userProfile :UserProfile?
    var vehicle:Vehicle?
    var profileVerificationData : ProfileVerificationData?
    var enableChatAndCall = true
    var allowCallsFrom: String?
  
  override init (){
  }
  
  required public init(map:Map){
    
  }
  
  public func mapping(map:Map){
    userProfile <- map["userProfile"]
    vehicle <- map["vehicle"]
    enableChatAndCall <- map["enableChatAndCall"]
    self.allowCallsFrom <- map["allowCallsFrom"]
  }
    public override var description: String {
        return "userProfile: \(String(describing: self.userProfile))," + " vehicle: \( String(describing: self.vehicle))," + " profileVerificationData: \(String(describing: self.profileVerificationData))," + " enableChatAndCall: \(String(describing: self.enableChatAndCall)),"
            + " allowCallsFrom: \(String(describing: self.allowCallsFrom)),"
    }
}

    
