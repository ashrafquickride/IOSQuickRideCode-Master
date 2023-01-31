//
//  RideInviteResponse.swift
//  Quickride
//
//  Created by Vinutha on 6/29/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideInviteResponse:NSObject, Mappable {
    var invitedUserId : Double?
    var success : Bool = false
    var rideInvite : RideInvitation?
    var error : ResponseError?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.invitedUserId <- map["invitedUserId"]
        self.success <- map["success"]
        self.rideInvite <- map["rideInvite"]
        self.error <- map["error"]
    }
    public override var description: String {
        return "invitedUserId: \(String(describing: self.invitedUserId))," + "success: \(String(describing: self.success))," + " rideInvite: \( String(describing: self.rideInvite))," + " error: \( String(describing: self.error)),"
    }
}
