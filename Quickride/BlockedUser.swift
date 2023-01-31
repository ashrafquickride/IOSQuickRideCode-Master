//
//  BlockedUser.swift
//  Quickride
//
//  Created by QuickRideMac on 1/6/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class BlockedUser : NSObject, Mappable{
    
    static let USER_ID = "userId"
    static let BLOCKED_USER_ID = "blockedUserId"
    static let BLOCKED_REASON = "reason"
    var id : Double?
    var userId : Double?
    var blockedUserId : Double?
    var imageUri : String?
    var gender : String?
    var name : String?
    
    required init?(map:Map){
    }
    init(id : Double, userId : Double, blockedUserId : Double) {
        self.id = id
        self.userId = userId
        self.blockedUserId = blockedUserId
    }
    
    override init(){
        
    }

    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        blockedUserId <- map["blockedUserId"]
        imageUri <- map["imageUri"]
        gender <- map["gender"]
        name <- map["name"]
    }
    
    func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String : String] = [String : String]()
        params["id"] = StringUtils.getStringFromDouble(decimalNumber: self.id)
        params["userId"] = StringUtils.getStringFromDouble(decimalNumber: self.userId)
        params["blockedUserId"] = StringUtils.getStringFromDouble(decimalNumber: self.blockedUserId)
        params["imageUri"] = self.imageUri
        params["gender"] = self.gender
        params["name"] = self.name
        return params
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "userId: \(String(describing: self.userId))," + " blockedUserId: \(String(describing: self.blockedUserId))," + " imageUri: \(String(describing: self.imageUri))," + " gender: \(String(describing: self.gender)),"
            + " name: \(String(describing: self.name))"
    }
}
