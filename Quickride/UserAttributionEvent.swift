//
//  UserInstallEvent.swift
//  Quickride
//
//  Created by Admin on 03/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct UserAttributionEvent : Mappable {
   
    var id: Double?
    var userId: Double?
    var uniqueDeviceId: String?
    var googleAdvertisingId: String?
    var source: String?
    var medium: String?
    var term: String?
    var content: String?
    var campaign: String?
    var installTime: String?
    var clickTime: String?
    var appsFlyerId: String?
    var publisherId: String?
    var subPublisherId: String?
    var adInfo: String?
    
    static let USER_ATTRIBUTION_TYPE_INSTALL = "install"
    static let USER_ATTRIBUTION_TYPE_APP_OPEN = "AppOpen"
    
    init?(map: Map) {
    }
    
    init(userId: Double?,uniqueDeviceId: String?,googleAdvertisingId: String?,source: String?, medium: String?,term: String?,content:String?,campaign:String?,installTime: String?,clickTime: String?,appsFlyerId: String?,publisherId: String?,subPublisherId: String?,adInfo: String?){
        self.userId = userId
        self.uniqueDeviceId = uniqueDeviceId
        self.googleAdvertisingId = googleAdvertisingId
        self.source = source
        self.medium = medium
        self.term = term
        self.content = content
        self.campaign = campaign
        self.installTime = installTime
        self.clickTime = clickTime
        self.appsFlyerId = appsFlyerId
        self.publisherId = publisherId
        self.subPublisherId = subPublisherId
        self.adInfo = adInfo
    }
       
    mutating func mapping(map: Map) {
        id <- map["id"]
        userId <- map["userId"]
        uniqueDeviceId <- map["uniqueDeviceId"]
        googleAdvertisingId <- map["googleAdvertisingId"]
        source <- map["source"]
        medium <- map["medium"]
        term <- map["term"]
        content <- map["content"]
        campaign <- map["campaign"]
        installTime <- map["installTime"]
        clickTime <- map["clickTime"]
        appsFlyerId <- map["appsFlyerId"]
        publisherId <- map["publisherId"]
        subPublisherId <- map["subPublisherId"]
        adInfo <- map["adInfo"]
    }
    
    func  getParams() -> [String : String?] {
        var params = [String : String?]()
        params["id"] = StringUtils.getStringFromDouble(decimalNumber: id)
        params["userId"] = StringUtils.getStringFromDouble(decimalNumber: userId)
        params["uniqueDeviceId"] = uniqueDeviceId
        params["googleAdvertisingId"] = googleAdvertisingId
        params["source"] =  source
        params["medium"] = medium
        params["term"] = term
        params["content"] =  content
        params["campaign"] = campaign
        params["installTime"] = installTime
        params["clickTime"] =  clickTime
        params["appsFlyerId"] = appsFlyerId
        params["publisherId"] = publisherId
        params["subPublisherId"] =  subPublisherId
        params["adInfo"] = adInfo
        return params
    }
    
}

