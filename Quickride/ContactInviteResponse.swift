//
//  ContactInviteResponse.swift
//  Quickride
//
//  Created by KNM Rao on 09/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

 class ContactInviteResponse:NSObject, Mappable {
  var contactId : String?
  var success : Bool = false
  var rideInvite : RideInvitation?
  var error : ResponseError?
  required  init?(map: Map) {
    
  }
  
  
   func mapping(map: Map) {
    self.contactId <- map["contactId"]
    self.success <- map["success"]
    self.rideInvite <- map["rideInvite"]
    self.error <- map["error"]
  }
    public override var description: String {
        return "contactId: \(String(describing: self.contactId))," + "success: \(String(describing: self.success))," + "rideInvite: \( String(describing: self.rideInvite))," + "error: \(String(describing: self.error)),"
    }
}
