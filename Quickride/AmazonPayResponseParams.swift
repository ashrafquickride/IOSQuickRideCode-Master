//
//  AmazonPayResponseParams.swift
//  Quickride
//
//  Created by Admin on 26/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AmazonPayResponseParams : NSObject, Mappable{
    
    var amount = 0.0
    var currencyCode = ""
    var amazonTransactionId = ""
    var status = ""
    var payURL = ""
    var lookAheadToken = ""
    var timeStamp = ""
    var merchantTransactionId = ""
    
    required init?(map: Map) {
        
    }
    
     func mapping(map: Map) {
        amount <- map["amount"]
        currencyCode <- map["currencyCode"]
        amazonTransactionId <- map["amazonTransactionId"]
        status <- map["status"]
        payURL <- map["payURL"]
        lookAheadToken <- map["lookAheadToken"]
        timeStamp <- map["timeStamp"]
        merchantTransactionId <- map["merchantTransactionId"]
    }
    public override var description: String {
        return "amount: \(String(describing: self.amount))," + "currencyCode: \(String(describing: self.currencyCode))," + " amazonTransactionId: \( String(describing: self.amazonTransactionId))," + " status: \(String(describing: self.status))," + " payURL: \(String(describing: self.payURL)),"
            + " lookAheadToken: \(String(describing: self.lookAheadToken))," + "timeStamp: \(String(describing: self.merchantTransactionId)),"
    }
    
}
