//
//  PreferredRidePartners.swift
//  Quickride
//
//  Created by rakesh on 2/1/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PreferredRidePartner : NSObject, Mappable{

    static let USER_ID = "userId"
    static let FAVOURITE_PARTNER_USER_ID = "favouritePartnerUserId"
    static let FAVOURITE_PARTNER_IDS = "favouriteUserIds"
    
    var id : Double?
    var userId : Double?
    var favouritePartnerUserId : Double?
    var imageUri : String?
    var gender : String?
    var name : String?
    var enableAutoConfirm: Bool?
    
    required init?(map:Map){
    }
    
    override init(){
        
    }
    
    init(id : Double, userId : Double, favouritePartnerUserId : Double) {
        self.id = id
        self.userId = userId
        self.favouritePartnerUserId = favouritePartnerUserId
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        favouritePartnerUserId <- map["favouritePartnerUserId"]
        imageUri <- map["imageUri"]
        gender <- map["gender"]
        name <- map["name"]
        enableAutoConfirm <- map["enableAutoConfirm"]
    }
    
    func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String : String] = [String : String]()
        params["id"] = StringUtils.getStringFromDouble(decimalNumber: self.id)
        params["userId"] = StringUtils.getStringFromDouble(decimalNumber: self.userId)
        params["favouritePartnerUserId"] = StringUtils.getStringFromDouble(decimalNumber: self.favouritePartnerUserId)
        if imageUri != nil{
            params["imageUri"] = self.imageUri!
        }
        if gender != nil{
             params["gender"] = self.gender!
        }
        if name != nil{
            params["name"] = self.name!
        }
        
        return params
    }
    public override var description: String {
        return "id: \(String(describing: self.id))," + "userId: \(String(describing: self.userId))," + " favouritePartnerUserId: \(String(describing: self.favouritePartnerUserId))," + " imageUri: \(String(describing: self.imageUri))," + " gender: \(String(describing: self.gender))," + " name: \(String(describing: self.name))," + " enableAutoConfirm: \(String(describing: self.enableAutoConfirm)),"
    }
}
