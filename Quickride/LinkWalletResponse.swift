//
//  LinkWalletResponse.swift
//  Quickride
//
//  Created by rakesh on 10/2/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class LinkWalletResponse : NSObject,Mappable{
    
    var status : String?
    var responseCode : String?
    var state : String?
    var message : String?
    var transactionID : String?
    
    required init?(map: Map) {
        
    }
    
   func mapping(map: Map) {
        self.status <- map["status"]
        self.responseCode <- map["responseCode"]
        self.state <- map["state"]
        self.message <- map["message"]
        self.transactionID <- map["transactionID"]
    }
    
    public override var description: String {
        return "status: \(String(describing: self.status))," + "responseCode: \(String(describing: self.responseCode))," + " state: \(String(describing: self.state))," + " message: \(String(describing: self.message))," + " transactionID: \(String(describing: self.transactionID)),"
    }
    
}
