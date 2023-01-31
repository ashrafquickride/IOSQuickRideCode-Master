//
//  AddProductStepsViewModel.swift
//  Quickride
//
//  Created by Halesh on 08/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import SDWebImage

class AddProductStepsViewModel{
    
    //MARK: Variables
    var productType: String?
    var step = 1
    var productPhotos = [UIImage]()
    var product = Product()
    var postedProduct: PostedProduct?
    var imageList = [String]()
    var isFromEditDetails = false
    var categoryCode: String?
    var requestId: String?
    var covidHome = false
    
    init(productType: String,isFromEditDetails: Bool, product: Product?,categoryCode: String,requestId: String?,covidHome : Bool) {
        self.productType = productType
        self.isFromEditDetails = isFromEditDetails
        self.product = product ?? Product()
        self.categoryCode = categoryCode
        self.requestId = requestId
        self.covidHome = covidHome
        if !isFromEditDetails{
            self.product.categoryCode = categoryCode
            self.product.location.append(QuickShareCache.getInstance()?.getUserLocation() ?? Location())
        }
        assignAddedPhotos()
    }
    
    init() {}
    func assignAddedPhotos(){
        guard let imageList = product.imageList?.components(separatedBy: ",") else { return }
        let imageView = UIImageView()
        for imageUrl in imageList{
            self.imageList.append(imageUrl)
            guard  let url = URL(string: imageUrl) else { return }
            imageView.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions(rawValue: 0)) { (image, error, cacheType, url) in
                self.productPhotos.append(image ?? UIImage())
            }
        }
    }
    func checkRequiredFieldsfilledOrNot() -> Bool{
        if covidHome {
            if step == 1{
                if product.title?.isEmpty == false && product.tradeType?.isEmpty == false &&  imageList.isEmpty == false && product.description?.isEmpty == false{
                    return true
                } else {
                    return false
                }
            }else{
                if ((product.tradeType  == Product.RENT && product.pricePerDay?.isEmpty == false && product.pricePerMonth?.isEmpty == false && product.deposit != 0) || (product.tradeType  == Product.SELL && product.finalPrice?.isEmpty == false) || (product.tradeType  == Product.BOTH && product.pricePerDay?.isEmpty == false && product.pricePerMonth?.isEmpty == false && product.finalPrice?.isEmpty == false && product.deposit != 0) || product.tradeType  == Product.DONATE || product.tradeType  == Product.SHARE) && product.location.isEmpty == false{
                    return true
                } else {
                    return false
                }
            }
        }else{
            if step == 1{
                if product.title?.isEmpty == false && product.condition?.isEmpty == false && product.tradeType?.isEmpty == false && product.manufacturedDate != 0 && imageList.isEmpty == false && product.description?.isEmpty == false{
                    return true
                } else {
                    return false
                }
            }else{
                if ((product.tradeType  == Product.RENT && product.pricePerDay?.isEmpty == false && product.pricePerMonth?.isEmpty == false && product.deposit != 0) || (product.tradeType  == Product.SELL && product.finalPrice?.isEmpty == false) || (product.tradeType  == Product.BOTH && product.pricePerDay?.isEmpty == false && product.pricePerMonth?.isEmpty == false && product.finalPrice?.isEmpty == false && product.deposit != 0)) && product.location.isEmpty == false{
                    return true
                } else {
                    return false
                }
            }
        }
        
    }
    
    func prepareImageList(){
        var imageUrls = ""
        for imageURl in imageList{
            if imageUrls.isEmpty{
                imageUrls += imageURl
            }else{
                imageUrls += "," + imageURl
            }
        }
        product.imageList = imageUrls
    }
    
    func sumbitAddedProduct(){
        QuickShareRestClient.addProduct(product: product,requestId: requestId){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.postedProduct = Mapper<PostedProduct>().map(JSONObject: responseObject!["resultData"])
              NotificationCenter.default.post(name: .productAddedSuccessfully, object: nil)
            } else {
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func updateAddedProduct(){
        QuickShareRestClient.updateAddedProduct(productId: product.id ?? "", product: product){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.postedProduct = Mapper<PostedProduct>().map(JSONObject: responseObject!["resultData"])
                NotificationCenter.default.post(name: .productUpdatedSuccessfully, object: nil)
            } else {
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
}
