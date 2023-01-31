//
//  WhatsAppPreferences.swift
//  Quickride
//
//  Created by Halesh on 03/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class WhatsAppPreferences: NSObject, Mappable, NSCopying{
    
    var userId : Double = 0.0
    var enableWhatsAppPreferences = false
    
    static let USER_ID = "userId"
    static let ENABLE_WHATSAPP_PREFERENCES = "enableWhatsAppPreferences"

    
    func mapping(map: Map) {
        self.userId <- map["userId"]
        self.enableWhatsAppPreferences <- map["receiveWhatsAppMessages"]
    }
    required init?(map: Map){
        
    }
    override init() {
        
    }
    init(userId : Double,enableWhatsAppPreferences : Bool) {
        self.userId = userId
        self.enableWhatsAppPreferences = enableWhatsAppPreferences
    }
    
    func  getParamsMap() -> [String : String] {
        var params : [String : String] = [String : String]()
        params["userId"] =  StringUtils.getStringFromDouble(decimalNumber: userId)
        params["receiveWhatsAppMessages"] = String(enableWhatsAppPreferences)
        return params
    }
    public func copy(with zone: NSZone? = nil) -> Any
    {
        let whatsAppPreferences = WhatsAppPreferences()
        whatsAppPreferences.userId = self.userId
        whatsAppPreferences.enableWhatsAppPreferences = self.enableWhatsAppPreferences
        return whatsAppPreferences
    }
    public override var description: String {
        return "userId: \(String(describing: self.userId))," + "enableWhatsAppPreferences: \(String(describing: self.enableWhatsAppPreferences)),"
    }
}
