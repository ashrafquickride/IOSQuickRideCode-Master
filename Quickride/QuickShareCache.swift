//
//  QuickShareCache.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class QuickShareCache{
    
    static var sharedInstance: QuickShareCache?
    var location: Location?
    var categories = [CategoryType]()
    var covidCategories = [CategoryType]()
    var availableProducts = [AvailableProduct]()
    var covidCareHome = false
    
    public static func getInstance() -> QuickShareCache?{
        AppDelegate.getAppDelegate().log.debug("getInstance()")
        if self.sharedInstance == nil {
            self.sharedInstance = QuickShareCache()
        }
        return self.sharedInstance
    }
    
    private func removeCacheInstance(){
        QuickShareCache.sharedInstance = nil
    }
    
    func storeUserLocation(location: Location?){
        if let currentLocation = location{
            self.location = currentLocation
        }
    }
    
    func getUserLocation() -> Location?{
        return self.location
    }
    func storeAvailableCategoryList(categories: [CategoryType]){
        self.categories = categories
        storeAvailableCovidCategoryList(categories: categories)
    }
    func storeAvailableCovidCategoryList(categories: [CategoryType]){
        covidCategories.removeAll()
        for category in categories{
            if category.categoryType == CategoryType.CATEGORY_TYPE_MEDICAL{
                covidCategories.append(category)
            }
        }
    }
    
    func getCategoryObjectForThisCode(categoryCode: String) -> CategoryType?{
        if let index = categories.index(where: { $0.code ==  categoryCode}) {
            return categories[index]
        }else{
            return nil
        }
    }
    func upadteAndNotifyOrderStatus(productOrder: ProductOrder){
        var userInfo =  [String: ProductOrder]()
        userInfo["productOrder"] = productOrder
        NotificationCenter.default.post(name: .updateProductOrderStatus, object: nil, userInfo: userInfo)
    }
    
    func receivedNewProductComment(productComment: ProductComment){
        var userInfo = [ String: ProductComment]()
        userInfo["productComment"] = productComment
        NotificationCenter.default.post(name: .newProductCommentReceived, object: nil, userInfo: userInfo)
    }
    
    func storeAvailableProductOfUser(availableProducts: [AvailableProduct]){
        self.availableProducts = availableProducts
    }
    
    func getAvailableProductOfUser() -> [AvailableProduct]{
        return availableProducts
    }
}

