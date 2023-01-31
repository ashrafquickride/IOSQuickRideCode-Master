//
//  MyPostsViewModel.swift
//  Quickride
//
//  Created by HK on 08/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MyPostsViewModel{
    
    var postedProductList = [PostedProduct]()
    var postedRequstList = [PostedRequest]()
    
    func getPostedProductsList(){
        QuickShareRestClient.getPostedProductsList(ownerId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let myPostedProducts = Mapper<MyPostedProduct>().mapArray(JSONObject: responseObject!["resultData"]) ?? [MyPostedProduct]()
                var products = [PostedProduct]()
                for postedProduct in myPostedProducts{
                    products.append(postedProduct.postedProduct ?? PostedProduct())
                }
                self.postedProductList = products
            }
            NotificationCenter.default.post(name: .myPostReceived, object: self)
        }
    }
    
    func getMyPostedRequestList(){
        QuickShareRestClient.getMyPlacedOrders(borrowerId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let requestedOrdesAndRequirement = Mapper<Order>().mapArray(JSONObject: responseObject!["resultData"]) ?? [Order]()
                self.postedRequstList.removeAll()
                for requestOrOrders in requestedOrdesAndRequirement{
                    if requestOrOrders.postedRequest?.listingId == nil{
                        self.postedRequstList.append(requestOrOrders.postedRequest ?? PostedRequest())
                    }
                }
            }
            NotificationCenter.default.post(name: .myPostReceived, object: self)
        }
    }
    
}
