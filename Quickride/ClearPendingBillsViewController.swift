//
//  ClearPendingBillsViewController.swift
//  Quickride
//
//  Created by HK on 22/06/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class ClearPendingBillsViewController: UIViewController {

    @IBOutlet weak var pendingAmountLabel: UILabel!
    @IBOutlet weak var pendingBillTableView: UITableView!
    @IBOutlet weak var payByURLArrowImageView: UIImageView!
    
    private var viewModel = ClearPendingBillsViewModel()
    
    func initialisePendingBills(pendingDues: [PendingDue]){
        viewModel = ClearPendingBillsViewModel(pendingDues: pendingDues)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.getTotalAmount()
        setUpUi()
    }
    
    private func setUpUi(){
        pendingBillTableView.register(UINib(nibName: "PendingDueTableViewCell", bundle: nil), forCellReuseIdentifier: "PendingDueTableViewCell")
        pendingBillTableView.reloadData()
        pendingAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: viewModel.totalPendingAmount)])
        self.payByURLArrowImageView.transform = CGAffineTransform(rotationAngle: (.pi))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @IBAction func payNowButtonTapped(_ sender: Any) {
        viewModel.orderId = AccountUtils().generateOrderIDWithPrefix()
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.updateOrderIdToClearPendingBills(userId: UserDataCache.getInstance()?.userId ?? "", dueIds: viewModel.getPendingDueIdsString(), orderId: viewModel.orderId!, paymentType: AccountTransaction.ACCOUNT_RECHARGE_SOURCE_PAYTM) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                AccountUtils().rechargeThroughPayTm(amount: self.viewModel.totalPendingAmount, delegate: self,custId: PendingDue.TXN_PREFIX + (UserDataCache.getInstance()?.userId ?? ""), orderId: self.viewModel.orderId!)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    @IBAction func needHelpButtonTapped(_ sender: Any) {
        let pendingDueHelpViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PendingDueHelpViewController") as! PendingDueHelpViewController
        self.navigationController?.pushViewController(pendingDueHelpViewController, animated: true)
    }
    @IBAction func payBYURLTapped(_ sender: Any) {
        displayPayByOtherModes()
    }
    
    private func displayPayByOtherModes(){
        guard viewModel.pendingDues.count > 0 else {
            return
        }
        let dueIds = viewModel.pendingDues.map{(String($0.id))}.joined(separator: ",")
        AccountRestClient.getPaymentLinkForPayment(dueIds: dueIds) { responseObject, error in
            let result = RestResponseParser<TaxiPayByOtherModesInfo>().parse(responseObject: responseObject, error: error)
            if let taxiPayByOtherModesInfo = result.0{
                if let linkUrl = taxiPayByOtherModesInfo.paymentLink, let successURL = taxiPayByOtherModesInfo.redirectionUrl {
                    let queryItems1 = URLQueryItem(name: "&isMobile", value: "true")
                    var urlcomps1 = URLComponents(string :  linkUrl )
                    urlcomps1?.queryItems = [queryItems1]
                    
                    let queryItems2 = URLQueryItem(name: "&isMobile", value: "true")
                    var urlcomps2 = URLComponents(string :  successURL )
                    urlcomps2?.queryItems = [queryItems2]
                    if urlcomps1?.url != nil {
                        let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                        webViewController.initializeDataBeforePresenting(titleString: "Payment", url: urlcomps1?.url, actionComplitionHandler: nil)
                        webViewController.successUrl = urlcomps2?.url
                        self.navigationController?.pushViewController(webViewController, animated: false)
                    } else {
                        UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
                    }
                }
            }
        }
    }
    
}
extension ClearPendingBillsViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.pendingDues.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PendingDueTableViewCell", for: indexPath) as! PendingDueTableViewCell
        cell.initialiseDueView(pendingDue: viewModel.pendingDues[indexPath.row])
        return cell
    }
}
//MARK: PGTransactionDelegate
extension ClearPendingBillsViewController: PGTransactionDelegate{
    func didSucceedTransaction(_ controller: PGTransactionViewController!, response: [AnyHashable : Any]!) {
        AccountUtils().removeController(controller: controller)
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.updateLinkedWalletOfUserAsSuccess(userId: (QRSessionManager.getInstance()?.getUserId())!, orderId: viewModel.orderId!, paymentType: AccountTransaction.ACCOUNT_RECHARGE_SOURCE_PAYTM, amount: viewModel.totalPendingAmount, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( "Pending Bills Cleared")
                self.navigationController?.popViewController(animated: false)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
            UserDataCache.getInstance()?.pendingLinkedWalletTransactions?.removeAll()
        }
    }
    
    func didFailTransaction(_ controller: PGTransactionViewController!, error: Error!, response: [AnyHashable : Any]!) {
        AccountUtils().removeController(controller: controller)
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
       AccountUtils().removeController(controller: controller)
    }
}
