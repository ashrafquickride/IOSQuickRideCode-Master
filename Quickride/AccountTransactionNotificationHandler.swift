//
//  AccountTransactionNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
// Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class AccountTransactionNotificationHandler : UserAccountNotificationHandler {
    
    override func handleNewUserNotification(clientNotification: UserNotification) {
      AppDelegate.getAppDelegate().log.debug("handleNewUserNotification()")
         let userDataCache = UserDataCache.getInstance()
        if userDataCache != nil{
            userDataCache!.refreshAccountInformationInCache()
        }
        super.handleNewUserNotification(clientNotification: clientNotification)
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        let accountTransactionDetails = Mapper<AccountTransaction>().map(JSONString: userNotification.msgObjectJson ?? "")
        if let billDetails = accountTransactionDetails{
            getBillAndNavigateToTripReport(accountTransaction: billDetails, viewController: viewController)
        }else{
            super.handleTap(userNotification: userNotification, viewController: viewController)
            moveToPastTransaction(viewController: viewController)
        }
    }
    private func moveToPastTransaction(viewController: UIViewController?){
        let transactionVC:TransactionViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
        transactionVC.intialisingData(isFromRewardHistory: false)
        viewController?.navigationController?.pushViewController(transactionVC, animated: false)
    }
    
    private func getBillAndNavigateToTripReport(accountTransaction: AccountTransaction,viewController: UIViewController?){
        if let transactiontype = accountTransaction.transactiontype, let sourceRefIdStr = accountTransaction.sourceRefId, let sourceRefId = Double(sourceRefIdStr){
            if transactiontype == AccountTransaction.ACCOUNT_TRANSACTION_TYPE_DEBIT && accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_SPENT && accountTransaction.accountId != nil{
                getPassengerBill(userId: accountTransaction.accountId!, passengerRideId: sourceRefId, viewController: viewController)
            }else if transactiontype == AccountTransaction.ACCOUNT_TRANSACTION_TYPE_CREDIT && accountTransaction.sourceType == AccountTransaction.ACCOUNT_TRANSACTION_SRC_TYPE_EARNED && accountTransaction.refAccountId != nil{
                getRiderBill(userId: accountTransaction.refAccountId!, riderRideId: sourceRefId, viewController: viewController)
            }else{
                moveToPastTransaction(viewController: viewController)
            }
        }else{
            moveToPastTransaction(viewController: viewController)
        }
    }
    
    private func getRiderBill(userId: String, riderRideId: Double, viewController: UIViewController?){
       QuickRideProgressSpinner.startSpinner()
        BillRestClient.getRiderRideBillingDetails(id: StringUtils.getStringFromDouble(decimalNumber:
                                                                                        riderRideId ), userId: userId) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let rideBillingDetailslist = Mapper<RideBillingDetails>().mapArray(JSONObject: responseObject!["resultData"])!
                self.moveToRiderTripReport(riderRideId: riderRideId, rideBillingDetails: rideBillingDetailslist, viewController: viewController)
            }else {
                self.moveToPastTransaction(viewController: viewController)
            }
            
        }
    }
    
    
    private func getPassengerBill(userId : Double, passengerRideId : Double, viewController: UIViewController?){
        QuickRideProgressSpinner.startSpinner()
        
        BillRestClient.getPassengerRideBillingDetails(id: StringUtils.getStringFromDouble(decimalNumber: passengerRideId), userId: StringUtils.getStringFromDouble(decimalNumber: userId), completionHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let rideBillingDetails = Mapper<RideBillingDetails>().map(JSONObject: responseObject!["resultData"])!
                var rideBillingDetailslist = [RideBillingDetails]()
                rideBillingDetailslist.append(rideBillingDetails)
                self.moveToPasssengerTripReport(passengerRideId: passengerRideId,rideBillingDetails: rideBillingDetailslist, viewController: viewController)
            }else{
                self.moveToPastTransaction(viewController: viewController)
            }
            
        })
    }
    private func moveToRiderTripReport(riderRideId: Double,rideBillingDetails: [RideBillingDetails]?,viewController: UIViewController?) {
        let billVC = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.billViewController) as! BillViewController
        billVC.initializeDataBeforePresenting(rideBillingDetails: rideBillingDetails, isFromClosedRidesOrTransaction: true,rideType: Ride.RIDER_RIDE,currentUserRideId: Double(rideBillingDetails?.last?.sourceRefId ?? "") ?? 0)
        viewController?.navigationController?.pushViewController(billVC, animated: false)
    }
    
    private func moveToPasssengerTripReport(passengerRideId: Double,rideBillingDetails: [RideBillingDetails]?, viewController: UIViewController?) {
        let billVC = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.billViewController) as! BillViewController
        billVC.initializeDataBeforePresenting(rideBillingDetails: rideBillingDetails, isFromClosedRidesOrTransaction: true,rideType: Ride.PASSENGER_RIDE,currentUserRideId: passengerRideId)
       ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: billVC, animated: false)
    }
}
