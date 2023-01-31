//
//  ReviewAndPayViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 31/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ReviewAndPayViewModel{
    
    var productRequest = RequestProduct()
    var selectedProduct = AvailableProduct()
    
    init(productRequest: RequestProduct,selectedProduct: AvailableProduct) {
        self.productRequest = productRequest
        self.selectedProduct = selectedProduct
    }
    
    init() {}
    
    func calculateFullAmountAndShow() -> Int{
        if productRequest.tradeType == Product.RENT{
            let rentalDays = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: productRequest.toTime/1000), date2: NSDate(timeIntervalSince1970: productRequest.fromTime/1000))
            let totalAmount = (Int(productRequest.requestingPricePerDay ?? "") ?? 0) * rentalDays
            if productRequest.paymentMode == RequestProduct.PAY_FULL_AMOUNT{
                return totalAmount + selectedProduct.deposit
            }else{
                let category = QuickShareCache.getInstance()?.getCategoryObjectForThisCode(categoryCode: productRequest.categoryCode ?? "")
                return (totalAmount*(category?.bookingAmountForRent ?? 0))/100
            }
        }else{
            if productRequest.paymentMode == RequestProduct.PAY_FULL_AMOUNT{
                return Int(selectedProduct.finalPrice)
            }else{
                return selectedProduct.bookingFee
            }
        }
    }
    
    func sendRequestToSelectedProduct(viewController: UIViewController){
        QuickShareRestClient.requestProduct(requestProduct: productRequest){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let order = Mapper<Order>().map(JSONObject: responseObject!["resultData"])
                var userInfo = [String: Any]()
                userInfo["order"] = order
                NotificationCenter.default.post(name: .requestSentToSelectedProduct, object: nil, userInfo: userInfo)
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                QuickShareSpinner.stop()
                let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                if error?.errorCode == RideValidationUtils.INSUFFICIENT_BALANCE_FOR_BUY_OR_RENT
                    || error?.errorCode == RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE{
                    RideValidationUtils.handleBalanceInsufficientError(viewController: viewController, title: Strings.low_bal_in_account, errorMessage: Strings.add_money_for_product, primaryAction: "", secondaryAction: nil, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                        self.sendRequestToSelectedProduct(viewController: viewController)
                    })
                }else{
                    var userInfo = [String : Any]()
                    userInfo["responseObject"] = responseObject
                    userInfo["error"] = error
                    NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
                }
            } else {
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
}
