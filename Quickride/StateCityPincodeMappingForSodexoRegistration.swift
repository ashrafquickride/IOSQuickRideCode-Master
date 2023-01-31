//
//  StateCityPincodeMappingForSodexoRegistration.swift
//  Quickride
//
//  Created by Halesh on 22/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class StateCityPincodeMappingForSodexoRegistration: NSObject,Mappable {
    
    var id : Double?
    var state : String?
    var city : String?
    var pinCode : Int?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        state <- map["state"]
        city <- map["city"]
        pinCode <- map["pinCode"]
    }
    func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String : String] = [String : String]()
        params["id"] = StringUtils.getStringFromDouble(decimalNumber: id)
        params["state"] = self.state
        params["city"] =  self.city
        params["pinCode"] =  String(self.pinCode!)
        return params
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "state: \(String(describing: self.state))," + "city: \(String(describing: self.city))," + "pinCode: \(String(describing: self.pinCode)),"
    }
}
