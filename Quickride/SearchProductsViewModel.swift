//
//  SearchProductsViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 23/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class SearchProductsViewModel {
    
    //MARK: Outletsf
    private var location: Location?
    var tradeType = Product.BOTH
    var searchList = [String]()
    var selectedType: String?
    var searchQueryMatchedProducts = [AvailableProduct]()
    var searchType = PRODUCTS
    var searchQueryMatchedRequest = [AvailableRequest]()
    
    static let PRODUCTS = "PRODUCTS"
    static let REQUESTS = "REQUESTS"
    
    init(tradeType: String) {
        self.tradeType = tradeType
        self.location = QuickShareCache.getInstance()?.getUserLocation()
    }
    init() {}
    
    func getProductsBasedOnEnteredCharacters(query: String){
        if searchType == SearchProductsViewModel.PRODUCTS{
            QuickShareRestClient.getProductListBasedOnEnterdCharacters(query: query,ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: nil, latitude: location?.latitude ?? 0, longitude: location?.longitude ?? 0, offSet: 0, maxDistance: QuickShareHomePageViewModel.QUICK_SHARE_RADIUS, tradeType: returnTradeType()){ (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    self.searchList = responseObject!["resultData"] as? [String] ?? [String]()
                    NotificationCenter.default.post(name: .receivedSearchedProductTitleList, object: nil)
                } else {
                    var userInfo = [String : Any]()
                    userInfo["responseObject"] = responseObject
                    userInfo["error"] = error
                    NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
                }
            }
        }else{
            QuickShareRestClient.getRequestsBasedOnEnterdCharacters(query: query,ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: nil, latitude: location?.latitude ?? 0, longitude: location?.longitude ?? 0, maxDistance: QuickShareHomePageViewModel.QUICK_SHARE_RADIUS, tradeType: returnTradeType()){ (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    self.searchList = responseObject!["resultData"] as? [String] ?? [String]()
                    NotificationCenter.default.post(name: .receivedSearchedProductTitleList, object: nil)
                } else {
                    var userInfo = [String : Any]()
                    userInfo["responseObject"] = responseObject
                    userInfo["error"] = error
                    NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
                }
            }
        }
    }
    
    func getProductsForPerticularTitle(query: String){
        selectedType = query
        if searchType == SearchProductsViewModel.PRODUCTS{
            QuickShareRestClient.getPerticularProductForSearchedTitle(query: query,ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: nil, latitude: location?.latitude ?? 0, longitude: location?.longitude ?? 0, offSet: 0, maxDistance: QuickShareHomePageViewModel.QUICK_SHARE_RADIUS, tradeType: returnTradeType()){ (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    let availabelItems = Mapper<AvailableItems>().map(JSONObject: responseObject!["resultData"])
                    self.searchQueryMatchedProducts.removeAll()
                    self.searchQueryMatchedProducts.append(contentsOf: availabelItems?.matchedProductListings ?? [AvailableProduct]())
                    NotificationCenter.default.post(name: .receivedSearchedProductMatchedList, object: nil)
                } else {
                    var userInfo = [String : Any]()
                    userInfo["responseObject"] = responseObject
                    userInfo["error"] = error
                    NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
                }
            }
        }else{
            QuickShareRestClient.getMatchingRequestList(query: query,ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: nil, latitude: location?.latitude ?? 0, longitude: location?.longitude ?? 0, offSet: 0, maxDistance: QuickShareHomePageViewModel.QUICK_SHARE_RADIUS, tradeType: returnTradeType()){ (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    self.searchQueryMatchedRequest = Mapper<AvailableRequest>().mapArray(JSONObject: responseObject!["resultData"]) ?? [AvailableRequest]()
                    NotificationCenter.default.post(name: .receivedSearchedRequestMatchedList, object: nil)
                } else {
                    var userInfo = [String : Any]()
                    userInfo["responseObject"] = responseObject
                    userInfo["error"] = error
                    NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
                }
            }
        }
    }
    private func returnTradeType() -> String{
        if tradeType == "Buy"{
            return Product.SELL
        }else if tradeType == "Rent"{
            return Product.RENT
        }else{
            return Product.BOTH
        }
    }
}
