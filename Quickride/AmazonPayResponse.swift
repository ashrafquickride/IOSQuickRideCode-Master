//
//  AmazonPayResponse.swift
//  Quickride
//
//  Created by Admin on 26/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AmazonPayResponse : NSObject,Mappable{
  
    var signature : String = ""
    var requestId : String = ""
    var response : AmazonPayResponseParams?
    
    static let auth_status_granted = "DONE"
    
    required init?(map: Map) {

    }
    
    func mapping(map: Map) {
        signature <- map["signature"]
        requestId <- map["requestId"]
        response <- map["response"]
    }
    public override var description: String {
        return "signature: \(String(describing: self.signature))," + "requestId: \(String(describing: self.requestId))," + " response: \( String(describing: self.response)),"
    }
}
