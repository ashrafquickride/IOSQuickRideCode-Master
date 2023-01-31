//
//  TaxiPayByOtherModesInfo.swift
//  Quickride
//
//  Created by Rajesab on 30/05/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

struct TaxiPayByOtherModesInfo: Mappable {
    var amount: Double?
    var id: String?
    var paymentLink: String?
    var redirectionUrl: String?
    var redirectionFailureUrl: String?
    var defaultPaymentLinkType: String?
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        self.amount <- map["amount"]
        self.id <- map["id"]
        self.paymentLink <- map["paymentLink"]
        self.redirectionUrl <- map["redirectionUrl"]
        self.redirectionFailureUrl <- map["redirectionFailureUrl"]
        self.defaultPaymentLinkType <- map["defaultPaymentLinkType"]
    }
    
    var description: String{
        return "amount: \(String(describing: self.amount))"
        + "id: \(String(describing: self.id))"
        + "paymentLink: \(String(describing: self.paymentLink))"
        + "redirectionUrl: \(String(describing: self.redirectionUrl))"
        + "redirectionFailureUrl: \(String(describing: self.redirectionFailureUrl))"
        + "defaultPaymentLinkType: \(String(describing: self.defaultPaymentLinkType))"
    }
}
