//
//  AddProductSuccessViewModel.swift
//  Quickride
//
//  Created by Halesh on 15/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AddProductSuccessViewModel{
    
    //MARK: Variables
    var postedProduct = PostedProduct ()
    var product = Product()
    var matchingRequests = [AvailableRequest]()
    var covidCareHome = false
    init(postedProduct: PostedProduct,product: Product,covidCareHome : Bool) {
        self.postedProduct = postedProduct
        self.product = product
        self.covidCareHome = covidCareHome
    }
    
    init(){}
    
    func getMatchingRequestList(){
        if !postedProduct.locations.isEmpty{
            QuickShareRestClient.getMatchingRequestList(query: postedProduct.title ?? "", ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: postedProduct.categoryCode, latitude: postedProduct.locations[0].lat, longitude: postedProduct.locations[0].lng, offSet: 0, maxDistance: QuickShareHomePageViewModel.QUICK_SHARE_RADIUS, tradeType: postedProduct.tradeType ?? ""){ (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    let matchingRequests = Mapper<AvailableRequest>().mapArray(JSONObject: responseObject!["resultData"]) ?? [AvailableRequest]()
                    self.updateRequestAreFromMatchingList(matchingRequests: matchingRequests)
                }
            }
        }
    }
    
    private func updateRequestAreFromMatchingList(matchingRequests: [AvailableRequest]){
        var availableRequests = [AvailableRequest]()
        for matchingRequest in matchingRequests{
            var availableRequest = matchingRequest
            availableRequest.listingId = postedProduct.id
            availableRequests.append(availableRequest)
        }
        self.matchingRequests = availableRequests
        NotificationCenter.default.post(name: .matchingRequestsReceived, object: nil)
    }
}
