//
//  ProbableUser.swift
//  Quickride
//
//  Created by Anki on 13/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ProbableUser:NSObject,Mappable{
  
  var probableuserid:Double?
  var phonenumber:Double?
  var email:String?
  
  required init(map:Map){
    
  }
  
  func mapping(map:Map){
    probableuserid <- map["id"]
    phonenumber <- map["phone"]
    email <- map["email"]
  }
    public override var description: String {
        return "probableuserid: \(String(describing: self.probableuserid))," + "phonenumber: \(String(describing: self.phonenumber))," + "email: \(String(describing: self.email)),"
    }
}
