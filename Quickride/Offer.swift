//
//  Offer.swift
//  Quickride
//
//  Created by KNM Rao on 01/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct Offer: Mappable {
    
    var offerImageUri :String?
    var offerMessage : String?
    var offerTitle :String?
    var offerSubTitle: String?
    var linkTitle :String?
    var linkUrl :String?
    var validUpto : Double = 0
    var navigateTo : String?
    var id : Double = 0
    var noOfTimesToDisplay : Int = 0
    var appToDisplay : String?
    var offerType : String?
    var termsAndCondtions : String?
    var offerScreenImageUri : String?
    var displayType : String?
    var targetDevice: String?
    var targetRole: String?
    var targetRegion: String?
    var inAppOffersImageUri: String?
    var inAppOffersSmallImageUri: String?
    var maxImpressions: Double?
    var remainingImpressions: Double?
    var priority = 0
    var category: String?
    var deepLinkUrl: String?
    var isImpressionSaved = false
    
    static let FLD_OFFER_TYPE = "offerType"
    static let OFFER_TYPE_RECHARGE = "RECHARGE"
    static let FLD_ID = "id"
    static let OFFER_STATUS_OFFERID = "offerId";
    static let OFFER_DISPLAY_TYPE_REFER_AND_EARN = "ReferAndEarn"
   
    init?(map: Map) {
        
    }
    
    mutating func mapping(map: Map) {
        self.offerImageUri <- map["offerImageUri"]
        self.offerMessage <- map["offerMessage"]
        self.offerTitle <- map["offerTitle"]
        self.offerSubTitle <- map["offerSubTitle"]
        self.linkTitle <- map["linkTitle"]
        self.linkUrl <- map["linkUrl"]
        self.validUpto <- map["validUpto"]
        self.navigateTo <- map["navigateTo"]
        self.id <- map["id"]
        self.noOfTimesToDisplay <- map["noOfTimesToDisplay"]
        self.appToDisplay <- map["appToDisplay"]
        self.offerType <- map["offerType"]
        self.termsAndCondtions <- map["termsAndCondtions"]
        self.offerScreenImageUri <- map["offerScreenImageUri"]
        self.displayType <- map["displayType"]
        self.targetDevice <- map["targetDevice"]
        self.targetRole <- map["targetRole"]
        self.targetRegion <- map["targetRegion"]
        self.inAppOffersImageUri <- map["inAppOffersImageUri"]
        self.inAppOffersSmallImageUri <- map["inAppOffersSmallImageUri"]
        self.maxImpressions <- map["maxImpressions"]
        self.remainingImpressions <- map["remainingImpressions"]
        self.priority <- map["priority"]
        self.category <- map["category"]
        self.deepLinkUrl <- map["deepLinkUrl"]
        
    }
    
    public var description: String {
        return "offerImageUri: \(String(describing: self.offerImageUri))," + "offerMessage: \(String(describing: self.offerMessage))," + " offerTitle: \( String(describing: self.offerTitle))," +  " offerSubTitle: \( String(describing: self.offerSubTitle))," + " linkTitle: \(String(describing: self.linkTitle))," + " linkUrl: \(String(describing: self.linkUrl)),"
            + " validUpto: \(self.validUpto)," + "navigateTo: \(String(describing: self.navigateTo))," + "id:\(self.id)," + "noOfTimesToDisplay:\(self.noOfTimesToDisplay)," + "appToDisplay:\(String(describing: self.appToDisplay))," + "appToDisplay:\(String(describing: self.appToDisplay))," + "offerType: \(String(describing: self.offerType))," + "termsAndCondtions: \( String(describing: self.termsAndCondtions))," + "offerScreenImageUri: \(String(describing: self.offerScreenImageUri))," + "displayType: \( String(describing: self.displayType))," + "targetDevice: \(String(describing: self.targetDevice))," + "targetRole: \(String(describing: self.targetRole)))," + "targetRegion: \(String(describing: self.targetRegion))," + "inAppOffersImageUri: \(String(describing: self.inAppOffersImageUri))," + "inAppOffersSmallImageUri: \(String(describing: self.inAppOffersSmallImageUri))," + "maxImpressions: \(String(describing: self.maxImpressions))," + "remainingImpressions: \(String(describing: self.remainingImpressions))," + "priority: \(String(describing: self.priority))," + "category: \(String(describing: self.category))," + "deepLinkUrl: \(String(describing: self.deepLinkUrl)),"
    }
}
