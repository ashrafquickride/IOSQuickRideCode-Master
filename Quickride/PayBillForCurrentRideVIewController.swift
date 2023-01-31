//
//  PayBillForCurrentRideVIewController.swift
//  Quickride
//
//  Created by Admin on 19/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PayBillForCurrentRideVIewController : UIViewController,PGTransactionDelegate{
 
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var payNowBtn: UIButton!
    
    @IBOutlet weak var rideAmountLbl: UILabel!
    
    var orderId : String?
    var totalAmount = 0.0
    var accountUtils = AccountUtils()
    var pendingLinkedWalletTransactions = [LinkedWalletPendingTransaction]()
    var txIds : String?
    
    func initializeDataBeforePresenting(pendingLinkedWalletTransactions : [LinkedWalletPendingTransaction]){
        self.pendingLinkedWalletTransactions = pendingLinkedWalletTransactions
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PayBillForCurrentRideVIewController.backgroundViewTapped(_:))))
        txIds = getTransactionIdsString()
        rideAmountLbl.text = StringUtils.getStringFromDouble(decimalNumber: self.totalAmount)+" "+Strings.pts
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 8.0)
        CustomExtensionUtility.changeBtnColor(sender: self.payNowBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        ViewCustomizationUtils.addCornerRadiusToView(view: self.payNowBtn, cornerRadius: 5.0)
    }
    
    
    @IBAction func payNowBtnClicked(_ sender: Any) {
        orderId = accountUtils.generateOrderIDWithPrefix()
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.updateOrderIdForPendingLinkedWalletTransaction(userId: (QRSessionManager.getInstance()?.getUserId())!, txnIds: txIds! , orderId: orderId!, paymentType: AccountTransaction.ACCOUNT_RECHARGE_SOURCE_PAYTM, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.accountUtils.rechargeThroughPayTm(amount: self.totalAmount, delegate: self, custId: PendingUPILinkedWalletTransactionViewController.LINKED_WALLET_PENDING_TRANSACTIONS + QRSessionManager.getInstance()!.getUserId(), orderId: self.orderId!)

            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    func getTransactionIdsString() -> String{
        var txnIds = [String]()
        totalAmount = 0
        for transaction in pendingLinkedWalletTransactions{
            txnIds.append(transaction.transactionId!)
            totalAmount += transaction.amount!
        }
        return txnIds.joined(separator: ",")
    }
    
    
    @objc func backgroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
     }
    
    func didSucceedTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
        self.accountUtils.removeController(controller: controller)
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.updateLinkedWalletOfUserAsSuccess(userId: (QRSessionManager.getInstance()?.getUserId())!, orderId: self.orderId!, paymentType: AccountTransaction.ACCOUNT_RECHARGE_SOURCE_PAYTM, amount: totalAmount, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( "Pending Bills Cleared")
                self.view.removeFromSuperview()
                self.removeFromParent()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
        UserDataCache.getInstance()?.pendingLinkedWalletTransactions?.removeAll()
    }
    
    func didFailTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        self.accountUtils.removeController(controller: controller)
        if ((response) != nil) {
            if let responseCodeObj = response["RESPCODE"] {
                let responseCodeStr = responseCodeObj as? String
                let responseCode = Int(responseCodeStr!)
                if (responseCode == AppConfiguration.paytm_transaction_cancelled_response_code_1 || responseCode == AppConfiguration.paytm_transaction_cancelled_response_code_2 || responseCode == AppConfiguration.paytm_transaction_cancelled_response_code_3 ) {
                    AppDelegate.getAppDelegate().log.debug("Transaction was cancelled by user")
                    return
                }
            }
            MessageDisplay.displayAlert(title: Strings.recharge_failed,messageString: response!["RESPMSG"] as! String, viewController: self, handler: nil)
        }
        else if ((error) != nil){
            MessageDisplay.displayAlert( title: Strings.recharge_failed,messageString: error.localizedDescription, viewController: self, handler: nil)
        }
        UserDataCache.getInstance()?.pendingLinkedWalletTransactions?.removeAll()
    }
    
    func didCancelTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        self.accountUtils.removeController(controller: controller)
    }
    
    
}
