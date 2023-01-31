//
//  PendingDueViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 04/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PendingDueViewModel {
    
    var pendingDue: PendingDue?
    var userBalance = 0.0
    
    init(pendingDue: PendingDue) {
        self.pendingDue = pendingDue
    }
    
    init() {}
    
    func getQRbalanace(){
        UserDataCache.getInstance()?.getAccountInformation(completionHandler: { (userAccount, error) -> Void in
            if userAccount != nil{
                let balanace = (userAccount?.earnedPoints ?? 0) + (userAccount?.purchasedPoints ?? 0)
                self.userBalance = balanace - (userAccount?.reserved ?? 0)
            }
        })
    }
    
    func payPendingDue(paymentType: String?){
        NotificationCenter.default.post(name: .startSpinner, object: self)
        AccountRestClient.payPendingDues(userId: UserDataCache.getInstance()?.userId ?? "", paymentType: paymentType ?? "", dueId: pendingDue?.id ?? 0) { (responseObject, error) in
            NotificationCenter.default.post(name: .stopSpinner, object: self)
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.pendingDue = Mapper<PendingDue>().map(JSONObject: responseObject!["resultData"])
                NotificationCenter.default.post(name: .paidPendingDue, object: self)
                var userInfo = [String : Any]()
                userInfo["PendingDue"] = self.pendingDue
                NotificationCenter.default.post(name: .pendingDuePaidInAccountSection, object: nil, userInfo: userInfo)
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                let errorResponse = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                if errorResponse?.errorCode == PendingDue.UPI_PAYMENT_ERROR_CODE, let extraInfo = errorResponse?.extraInfo, !extraInfo.isEmpty{
                    AccountUtils().showPaymentConfirmationView(paymentInfo: extraInfo, rideId: nil){ (result) in
                        if result == Strings.success {
                            NotificationCenter.default.post(name: .paidPendingDue, object: self)
                            NotificationCenter.default.post(name: .pendingDuePaidInAccountSection, object: nil)
                        }
                    }
                }else{
                    var userInfo = [String : Any]()
                    userInfo["responseObject"] = responseObject
                    userInfo["error"] = error
                    NotificationCenter.default.post(name: .handleError, object: self, userInfo: userInfo)
                }
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleError, object: self, userInfo: userInfo)
            }
        }
    }
}

extension Notification.Name{
    static let handleError = NSNotification.Name("handleError")
    static let paidPendingDue = NSNotification.Name("paidPendingDue")
    static let startSpinner = NSNotification.Name("startSpinner")
    static let pendingDuePaidInAccountSection = NSNotification.Name("pendingDuePaidInAccountSection")
}
