//
//  ConversationMessageBC.swift
//  Quickride
//
//  Created by QuickRideMac on 02/07/16.
//  Copyright © 2016 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper

class ConversationMessageBC: QuickRideMessageEntity {
    var sourceId : Double?
    var message : String?
    var sourceName : String?
    var imageURI : String?
    var gender : String?
    var chatTime : Double?
    
    override init(){
        super.init()
    }
    required init?(_ map: Map) {
        super.init()
    }
    
    required public init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        self.sourceId <- map["sourceId"]
        self.message <- map["message"]
        self.sourceName <- map["sourceName"]
        self.imageURI <- map["imageURI"]
        self.gender <- map["gender"]
        self.chatTime <- map["chatTime"]
    }
    override func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("")
        var params = super.getParams()
        params["sourceId"] = StringUtils.getStringFromDouble(decimalNumber: self.sourceId)
        params["message"] = self.message
        params["gender"] =  self.gender
        params["sourceName"] = self.sourceName
        params["imageURI"] = self.imageURI
        params["chatTime"] = StringUtils.getStringFromDouble(decimalNumber: self.chatTime)
        return params
    }
}
