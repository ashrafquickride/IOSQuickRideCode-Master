//
//  LinkedWallet.swift
//  Quickride
//
//  Created by rakesh on 10/2/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class LinkedWallet : NSObject,Mappable{
    
    var userId : Double?
    var type : String?
    var mobileNo : String?
    var email : String?
    var token : String?
    var key : String?
    var custId : String?
    var status : String?
    var defaultWallet = true
    var balance: Double?
    
    static var EXPIRED = "EXPIRED"
    
    override init(){
        
    }
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
       self.userId <- map["userId"]
       self.type <- map["type"]
       self.mobileNo <- map["mobileNo"]
       self.email <- map["email"]
       self.token <- map["token"]
       self.key <- map["key"]
       self.custId <- map["custId"]
       self.status <- map["status"]
       self.defaultWallet <- map["defaultWallet"]
    }
    
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "type: \(String(describing: self.type))," + " mobileNo: \(String(describing: self.mobileNo))," + " email: \(String(describing: self.email))," + " token: \(String(describing: self.token)),"
            + "key: \(String(describing: self.key))," + "custId: \(String(describing: self.custId)),"
    }
    
}
