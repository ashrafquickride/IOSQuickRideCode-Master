//
//  ProductViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 27/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in).` All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ProductViewModel{

    var product = AvailableProduct()
    var similarProducts = [AvailableProduct]()
    var isRequiredToShowHowRentalWorks = false
    var productComments = [ProductComment]()
    var isFromOrder = false
    var isRequiredToShowAllComments = false
    
    init(product: AvailableProduct,isFromOrder: Bool) {
        self.product = product
        self.isFromOrder = isFromOrder
    }
    
    init() {}
    
    func getSimilarProducts(){
        let currentLocation = QuickShareCache.getInstance()?.location
        QuickShareRestClient.getRecentlyAddedItemsList(ownerId: UserDataCache.getInstance()?.userId ?? "", categoryCode: product.categoryCode, latitude: currentLocation?.latitude ?? 0, longitude: currentLocation?.longitude ?? 0, offSet: 0, maxDistance: 10,tabType: nil){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if let availabelItems = Mapper<AvailableItems>().map(JSONObject: responseObject!["resultData"]){
                    for availableProduct in availabelItems.matchedProductListings{
                        if availableProduct.productListingId != self.product.productListingId{
                            self.similarProducts.append(availableProduct)
                        }
                    }
                }
                NotificationCenter.default.post(name: .receivedSimilarItems, object: self)
            }
        }
    }
    
    func getNumberOfViewsOfProduct(){
        QuickShareRestClient.getNumberOfViewsOfProduct(entityId: product.productListingId ?? "", entityType: AvailableProduct.LISTING, userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.product.noOfViews =  responseObject!["resultData"] as? Int ?? 0
                NotificationCenter.default.post(name: .numberOfViewsRecieved, object: self)
            }
        }
    }
    
    func updateProductViews(){
        QuickShareRestClient.updateViewsOfProduct(entityId: product.productListingId ?? "", entityType: AvailableProduct.LISTING, userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
            }
        }
    }
    
    func getProductComments(){
        QuickShareRestClient.getProductComments(listingId: product.productListingId ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.productComments = Mapper<ProductComment>().mapArray(JSONObject: responseObject!["resultData"]) ?? [ProductComment]()
                NotificationCenter.default.post(name: .productCommentsReceived, object: self)
            }
        }
    }
}
