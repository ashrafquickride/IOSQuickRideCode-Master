//
//  UserRefererInfo.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 27/09/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class UserRefererInfo: NSObject,Mappable {
    
    var source : String?
    var medium : String?
    var term : String?
    var content : String?
    var campaign : String?
    var userId : String?
    var googleAdvertisingId : String?
    var deviceUniqueId : String?
    
    static let utm_id = "id"
    static let utm_user_id = "userId"
    static let utm_source = "utm_source"
    static let utm_medium = "utm_medium"
    static let utm_term = "utm_term"
    static let utm_content = "utm_content"
    static let utm_campaign = "utm_campaign"
    static let googleAdvertisingId = "googleAdvertisingId"
    static let deviceUniqueId = "deviceUniqueId"
    
    static let utm_campaign_shortsignup = "shortsignup"
    static let organic = "organic"

    
    required init?(map: Map) {
        
    }
    init(source : String?,medium : String?,term : String?,content : String?,campaign : String?,googleAdvertisingId : String?,deviceUniqueId : String?) {
        self.source = source
        self.medium = medium
        self.term = term
        self.content = content
        self.campaign = campaign
        self.googleAdvertisingId = googleAdvertisingId
        self.deviceUniqueId = deviceUniqueId
    }

    func mapping(map: Map) {
        self.source <- map["source"]
        self.medium <- map["medium"]
        self.term <- map["term"]
        self.content <- map["content"]
        self.campaign <- map["campaign"]
        self.userId <- map["userId"]
        self.googleAdvertisingId <- map["googleAdvertisingId"]
        self.deviceUniqueId <- map["deviceUniqueId"]
    }
    func isValid() -> Bool{
        if source == nil && medium == nil && term == nil && content == nil && campaign == nil{
            return false
        }
            return true
    }
    func getParams() -> [String: String]{
        var params = [String: String]()
        
        if source != nil{
            params[UserRefererInfo.utm_source] = source!
        }
        if medium != nil{
            params[UserRefererInfo.utm_medium] = medium!
        }
        if content != nil{
            params[UserRefererInfo.utm_content] = content
        }
        if term != nil{
            params[UserRefererInfo.utm_term] = term
        }
        if campaign != nil{
            params[UserRefererInfo.utm_campaign] = campaign
        }
        if googleAdvertisingId != nil{
            params[UserRefererInfo.googleAdvertisingId] = googleAdvertisingId
        }
        
        if userId != nil{
            params[UserRefererInfo.utm_user_id] = userId
        }
        
        if deviceUniqueId != nil{
          params[UserRefererInfo.deviceUniqueId] = deviceUniqueId
        }
        
        
        return params;
    }
    public override var description: String {
        return "source: \(String(describing: self.source))," + "medium: \(String(describing: self.medium))," + " term: \( String(describing: self.term))," + " content: \(String(describing: self.content))," + " campaign: \(String(describing: self.campaign)),"
            + " userId: \(String(describing: self.userId))," + "googleAdvertisingId: \(String(describing: self.googleAdvertisingId)),"
    }
    
}
