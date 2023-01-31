//
//  Referral.swift
//  Quickride
//
//  Created by Anki on 13/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class Referral:NSObject,Mappable {
  
  var referralCode:String?
  var referralOwnerId:Double?
  var status:String?
  
  required init(map:Map){
    
  }
  
  func mapping(map:Map){
    referralCode <- map["referralCode"]
    referralOwnerId <- map["referralOwnerId"]
    status <- map["status"]
  }
    public override var description: String {
        return "referralCode: \(String(describing: self.referralCode))," + "referralOwnerId: \(String(describing: self.referralOwnerId))," + "status: \(String(describing: self.status)),"
    }
}


