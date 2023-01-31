//
//  PostedProductDetailsViewModel.swift
//  Quickride
//
//  Created by Halesh on 17/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import SDWebImage

class PostedProductDetailsViewModel{
    
    //MARK: Variables
    var postedProduct = PostedProduct()
    var productComments = [ProductComment]()
    var parentId: String?
    var noOfViews = 0
    var matchingRequests = [AvailableRequest]()
    
    init(postedProduct: PostedProduct) {
        self.postedProduct = postedProduct
    }
    init() {}
    
    func getProductComments(){
        QuickShareRestClient.getProductComments(listingId: postedProduct.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.productComments = Mapper<ProductComment>().mapArray(JSONObject: responseObject!["resultData"]) ?? [ProductComment]()
                NotificationCenter.default.post(name: .productCommentsReceived, object: self)
            }
        }
    }
    func addAnswerForComment(comment: String){
        QuickShareRestClient.addCommentToProduct(listingId: postedProduct.id ?? "", commentId: nil, userId: UserDataCache.getInstance()?.userId ?? "", comment: comment, parentId: parentId ?? "",type: AvailableProduct.LISTING){ (responseObject, error) in
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
    func getNumberOfViewsOfProduct(){
        QuickShareRestClient.getNumberOfViewsOfProduct(entityId: postedProduct.id ?? "", entityType: AvailableProduct.LISTING, userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.noOfViews =  responseObject!["resultData"] as? Int ?? 0
                NotificationCenter.default.post(name: .numberOfViewsRecieved, object: self)
            }
        }
    }
    
    func prepareImageList(){
        guard let imageList = postedProduct.imageList?.components(separatedBy: ",") else { return }
        var productImages = [UIImage]()
        for imageUrl in imageList{
            let imageView = UIImageView()
            guard  let url = URL(string: imageUrl) else { return }
            imageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0)) { (image, error, cacheType, url) in
                productImages.append(image ?? UIImage())
            }
        }
    }
    
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

