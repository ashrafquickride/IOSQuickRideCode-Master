//
//  RideModeratorStatus.swift
//  Quickride
//
//  Created by Vinutha on 17/01/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideModeratorStatus: NSObject,Mappable{
    var userId : Double?
    var moderationEnabled : Bool?
    
    required init?(map: Map) { }
    
    func mapping(map: Map) {
        self.userId <- map["userId"]
        self.moderationEnabled <- map["moderationEnabled"]
    }
    
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "moderationEnabled: \(String(describing: self.moderationEnabled)),"
    }
}
