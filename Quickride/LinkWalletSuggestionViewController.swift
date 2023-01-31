//
//  LinkWalletSuggestionViewController.swift
//  Quickride
//
//  Created by Halesh on 30/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
typealias walletSelectionTypeAndActionCompletionHandler = (_ action : String?, _ walletType : String?) -> Void

class LinkWalletSuggestionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource,LinkWalletReceiver{
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var seperatorView: UIView!
    
    @IBOutlet weak var backButtonBottomSpaceConstraint: NSLayoutConstraint!
    
    private var handler : walletSelectionTypeAndActionCompletionHandler?
    private var titleString : String?
    private var message : String?
    private var isLazyPayEligible : Bool?
    private var linkedWalletList = [String]()
    
    func initializeView(titleString: String?, message: String?, handler: @escaping walletSelectionTypeAndActionCompletionHandler){
        self.handler = handler
        self.titleString = titleString
        self.message = message
    }
    override func viewDidLoad() {
        definesPresentationContext = true
        if titleString == nil{
            titleLabel.isHidden = true
            seperatorView.isHidden = true
            backButtonBottomSpaceConstraint.constant = 0
        } else {
            titleLabel.isHidden = false
            seperatorView.isHidden = false
            backButtonBottomSpaceConstraint.constant = 20
            titleLabel.text = titleString
        }
        var rechargeLinkedWallet = [String]()
        var redemptionLinkedWallet = [String]()
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        for linkWallet in AccountUtils().checkAvailableRechargeWalletsValidOrNot(linkWallets: clientConfiguration.availablePayLaterOptions){
            rechargeLinkedWallet.append(linkWallet)
        }
        for linkWallet in AccountUtils().checkAvailableRechargeWalletsValidOrNot(linkWallets: clientConfiguration.availableWalletOptions){
            if rechargeLinkedWallet.contains(linkWallet){
                continue
            }
            rechargeLinkedWallet.append(linkWallet)
        }
        redemptionLinkedWallet = AccountUtils().checkAvailableRedemptionWalletsValidOrNot(linkWallets: clientConfiguration.availableRedemptionWalletOptions)
        if titleString == Strings.redeem_title{
            linkedWalletList = redemptionLinkedWallet
        }
        else{
            linkedWalletList = rechargeLinkedWallet
            let upiWalletOptions = AccountUtils().checkAvailableUPIWalletValidOrNot(linkWallets: clientConfiguration.availableUpiOptions)
            
            for upiWallet in upiWalletOptions{
                linkedWalletList.append(upiWallet)
            }
        }
        
        tableViewHeightConstraint.constant = CGFloat(linkedWalletList.count*85)
        if linkedWalletList.isEmpty{
            self.tableView.isHidden = true
        }else{
            tableView.register(UINib(nibName: "AllLinkWalletXibTableViewCell", bundle: nil), forCellReuseIdentifier: "AllLinkWalletXibTableViewCell")
            self.tableView.isHidden = false
            self.tableView.delegate = self
            self.tableView.dataSource = self
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(false)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkedWalletList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllLinkWalletXibTableViewCell", for: indexPath as  IndexPath) as! AllLinkWalletXibTableViewCell
        if linkedWalletList.endIndex <= indexPath.row{
            return cell
        }
        cell.linkButton.tag = 1
        if titleString == Strings.redeem_title{
            cell.initializeDataInCell(walletType: linkedWalletList[indexPath.row], isRedemptionLinkWallet: true, viewController: self,linkWalletReceiver: self)
        }
        else{
            cell.initializeDataInCell(walletType: linkedWalletList[indexPath.row],  isRedemptionLinkWallet: false, viewController: self,linkWalletReceiver: self)
        }
        
        return cell
    }
    
    func linkWallet(walletType: String){
        var linkedWalletType = walletType
        if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
            linkedWalletType = EncashPaymentViewController.ENCASH_TYPE_LINKED_PAYTM
        }
        else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_TMW{
            linkedWalletType = EncashPaymentViewController.ENCASH_TYPE_LINKED_TMW
        }
        self.navigationController?.popViewController(animated: false)
        handler!(Strings.link_caps, linkedWalletType)
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any?) {
        self.navigationController?.popViewController(animated: false)
        handler!(Strings.cancel_caps, nil)
    }
}
