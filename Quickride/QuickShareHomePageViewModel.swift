//
//  QuickShareHomePageViewModel.swift
//  Quickride
//
//  Created by Halesh on 29/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class QuickShareHomePageViewModel{
    
    //MARK: Variables
    var currentCity = CurrentCity()
    var currentLocation: Location?
    var availableProducts = [AvailableProduct]()
    var availableRequests = [AvailableRequest]()
    var isQuickShareAvailabilityChecked = false
    var isQuickShareAvailable = false
    var offset = 0
    var covidCareHome = false
    var isDataFetchingFromServer = false
    
    static let ORDERS = "ORDERS"
    static let PLACED_ORDER = "PLACED_ORDER"
    
    static let QUICK_SHARE_RADIUS = 3000.0
        
    func checkQuickShareAvailabilityForCurrentLocation(){
        QuickShareRestClient.checkQuickShareAvailabilityForCurrentLoaction(latitude: currentLocation?.latitude ?? 0.0, longitude: currentLocation?.longitude ?? 0.0){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.currentCity = Mapper<CurrentCity>().map(JSONObject: responseObject!["resultData"]) ?? CurrentCity()
                self.isQuickShareAvailable = true
                self.getAvailableCategoryList()
                self.getAllRequiredData()
            } else {
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: self, userInfo: userInfo)
            }
            self.isQuickShareAvailabilityChecked = true
        }
    }
    
    func getAvailableCategoryList(){
        QuickShareRestClient.getAvailableCategoriesList(cityName: "pan india"){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let catgories = Mapper<CategoryType>().mapArray(JSONObject: responseObject!["resultData"]) ?? [CategoryType]()
                QuickSharePersistanceHelper.storeAvailableCategoryList(categories: catgories)
                QuickShareCache.getInstance()?.storeAvailableCategoryList(categories: catgories)
            }
            NotificationCenter.default.post(name: .stopSpinner, object: self)
        }
    }
    
    func getAllRequiredData(){
        getRecentlyAddedItmes(tabType: covidCareHome ? CategoryType.CATEGORY_TYPE_MEDICAL : nil)
        getRecentRequestList()
    }
   
    
    private func getRecentlyAddedItmes(tabType: String?){
        QuickShareRestClient.getRecentlyAddedItemsList(ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: nil, latitude: currentLocation?.latitude ?? 0, longitude: currentLocation?.longitude ?? 0, offSet: 0, maxDistance: QuickShareHomePageViewModel.QUICK_SHARE_RADIUS,tabType: tabType){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let availabelItems = Mapper<AvailableItems>().map(JSONObject: responseObject!["resultData"])
                self.availableProducts.removeAll()
                self.availableProducts.append(contentsOf: availabelItems?.matchedProductListings ?? [AvailableProduct]())
                QuickShareCache.getInstance()?.storeAvailableProductOfUser(availableProducts: self.availableProducts)
                self.offset = availabelItems?.offSet ?? 0
                NotificationCenter.default.post(name: .recentlyAddedItemListReceived, object: self)
            }
        }
    }
    
    private func getRecentRequestList(){
        QuickShareRestClient.getRecentRequestsList(ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: "", latitude: currentLocation?.latitude ?? 0, longitude: currentLocation?.longitude ?? 0, offSet: 0, maxDistance: QuickShareHomePageViewModel.QUICK_SHARE_RADIUS){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.availableRequests = Mapper<AvailableRequest>().mapArray(JSONObject: responseObject!["resultData"]) ?? [AvailableRequest]()
                NotificationCenter.default.post(name: .recentlyRequestedListReceived, object: self)
            }
        }
    }
}
