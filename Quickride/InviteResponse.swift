//
//  InviteResponse.swift
//  Quickride
//
//  Created by KNM Rao on 02/07/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class InviteResponse: Mappable{
  var rideInvites = [RideInvitation]()
  var errors  = [ResponseError]()
  
  required init?(map: Map) {
    
  }
  
  
  func mapping(map: Map) {
    self.rideInvites <- map["rideInvites"]
    self.errors <- map["errors"]
  }
}
