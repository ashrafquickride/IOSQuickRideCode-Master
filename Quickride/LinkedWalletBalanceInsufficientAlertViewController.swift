//
//  LinkedWalletBalanceInsufficientAlertViewController.swift
//  Quickride
//
//  Created by iDisha on 23/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias insufficientBalanceCompletionHandler = (_ action : String?) -> Void

class LinkedWalletBalanceInsufficientAlertViewController: ModelViewController, UITableViewDelegate,UITableViewDataSource,LinkedWalletUpdateDelegate{
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var labelWalletType: UILabel!
    
    @IBOutlet weak var labelBalance: UILabel!
    
    @IBOutlet weak var imageViewLinkedWallet: UIImageView!
    
    @IBOutlet weak var actionBtn: UIButton!
    
    @IBOutlet weak var messageLbnTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var linkedWalletTableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var linkedWalletTableView: UITableView!
    
    @IBOutlet weak var seperatorView: UIView!
    
    private var handler : insufficientBalanceCompletionHandler?
    private var titleString : String?
    private var isLazyPayEligible : Bool?
    private var linkedWallets = [LinkedWallet]()
    
    func initializeView(titleString: String, handler: @escaping insufficientBalanceCompletionHandler){
        self.handler = handler
        self.titleString = titleString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleString
        for linkedWallet in UserDataCache.getInstance()!.getAllLinkedWallets(){
            if linkedWallet.defaultWallet{
                continue
            }
            linkedWallets.append(linkedWallet)
        }
        if !linkedWallets.isEmpty{
            linkedWalletTableView.isHidden = false
            linkedWalletTableViewHeightConstraint.constant = CGFloat(self.linkedWallets.count * 85)
            seperatorView.isHidden = false
            linkedWalletTableView.register(UINib(nibName: "LinkedWalletXibTableViewCell", bundle: nil), forCellReuseIdentifier: "LinkedWalletXibTableViewCell")
        }
        else{
            seperatorView.isHidden = true
            linkedWalletTableView.isHidden = true
            linkedWalletTableViewHeightConstraint.constant = 0
        }
        setDataBasedOnLinkedWallet()
        if titleString == Strings.wallet_expired{
            labelWalletType.text = Strings.expired_caps
            labelWalletType.font = UIFont(name: "HelveticaNeue-Medium",size: 15.0)
            labelWalletType.textColor = UIColor(netHex: 0xFF0000)
            actionBtn.isHidden = false
        }else{
            self.labelBalance.isHidden = true
            var linkedWalletTypes = [String]()
            let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
            for linkedWallet in UserDataCache.getInstance()!.getAllLinkedWallets(){
                if clientConfiguration.availablePayLaterOptions.contains(linkedWallet.type!) || clientConfiguration.availableUpiOptions.contains(linkedWallet.type!){
                    continue
                }
                linkedWalletTypes.append(linkedWallet.type!)
            }
            let linkedWalletTypesInString = linkedWalletTypes.joined(separator: ",")
            AccountRestClient.getLinkedWalletBalancesOfUser(userId: QRSessionManager.getInstance()!.getUserId(), types: linkedWalletTypesInString, viewController: self, handler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let linkedWalletBalances = Mapper<LinkedWalletBalance>().mapArray(JSONObject: responseObject!["resultData"])!
                    for linkedWalletBalance in linkedWalletBalances{
                        if linkedWalletBalance.type == UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type{
                            self.labelBalance.isHidden = false
                            self.labelBalance.text = StringUtils.getPointsInDecimal(points: linkedWalletBalance.balance)
                            break
                        }
                    }
                    for linkedWallet in self.linkedWallets{
                        if clientConfiguration.availablePayLaterOptions.contains(linkedWallet.type!) || clientConfiguration.availableUpiOptions.contains(linkedWallet.type!){
                            continue
                        }
                        for linkedWalletBalance in linkedWalletBalances{
                            if linkedWallet.type == linkedWalletBalance.type{
                                linkedWallet.balance = linkedWalletBalance.balance
                                break
                            }
                        }
                    }
                    self.linkedWalletTableView.reloadData()
                }
            })
            actionBtn.isHidden = true
        }
    }
    
    private func setDataBasedOnLinkedWallet(){
        if let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet(){
            if titleString == Strings.wallet_expired{
                messageLbnTopConstraint.constant = 0
                messageLabel.isHidden = true
            }else{
                messageLabel.isHidden = false
                messageLbnTopConstraint.constant = 25
            }
            switch linkedWallet.type {
            case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
                labelWalletType.text = Strings.paytm_wallet
                imageViewLinkedWallet.image = UIImage(named: "paytm_new")
                messageLabel.text = String(format: Strings.recharge_or_change_payment_mode, arguments: [Strings.tmw_wallet])
            case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
                labelWalletType.text = Strings.tmw_wallet
                imageViewLinkedWallet.image = UIImage(named: "tmw_new")
                messageLabel.text = String(format: Strings.recharge_or_change_payment_mode, arguments: [Strings.tmw_wallet])
            case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
                labelWalletType.text = Strings.simpl_Wallet
                imageViewLinkedWallet.image = UIImage(named: "simpl_new")
                messageLabel.text = String(format: Strings.recharge_or_change_payment_mode, arguments: [Strings.lazyPay_wallet])
            case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
                labelWalletType.text = Strings.lazyPay_wallet
                imageViewLinkedWallet.image = UIImage(named: "lazypay_logo")
                messageLabel.text = String(format: Strings.recharge_or_change_payment_mode, arguments: [Strings.lazyPay_wallet])
            case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
                labelWalletType.text = Strings.amazon_Wallet
                imageViewLinkedWallet.image = UIImage(named: "amazon_pay")
                messageLabel.text = String(format: Strings.recharge_or_change_payment_mode, arguments: [Strings.amazon_Wallet])
            case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
                labelWalletType.text = Strings.mobikwik_wallet
                imageViewLinkedWallet.image = UIImage(named: "mobikwik_logo")
                messageLabel.text = String(format: Strings.recharge_or_change_payment_mode, arguments: [Strings.mobikwik_wallet])
            case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
                labelWalletType.text = Strings.frecharge_wallet
                imageViewLinkedWallet.image = UIImage(named: "frecharge_logo")
                messageLabel.text = String(format: Strings.recharge_or_change_payment_mode, arguments: [Strings.frecharge_wallet])
            default:
                labelWalletType.text = ""
                imageViewLinkedWallet.image = nil
                messageLabel.text = ""
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return linkedWallets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkedWalletXibTableViewCell", for: indexPath as  IndexPath) as! LinkedWalletXibTableViewCell
        if linkedWallets.endIndex <= indexPath.row{
            return cell
        }
        cell.tag = 1
        cell.initializeDataInCell(linkedWallet: linkedWallets[indexPath.row],showSelectButton: false, viewController: self, listener: self)
        if indexPath.row == linkedWallets.endIndex - 1{
            cell.separatorView.isHidden = true
        }else{
            cell.separatorView.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if let cell = tableView.cellForRow(at: indexPath) as? LinkedWalletXibTableViewCell{
            cell.updateDefaultLinkedWallet()
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func linkedWalletInfoChanged(){
        removeViewController(action: nil)
    }
    
    @IBAction func btnActionTapped(_ sender: Any?){
        removeViewController(action: actionBtn.titleLabel?.text)
    }
    
    @IBAction func closeBtnTapped(_ sender: Any?) {
        removeViewController(action: Strings.cancel_caps)
    }
    
    @IBAction func changePaymentModeTapped(_ sender: Any) {
        removeViewController(action: Strings.change_paymet_mode)
    }
    
    private func removeViewController(action: String?){
        handler?(action)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
