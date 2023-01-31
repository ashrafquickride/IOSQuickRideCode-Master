//
//  FreeChargeRequest.swift
//  Quickride
//
//  Created by rakesh on 7/4/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class FreeChargeRequest : NSObject,Mappable{
    
    var amount : String?
    var channel : String?
    var furl : String?
    var merchantId : String?
    var merchantTxnId : String?
    var metadata : String?
    var mobile : String?
    var productInfo : String?
    var surl : String?
    
    
    required init?(map: Map) {
        
    }
    
    init(amount : String,channel : String,furl : String,merchantId : String,merchantTxnId : String,metadata : String,mobile : String,productInfo : String,surl : String){
        self.amount = amount
        self.channel = channel
        self.furl = furl
        self.merchantId = merchantId
        self.merchantTxnId = merchantTxnId
        self.metadata = metadata
        self.mobile = mobile
        self.productInfo = productInfo
        self.surl = surl
    }
    
    func mapping(map: Map) {
        amount <- map["amount"]
        channel <- map["channel"]
        furl <- map["furl"]
        merchantId <- map["merchantId"]
        merchantTxnId <- map["merchantTxnId"]
        metadata <- map["metadata"]
        mobile <- map["mobile"]
        productInfo <- map["productInfo"]
        surl <- map["surl"]
    }
    
    func getParams(checksum : String?) -> [String : String]{
        var params = [String : String]()
        params["amount"] = amount
        params["channel"] = channel
        params["furl"] = furl
        params["surl"] = surl
        params["merchantId"] = merchantId
        params["merchantTxnId"] = merchantTxnId
        params["metadata"] = metadata
        params["mobile"] = mobile
        params["productInfo"] = productInfo
        if checksum != nil{
          params["checksum"] = checksum
        }
        return params
    }

    public override var description: String { 
        return "amount: \(String(describing: self.amount))," + "channel: \(String(describing: self.channel))," + " merchantId: \(String(describing: self.merchantId))," + " merchantTxnId: \(String(describing: self.merchantTxnId))," + " metadata: \(String(describing: self.metadata)),"
            + "mobile: \(String(describing: self.mobile))," + "productInfo: \(String(describing: self.productInfo))," + "surl: \(String(describing: self.surl)),"
    }
}
