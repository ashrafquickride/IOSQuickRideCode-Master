//
//  UPIPaymemtInitiationViewModel.swift
//  Quickride
//
//  Created by Vinutha on 14/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol upiPaymemtInitiationViewModelDelegate {
    func onSucess(orderId: String)
}

class UPIPaymemtInitiationViewModel {
    
    var paymentInfo: [String: Any]?
    var upiPaymemtInitiationViewModelDelegate: upiPaymemtInitiationViewModelDelegate?
    var actionCompletionHandler: paymentActionCompletionHandler?
    var rideId: Double?

    init(paymentInfo: [String: Any], rideId: Double?, actionCompletionHandler: paymentActionCompletionHandler?) {
        self.paymentInfo = paymentInfo
        self.rideId = rideId
        self.actionCompletionHandler = actionCompletionHandler
    }
    func getDefaultLinkedWallet() -> LinkedWallet?{
        return UserDataCache.getInstance()?.getDefaultLinkedWallet()
    }
    
    func initiateUPIPayment(amount: String?) {
        var orderId: String?
        if let paymentInfo = paymentInfo {
            for key in paymentInfo.keys {
                if key == "OrderId" {
                    orderId = paymentInfo[key] as? String
                }
            }
        }
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.initiateUPIPayment(userId: QRSessionManager.getInstance()?.getUserId(), orderId: orderId, amount: amount, paymentType: getDefaultLinkedWallet()?.type) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as? String == "SUCCESS" {
                if let orderId = orderId{
                    self.upiPaymemtInitiationViewModelDelegate?.onSucess(orderId: orderId)
                }
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
            
        }
    }
    func updateUPIId(upiId: String,handler : @escaping AccountRestClient.responseJSONCompletionHandler){
        let UPIType = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type
        AccountRestClient.linkUPIWallet(userId: UserDataCache.getInstance()?.userId ?? "", mobileNo: UserDataCache.getInstance()?.currentUser?.contactNo, email: UserDataCache.getInstance()?.getLoggedInUserProfile()?.emailForCommunication, vpaAddress: upiId, type: UPIType, viewController: nil) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet!)
                UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet!)
                handler(nil,nil)
            }else{
                handler(responseObject,error)
            }
        }
    }
}
