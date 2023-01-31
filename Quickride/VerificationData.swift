//
//  VerificationData.swift
//  Quickride
//
//  Created by Anki on 14/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class VerificationData:NSObject,Mappable{
  
  static var VERIFICATION_DATA_FIELD_VERIFYCODE:String = "verifycode";
  var subject:String?
  var verifycode:String?
  
  required init(map:Map){
    
  }
  
  func mapping(map:Map){
    subject <- map["subject"]
    verifycode <- map["verifycode"]
  }
    public override var description: String {
        return "subject: \(String(describing: self.subject))," + "verifycode: \(String(describing: self.verifycode)),"
    }
  
}
