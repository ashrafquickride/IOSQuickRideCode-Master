//
//  PendingUPILinkedWalletTransactionViewController.swift
//  Quickride
//
//  Created by Admin on 04/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PendingUPILinkedWalletTransactionViewController : UIViewController,UITableViewDelegate,UITableViewDataSource,PGTransactionDelegate{
    
   @IBOutlet weak var transactionListTableView: UITableView!
    
    @IBOutlet weak var clearNowBtn: UIButton!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var pendingBillAmountLabel: UILabel!
    
    
    var orderId : String?
    var pendingLinkedWalletTransactions = [LinkedWalletPendingTransaction]()
    var totalAmount = 0.0
    var accountUtils = AccountUtils()
    
    static let LINKED_WALLET_PENDING_TRANSACTIONS = "PENDING_TXNS"
    
    func initializeDataBeforePresenting(pendingLinkedWalletTransactions : [LinkedWalletPendingTransaction]){
        self.pendingLinkedWalletTransactions = pendingLinkedWalletTransactions
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionListTableView.delegate = self
        transactionListTableView.dataSource = self
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 8.0)
        getTotalAmount()
        pendingBillAmountLabel.text = String(format: Strings.pending_bill_amount_text, arguments: [String(totalAmount)])
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(PendingUPILinkedWalletTransactionViewController.backgroundViewTapped(_:))))
    }
   
    override func viewDidAppear(_ animated: Bool) {
        CustomExtensionUtility.changeBtnColor(sender: self.clearNowBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        ViewCustomizationUtils.addCornerRadiusToView(view: self.clearNowBtn, cornerRadius: 8.0)
    }
    
    @IBAction func clearNowBtnClicked(_ sender: Any) {
        orderId = accountUtils.generateOrderIDWithPrefix()
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.updateOrderIdForPendingLinkedWalletTransaction(userId: (QRSessionManager.getInstance()?.getUserId())!, txnIds: getTransactionIdsString(), orderId:orderId!, paymentType: AccountTransaction.ACCOUNT_RECHARGE_SOURCE_PAYTM, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.accountUtils.rechargeThroughPayTm(amount: self.totalAmount, delegate: self, custId: PendingUPILinkedWalletTransactionViewController.LINKED_WALLET_PENDING_TRANSACTIONS + QRSessionManager.getInstance()!.getUserId(), orderId: self.orderId!)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pendingLinkedWalletTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingLinkWalletTransactionsTableViewCell", for: indexPath as IndexPath) as! PendingLinkWalletTransactionsTableViewCell
        if pendingLinkedWalletTransactions.count <= indexPath.row{
            return cell
        }
        let pendingLinkedWalletTransaction = pendingLinkedWalletTransactions[indexPath.row]
        cell.initializeViews(linkedWalletPendingTransaction: pendingLinkedWalletTransaction)
        return cell
     }
    
    func getTransactionIdsString() -> String{
        var txnIds = [String]()
        for transaction in pendingLinkedWalletTransactions{
            txnIds.append(transaction.transactionId!)
        }
       return txnIds.joined(separator: ",")
    }
    
    func getTotalAmount(){
        totalAmount = 0
        for transaction in pendingLinkedWalletTransactions{
            totalAmount += transaction.amount!
        }
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
            UserDataCache.getInstance()?.pendingLinkedWalletTransactions?.removeAll()
        }
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
    
    
    @objc func backgroundViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
        
    }
    
    
    
}
