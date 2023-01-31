//
//  RequestProductSuccessViewModel.swift
//  Quickride
//
//  Created by Halesh on 20/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RequestProductSuccessViewModel{
    
    var requestProduct: RequestProduct?
    var postedRequest: PostedRequest?
    var covidHome = false
    var matchingProducts = [AvailableProduct]()
    
    init(requestProduct: RequestProduct,postedRequest: PostedRequest,covidHome : Bool) {
        self.requestProduct = requestProduct
        self.postedRequest = postedRequest
        self.covidHome = covidHome
    }
    
    init() {}
    
    func getMatchingProductList(){
        QuickShareRestClient.getMatchingProductList(query: postedRequest?.title ?? "", ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: postedRequest?.categoryCode ?? "", latitude: postedRequest?.latitude ?? 0, longitude: postedRequest?.longitude ?? 0, offSet: 0, maxDistance: QuickShareHomePageViewModel.QUICK_SHARE_RADIUS, tradeType: postedRequest?.tradeType ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let availabelItems = Mapper<AvailableItems>().map(JSONObject: responseObject!["resultData"])
                self.matchingProducts.removeAll()
                self.matchingProducts.append(contentsOf: availabelItems?.matchedProductListings ?? [AvailableProduct]())
                NotificationCenter.default.post(name: .matchingProductsReceived, object: nil)
            }
        }
    }
}
