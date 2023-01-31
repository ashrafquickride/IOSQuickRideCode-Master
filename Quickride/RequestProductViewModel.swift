//
//  RequestProductViewModel.swift
//  Quickride
//
//  Created by Halesh on 19/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RequestProductViewModel {
    
    var productType: String?
    var requestProduct = RequestProduct()
    var postedRequest: PostedRequest?
    var categoryCode: String?
    var isFromCovid = false
    
    init(productType: String,categoryCode: String,requestProduct: RequestProduct?,isFromCovid: Bool) {
        self.productType = productType
        self.categoryCode = categoryCode
        self.requestProduct = requestProduct ?? RequestProduct()
        self.isFromCovid = isFromCovid
    }
    init() {}
    
    func requestPreparedProduct(){
        QuickShareRestClient.requestProduct(requestProduct: requestProduct){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let order = Mapper<Order>().map(JSONObject: responseObject!["resultData"])
                self.postedRequest = order?.postedRequest
                NotificationCenter.default.post(name: .productRequestedSuccessfully, object: nil)
            } else {
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func checkRequiredFieldsfilledOrNot() -> Bool{
        if requestProduct.title?.isEmpty == false && requestProduct.description?.isEmpty == false && requestProduct.tradeType?.isEmpty == false && requestProduct.requestLocationInfo != nil{
            return true
        } else {
            return false
        }
    }
}
