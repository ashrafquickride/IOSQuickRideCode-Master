//
//  ProductListViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 28/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ProductListViewModel {
    
    var availabelProducts = [AvailableProduct]()
    var mostViewedProducts = [AvailableProduct]()
    var remaingProducts = [AvailableProduct]()
    var screenTitle: String?
    var categoryCode: String?
    
    init(categoryCode: String?,title: String,availabelProducts: [AvailableProduct]) {
        self.availabelProducts = availabelProducts
        screenTitle = title
        self.categoryCode = categoryCode
    }
    
    init() {}
    
    func getCategoryObjectForCategoryCode() -> CategoryType?{
        let categoty = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: categoryCode ?? "")
        return categoty
    }
    
    func getProductListForThisCategory(){
        let currentLocation = QuickShareCache.getInstance()?.location
        QuickShareRestClient.getRecentlyAddedItemsList(ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: categoryCode, latitude: currentLocation?.latitude ?? 0, longitude: currentLocation?.longitude ?? 0, offSet: 0, maxDistance: QuickShareHomePageViewModel.QUICK_SHARE_RADIUS,tabType: nil){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let availabelItems = Mapper<AvailableItems>().map(JSONObject: responseObject!["resultData"])
                self.availabelProducts = availabelItems?.matchedProductListings ?? [AvailableProduct]()
                NotificationCenter.default.post(name: .productsReceived, object: self)
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
}
