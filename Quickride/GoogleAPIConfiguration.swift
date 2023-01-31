//
//  GoogleAPIConfiguration.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 04/05/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class GoogleAPIConfiguration : NSObject, Mappable {

    var googlePremiumKey : String?
    var googleDynamicLinksWebApiKey  = "AIzaSyDm_y1Z2UX2pfR51zJPgQabPzU6PqxvMoY"
    var googleDynamicLinksDomain = "ms79s.app.goo.gl"
    var readPlacesAPIDataFromGoogle = true
    var readETABeforeRideJoin = false


    override init() {

    }
    required init?(map: Map) {

    }

    func mapping(map: Map) {
        self.googlePremiumKey <- map["googlePremiumKey"]
        self.googleDynamicLinksWebApiKey <- map["googleDynamicLinksWebApiKey"]
        self.googleDynamicLinksDomain <- map["googleDynamicLinksDomain"]
        self.readPlacesAPIDataFromGoogle <- map["readPlacesAPIDataFromGoogle"]
        self.readETABeforeRideJoin <- map["readETABeforeRideJoin"]
    }
    public override var description: String {
        return "googlePremiumKey: \(String(describing: self.googlePremiumKey))," + " readETABeforeRideJoin: \( String(describing: self.readETABeforeRideJoin))"
    }
}
