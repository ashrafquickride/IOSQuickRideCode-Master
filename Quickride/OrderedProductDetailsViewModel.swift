//
//  OrderedProductDetailsViewModel.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class OrderedProductDetailsViewModel{
    
    //MARK: Variables
    var order: Order?
    var productOwnerInfo: UserBasicInfo?
    var isFromMyOrder = false
    var invoice: ProductOrderInvoice?
    var orderPayment: OrderPayment?
    var rating = 0
    var alreadyGivenRating = -1
    var productFeedback: String?
    var failedAmount = 0.0
    var failedTransactionType: String?
    var isShowedPendingScreen = false
    var isRequiredToShowCancelOption = true
    
    init(order: Order,isFromMyOrder: Bool) {
        self.order = order
        self.isFromMyOrder = isFromMyOrder
    }
    
    init() {}
    
    func getProductOwnerContactFromSerever(userId : String,handler: @escaping contactNoReceiverhandler){
        UserRestClient.getUserContactNo(userId: userId, uiViewController: nil) { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let contactNo = responseObject!["resultData"] as? String
                handler(contactNo ?? "")
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func getProductOwnerBasicInfo(){
        UserDataCache.getInstance()?.getUserBasicInfo(userId: order?.postedProduct?.ownerId ?? 0, handler: { (userBasicInfo, responseError, error) in
            if let userBasicInfo = userBasicInfo{
                self.productOwnerInfo = userBasicInfo
                NotificationCenter.default.post(name: .receivedProductOwnerDetails, object: nil)
            }
        })
    }
    func getMyOrderPaidAndBalance(){
        QuickShareRestClient.getMyOrderPaidAndBalanceAmount(orderId: order?.productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.orderPayment = Mapper<OrderPayment>().map(JSONObject: responseObject!["resultData"])
                NotificationCenter.default.post(name: .myOrderPaidAndBalanceReceived, object: nil)
                self.checkAnyFailedTransaction()
            }
        }
    }
    private func checkAnyFailedTransaction(){
        guard let paymentStatus = orderPayment?.paymentStatus else { return }
        for paymentStatus in paymentStatus{
            if paymentStatus.type == OrderPayment.BOOKING && paymentStatus.status == OrderPayment.OPEN && !paymentStatus.paymentInProgress{
                failedAmount = paymentStatus.pending
                failedTransactionType = paymentStatus.type
            }else if paymentStatus.type == OrderPayment.FINAL && paymentStatus.status == OrderPayment.OPEN && !paymentStatus.paymentInProgress{
                failedAmount += paymentStatus.pending
                failedTransactionType = (failedTransactionType ?? "") + (paymentStatus.type ?? "")
            }else if paymentStatus.type == OrderPayment.RENT && paymentStatus.status == OrderPayment.OPEN && !paymentStatus.paymentInProgress{
                failedAmount = paymentStatus.pending
                failedTransactionType = paymentStatus.type
            }
            if order?.productOrder?.status == Order.ACCEPTED && order?.productOrder?.paymentMode == RequestProduct.PAY_BOOKING_OR_DEPOSITE_FEE{
                if paymentStatus.type == OrderPayment.BOOKING{
                    if order?.productOrder?.tradeType == Product.SELL{
                        let remainingAmount = (order?.productOrder?.finalPrice ?? 0) - paymentStatus.amount
                        order?.productOrder?.remainingAmount = remainingAmount
                    }else{
                        let rentalDays = DateUtils.getExactDifferenceBetweenTwoDatesInDays(date1: NSDate(timeIntervalSince1970: (order?.productOrder?.toTimeInMs ?? 0)/1000), date2: NSDate(timeIntervalSince1970: (order?.productOrder?.fromTimeInMs ?? 0)/1000))
                        let totalAmount = (order?.productOrder?.pricePerDay ?? 0) * Double(rentalDays)
                         let remainingAmount = (totalAmount + Double(order?.productOrder?.deposit ?? 0)) - paymentStatus.amount
                        order?.productOrder?.remainingAmount = remainingAmount
                    }
                }
            }
        }
        NotificationCenter.default.post(name: .showPendingAmount, object: nil)
    }
    
    func cancelOrder(reason: String){
        QuickShareRestClient.cancelMyPlacedOrder(orderId: order?.productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? "", reason: reason){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                var userInfo = [String : Any]()
                userInfo["order"] = self.order
                NotificationCenter.default.post(name: .placedOrderCancelled, object: nil, userInfo: userInfo)
            } else {
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
    
    func getInvoice(){
        QuickShareRestClient.getInvoiceForOrder(orderId: order?.productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.invoice = Mapper<ProductOrderInvoice>().map(JSONObject: responseObject!["resultData"])
                NotificationCenter.default.post(name: .invoiceRecieved, object: nil)
            }
        }
    }
    func saveRating(){
        QuickShareRestClient.upadteProductRating(listingId: order?.postedProduct?.id ?? "", rating: rating, userId: UserDataCache.getInstance()?.userId ?? "", comment: productFeedback ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
            }
        }
    }
    
    func getProductRating(){
        QuickShareRestClient.getPerticularProductRating(listingId: order?.postedProduct?.id ?? "",userId: UserDataCache.getInstance()?.userId ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                let productRating  = Mapper<ProductRating>().map(JSONObject: responseObject!["resultData"])
                self.alreadyGivenRating = productRating?.rating ?? 0
                NotificationCenter.default.post(name: .receivedProductRating, object: nil)
            }else{
                self.alreadyGivenRating = 0
            }
        }
    }
    
    func payFailedAndOutstandingAmount(viewController: UIViewController){
        QuickShareRestClient.payFailedAndOutstandingAmount(orderId: order?.productOrder?.id ?? "", userId: UserDataCache.getInstance()?.userId ?? "", typeList: failedTransactionType ?? ""){ (responseObject, error) in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                NotificationCenter.default.post(name: .pendingAmountPaid, object: nil)
                self.isShowedPendingScreen = true
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                QuickShareSpinner.stop()
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!.value(forKey: "resultData"))
                if responseError?.errorCode == RideValidationUtils.INSUFFICIENT_BALANCE_FOR_BUY_OR_RENT
                    || responseError?.errorCode == RideValidationUtils.PASSENGER_INSUFFICIENT_WITHDRAWABLE_BALANCE{
                    RideValidationUtils.handleBalanceInsufficientError(viewController:  viewController, title: Strings.low_bal_in_account, errorMessage: Strings.add_money_for_product, primaryAction: "", secondaryAction: nil, addMoneyOrWalletLinkedComlitionHanler: { (result) in
                        self.payFailedAndOutstandingAmount(viewController: viewController)
                    })
                }else{
                    var userInfo = [String : Any]()
                    userInfo["responseObject"] = responseObject
                    userInfo["error"] = error
                    NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
                }
            }else{
                var userInfo = [String : Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .handleApiFailureError, object: nil, userInfo: userInfo)
            }
        }
    }
}
