//
//  EnterHandoverOtpViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EnterHandoverOtpViewModel {
    
    //MARK: Variables
    var handler: otpEnteredComplitionHandler?
    var productOrder: ProductOrder?
    var type: String?
    
    static let HANDOVER_PRODUCT = "HANDOVER_PRODUCT"
    static let RETURN_PRODUCT = "RETURN_PRODUCT"
    
    init(type: String,productOrder: ProductOrder,handler: @escaping otpEnteredComplitionHandler) {
        self.handler = handler
        self.productOrder = productOrder
        self.type = type
    }
    
    init() {}
    
    //MARK: Get otp from taker and handover Product
    func completePickupAndHandoverProduct(otp: String){
        QuickShareRestClient.completePickUpProduct(orderId: productOrder?.id ?? "", pickupLat: productOrder?.pickUpLat ?? 0, pickupLng: productOrder?.pickUpLng ?? 0, pickupAddress: productOrder?.pickUpAddress ?? "", otp: otp, handoverImageURL: productOrder?.handOverPic, userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let order = Mapper<Order>().map(JSONObject: responseObject!["resultData"])
                var userInfo = [String : Any]()
                userInfo["productOrder"] = order?.productOrder
                NotificationCenter.default.post(name: .pickUpCompleted, object: nil, userInfo: userInfo)
            } else if responseObject != nil{
                let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                let errorMessage = ErrorProcessUtils.getErrorMessageFromErrorObject(error: error ?? ResponseError())
                var userInfo = [String : Any]()
                userInfo["error"] = errorMessage
                NotificationCenter.default.post(name: .showOTPInvalidError, object: nil, userInfo: userInfo)
            }else{
                NotificationCenter.default.post(name: .showOTPInvalidError, object: nil)
            }
        }
    }
    
    //MARK: get otp from seller and return his/her product
    func confirmReturnProductToSeller(otp: String){
        QuickShareRestClient.completeReturnProduct(orderId: productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? "",otp: otp, returnImageURL: productOrder?.returnHandOverPic, damageAmount: "0"){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let productOrder = Mapper<ProductOrder>().map(JSONObject: responseObject!["resultData"])
                var userInfo = [String : Any]()
                userInfo["productOrder"] = productOrder
                NotificationCenter.default.post(name: .returnProductCompleted, object: nil, userInfo: userInfo)
            } else if responseObject != nil{
                let error = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                let errorMessage = ErrorProcessUtils.getErrorMessageFromErrorObject(error: error ?? ResponseError())
                var userInfo = [String : Any]()
                userInfo["error"] = errorMessage
                NotificationCenter.default.post(name: .showOTPInvalidError, object: nil, userInfo: userInfo)
            }else{
                NotificationCenter.default.post(name: .showOTPInvalidError, object: nil)
            }
        }
    }
}
