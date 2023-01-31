//
//  PendingDueViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 04/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class PendingDueViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var dueAmountLabel: UILabel!
    @IBOutlet weak var dueInfoLabel: UILabel!
    
    //MARK: Variables
    var pendingDueViewModel = PendingDueViewModel()
    func showDueView(pendingDue: PendingDue){
        pendingDueViewModel = PendingDueViewModel(pendingDue: pendingDue)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pendingDueViewModel.getQRbalanace()
        prepareView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        confirmNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func prepareView(){
        let pendingDue = (pendingDueViewModel.pendingDue?.dueAmount ?? 0) - (pendingDueViewModel.pendingDue?.paidAmount ?? 0)
        dueAmountLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [String(pendingDue)])
        dueInfoLabel.text = pendingDueViewModel.pendingDue?.remarks
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:))))
    }
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleError), name: .handleError , object: pendingDueViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(paidPendingDue), name: .paidPendingDue , object: pendingDueViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(stopSpinner), name: .stopSpinner , object: pendingDueViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(startSpinner), name: .startSpinner , object: pendingDueViewModel)
    }
    
    @objc private func stopSpinner(notification: NSNotification){
        QuickRideProgressSpinner.stopSpinner()
    }
    
    @objc private func startSpinner(notification: NSNotification){
        QuickRideProgressSpinner.startSpinner()
    }
    
    @objc private func handleError(notification: NSNotification){
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc private func paidPendingDue(notification: NSNotification){
        let pendingDue = (pendingDueViewModel.pendingDue?.dueAmount ?? 0) - (pendingDueViewModel.pendingDue?.paidAmount ?? 0)
        if pendingDue > 0{
           prepareView()
        }else{
            closeView()
        }
    }
    
    @objc func backgroundTapped(_ sender :UITapGestureRecognizer){
        closeView()
    }
    private func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    //MARK: Actions
    @IBAction func payNowTapped(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("payDueTapped")
        checkWalletAndBalanceToPayDue()
    }
    
    func checkWalletAndBalanceToPayDue(){
        let pendingDueAmount = (pendingDueViewModel.pendingDue?.dueAmount ?? 0) - (pendingDueViewModel.pendingDue?.paidAmount ?? 0)
        if pendingDueViewModel.userBalance >= pendingDueAmount{
            pendingDueViewModel.payPendingDue(paymentType: AccountTransaction.TRANSACTION_WALLET_TYPE_INAPP)
        }else if let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet(){
            if (linkedWallet.balance ?? 0) >= pendingDueAmount{
                pendingDueViewModel.payPendingDue(paymentType: linkedWallet.type)
            }else if linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY{
                let addMoneyViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
                addMoneyViewController.initializeView(errorMsg: Strings.low_balance){ (result) in
                    if result == .addMoney {
                        self.pendingDueViewModel.payPendingDue(paymentType: linkedWallet.type)
                    }else if result == .changePayment {
                        self.showPaymentDrawer()
                    }
                }
                ViewControllerUtils.addSubView(viewControllerToDisplay: addMoneyViewController)
            }else{
                pendingDueViewModel.payPendingDue(paymentType: linkedWallet.type)
            }
        }else{
            AccountUtils().addLinkWalletSuggestionAlert(title: nil, message: nil, viewController: self){ (walletAdded, walletType) in
                if walletAdded{
                    self.pendingDueViewModel.payPendingDue(paymentType: walletType)
                }
            }
        }
    }
    
    private func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: false) {(data) in
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }
    
    
    @IBAction func contactCustomerTapped(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("callSupportTapped")
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        AppUtilConnect.callSupportNumber(phoneNumber: "\(clientConfiguration.callQuickRideForSupport)".components(separatedBy: ".")[0], targetViewController: self)
    }
}

