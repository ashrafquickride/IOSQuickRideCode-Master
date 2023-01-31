//
//  RequirementRequestDetailsViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 23/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RequirementRequestDetailsViewModel{
    
    var availableRequest = AvailableRequest()
    var requetComments = [ProductComment]()
    var matchingPostedProducts = [PostedProduct]()
    
    init(availableRequest: AvailableRequest) {
        self.availableRequest = availableRequest
    }
    
    init() {}
    
    func getRequestComments(){
        QuickShareRestClient.getProductComments(listingId: availableRequest.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.requetComments = Mapper<ProductComment>().mapArray(JSONObject: responseObject!["resultData"]) ?? [ProductComment]()
                NotificationCenter.default.post(name: .productCommentsReceived, object: self)
            }
        }
    }
    
    func getProductOwnerContactFromSerever(userId : String,handler: @escaping contactNoReceiverhandler){
        UserRestClient.getUserContactNo(userId: userId, uiViewController: nil) { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let contactNo = responseObject!["resultData"] as? String
                handler(contactNo ?? "")
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    func offerYourPostedProductToRequestedUser(){
        QuickShareSpinner.start()
        QuickShareRestClient.notifyProductToRequestedUser(sellerId: UserDataCache.getInstance()?.userId ?? "", borrowerId: availableRequest.userId, id: availableRequest.id ?? "", listingId: availableRequest.listingId ?? ""){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UIApplication.shared.keyWindow?.makeToast("Notified to requestd user successfully")
            }
        }
    }
    func getMyMatchingPostedProduct(){
        QuickShareSpinner.start()
        QuickShareRestClient.getMyMatchingProductsForRequest(ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: availableRequest.categoryCode, tradeType: availableRequest.tradeType ?? ""){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.matchingPostedProducts = Mapper<PostedProduct>().mapArray(JSONObject: responseObject!["resultData"]) ?? [PostedProduct]()
            }
            NotificationCenter.default.post(name: .matchingProductsReceived, object: nil)
        }
    }
}
