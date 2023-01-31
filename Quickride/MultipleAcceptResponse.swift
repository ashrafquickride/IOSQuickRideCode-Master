//
//  MultipleAcceptResponse.swift
//  Quickride
//
//  Created by rakesh on 9/5/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MultipleAcceptResponse : NSObject, Mappable{
    
    var inviteId : Double?
    var success : Bool = false
    var error : ResponseError?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        self.inviteId <- map["inviteId"]
        self.success <- map["success"]
        self.error <- map["error"]
    }
    public override var description: String {
        return "inviteId: \(String(describing: self.inviteId))," + "success: \(String(describing: self.success))," + " error: \( String(describing: self.error)),"
    }
    
}
