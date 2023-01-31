//
//  MyRequestDetailsViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 25/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MyRequestDetailsViewModel{
    
    var postedRequest = PostedRequest()
    var requetComments = [ProductComment]()
    var matchingProducts = [AvailableProduct]()
    var parentId: String?
    
    init(postedRequest: PostedRequest) {
        self.postedRequest = postedRequest
    }
    
    init() {}
    
    func getRequestComments(){
        QuickShareRestClient.getProductComments(listingId: postedRequest.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.requetComments = Mapper<ProductComment>().mapArray(JSONObject: responseObject!["resultData"]) ?? [ProductComment]()
                NotificationCenter.default.post(name: .productCommentsReceived, object: self)
            }
        }
    }
    func addAnswerForComment(comment: String){
        QuickShareRestClient.addCommentToProduct(listingId: postedRequest.id ?? "", commentId: nil, userId: UserDataCache.getInstance()?.userId ?? "", comment: comment, parentId: parentId ?? "", type: AvailableProduct.REQUEST){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                var productComment = Mapper<ProductComment>().map(JSONObject: responseObject!["resultData"])
                let userProfile = UserDataCache.getInstance()?.userProfile
                let userBasicInfo = UserBasicInfo(userId: userProfile?.userId ?? 0, gender: userProfile?.gender, userName: userProfile?.userName ?? "", imageUri: userProfile?.imageURI, callSupport: userProfile?.supportCall ?? "")
                productComment?.userBasicInfo = userBasicInfo
                var userInfo = [String : Any]()
                userInfo["productComment"] = productComment
                NotificationCenter.default.post(name: .newCommentAdded, object: nil, userInfo: userInfo)
            } else {
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    func getMatchingProductList(){
        if !postedRequest.pickUpLocations.isEmpty{
            QuickShareRestClient.getMatchingProductList(query: postedRequest.title ?? "", ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: postedRequest.categoryCode, latitude: postedRequest.pickUpLocations[0].lat, longitude: postedRequest.pickUpLocations[0].lng, offSet: 0, maxDistance: QuickShareHomePageViewModel.QUICK_SHARE_RADIUS, tradeType: postedRequest.tradeType ?? ""){ (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    let availabelItems = Mapper<AvailableItems>().map(JSONObject: responseObject!["resultData"])
                    self.matchingProducts.removeAll()
                    self.matchingProducts.append(contentsOf: availabelItems?.matchedProductListings ?? [AvailableProduct]())
                    NotificationCenter.default.post(name: .matchingProductsReceived, object: nil)
                }
            }
        }
    }
}
