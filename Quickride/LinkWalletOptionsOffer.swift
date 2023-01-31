//
//  LinkWalletOptionsOffer.swift
//  Quickride
//
//  Created by Halesh on 23/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class LinkWalletOptionsOffer: NSObject, Mappable{
    var offerText : String?
    var walletType : String?
    
    required init?(map: Map) {
        
    }
    
    func mapping(map: Map) {
        offerText <- map["offerText"]
        walletType <- map["walletType"]
    }
    func getParams() -> [String : String] {
        AppDelegate.getAppDelegate().log.debug("getParams()")
        var params : [String : String] = [String : String]()
        params["offerText"] = offerText
        params["walletType"] = walletType
        return params
    }
    
    public override var description: String {
        return "offerText: \(String(describing: self.offerText))," + "walletType: \(String(describing: self.walletType)),"
    }
}
