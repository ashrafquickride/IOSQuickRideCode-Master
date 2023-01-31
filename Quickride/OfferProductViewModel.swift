//
//  OfferProductViewModel.swift
//  Quickride
//
//  Created by HK on 05/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class OfferProductViewModel {
    
    var myPostedProducts = [PostedProduct]()
    var categoryType = CategoryType()
    var requestId: String?
    var requetedUserId = 0
    var selectedIndex = -1
    
    init(requetedUserId: Int,requestId: String,categoryType: CategoryType,myPostedProducts: [PostedProduct]) {
        self.myPostedProducts = myPostedProducts
        self.categoryType = categoryType
        self.requestId = requestId
        self.requetedUserId = requetedUserId
    }
    
    init() {}
    
    func offerYourPostedProductToRequestedUser(){
        QuickShareSpinner.start()
        QuickShareRestClient.notifyProductToRequestedUser(sellerId: UserDataCache.getInstance()?.userId ?? "", borrowerId: requetedUserId, id: requestId ?? "", listingId: myPostedProducts[selectedIndex].id ?? ""){ (responseObject, error) in
            QuickShareSpinner.stop()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                NotificationCenter.default.post(name: .notifiedToUserRequestedUser, object: nil)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
}
