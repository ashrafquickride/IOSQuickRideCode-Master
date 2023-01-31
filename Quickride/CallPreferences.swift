//
//  CallPreferences.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/06/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class CallPreferences: NSObject, Mappable, NSCopying{
    
    var userId : Double = 0.0
    var enableCallPreferences = false
    
    static let USER_ID = "userId"
    static let ENABLE_CALL_PREFERENCES = "ivrEnabled"

    
    func mapping(map: Map) {
        self.userId <- map["userId"]
        self.enableCallPreferences <- map["ivrEnabled"]
    }
    required init?(map: Map){
        
    }
    override init() {
        
    }
    init(userId : Double,enableCallPreferences : Bool) {
        self.userId = userId
        self.enableCallPreferences = enableCallPreferences
    }
    
    func  getParamsMap() -> [String : String] {
        var params : [String : String] = [String : String]()
        params["userId"] =  StringUtils.getStringFromDouble(decimalNumber: userId)
        params["ivrEnabled"] = String(enableCallPreferences)
        return params
    }
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let callPreferences = CallPreferences()
        callPreferences.userId = self.userId
        callPreferences.enableCallPreferences = self.enableCallPreferences
        return callPreferences
    }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "enableCallPreferences: \(String(describing: self.enableCallPreferences)),"
    }
}
