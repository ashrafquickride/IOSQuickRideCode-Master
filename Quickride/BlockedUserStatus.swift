//
//  BlockedUserStatus.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 07/10/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


class BlockedUserStatus : NSObject, Mappable{
    
    var userId : Double?
    var blockedUserId : Double?
    var blocked : Bool?
    var contact : Contact?
    
    required init?(map:Map){
    }
  
    func mapping(map: Map) {
        userId <- map["userId"]
        blockedUserId <- map["blockedUserId"]
        blocked <- map["blocked"]
        contact <- map["contact"]
    }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "blockedUserId: \(String(describing: self.blockedUserId))," + " blocked: \(String(describing: self.blocked))," + " contact: \(String(describing: self.contact)),"
    }

    
}
