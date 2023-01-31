//
//  PaymentAckowledgementViewModel.swift
//  Quickride
//
//  Created by Vinutha on 14/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol cancelPaymentResponseActionDelegate {
    func cancelPaymentSucceeded()
}
protocol paymentStatusResponseActionDelegate {
    func paymentSucceeded()
}
class PaymentAckowledgementViewModel {
    
    var orderId: String?
    var cancelPaymentDelegate: cancelPaymentResponseActionDelegate?
    var paymentStatusDelegate: paymentStatusResponseActionDelegate?
    var actionCompletionHandler: paymentActionCompletionHandler?
    var rideId: Double?
    static let PAYMENT_STATUS = "paymentStatus"
    var isFromTaxi = false
    var amount: Double?
    
    func setData(orderId: String, rideId: Double?,isFromTaxi: Bool,amount: Double, actionCompletionHandler: paymentActionCompletionHandler?){
        self.orderId = orderId
        self.rideId = rideId
        self.actionCompletionHandler = actionCompletionHandler
        self.isFromTaxi = isFromTaxi
        self.amount = amount
    }
    
    func cancelPayment(){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.cancelUPIPayment(userId: QRSessionManager.getInstance()?.getUserId(), orderId: self.orderId) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.cancelPaymentDelegate?.cancelPaymentSucceeded()
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        }
    }
    
    func checkPaymentStatus() {
        AccountRestClient.getPaymentStatus(orderId: self.orderId) { (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if let paymentSuccess = responseObject!["resultData"] as? Bool, paymentSuccess{
                    self.paymentStatusDelegate?.paymentSucceeded()
                }
            }
        }
    }
}

