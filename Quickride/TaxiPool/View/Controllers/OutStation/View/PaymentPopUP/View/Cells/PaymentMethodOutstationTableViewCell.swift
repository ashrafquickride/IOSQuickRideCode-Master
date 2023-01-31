//
//  PaymentMethodOutstationTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 02/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper
import Lottie

protocol PaymentMethodOutstationTableViewCellDelegate {
    func updateUI()
}

class PaymentMethodOutstationTableViewCell: UITableViewCell {
    @IBOutlet weak var walletTypeimageView: UIImageView!
    @IBOutlet weak var walletTypeTextShowingLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var insufficientLabel: UILabel!
    @IBOutlet weak var addMoneyButton: UIButton!
    @IBOutlet weak var changePaymentMethodButton: UIButton!
    @IBOutlet weak var loadingAnimationView: AnimatedControl!
    
    private var estimateFare = 0.0
    private var lowBalanceFare = 100.0
    private var delegate: PaymentMethodOutstationTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func getEstimateFare(estimateFare: Double,delegate: PaymentMethodOutstationTableViewCellDelegate) {
        self.estimateFare = estimateFare
        self.delegate = delegate
        getDefaultLinkedWalletBalance()
    }
    
    @IBAction func addMoneyBtnPressed(_ sender: UIButton) {
        let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if linkedWallet?.status == LinkedWallet.EXPIRED{
            relinkSelectedLinkedWallet(walletType: linkedWallet?.type ?? "")
        }else{
            let linkedWalletAddMoneyViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
            linkedWalletAddMoneyViewController.initializeView(errorMsg: "") { [weak self] (data) in
                if data == .changePayment {
                    self?.showPaymentDrawer()
                }else {
                    self?.delegate?.updateUI()
                }
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: linkedWalletAddMoneyViewController)
        }
    }
    
    private func relinkSelectedLinkedWallet(walletType: String) {
        AccountUtils().linkRequestedWallet(walletType: walletType) { (walletAdded, walletType) in
            if walletAdded{
                self.getDefaultLinkedWalletBalance()
            }
        }
    }
    
    @IBAction func changePaymentMethodBtnPressed(_ sender: UIButton) {
        showPaymentDrawer()
    }
    
    private func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: false) {(data) in
            self.getDefaultLinkedWalletBalance()
            self.delegate?.updateUI()
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }
    
    private func getDefaultLinkedWalletBalance() {
        guard let defaultLinkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet() else {return}
        showLOTAnimation(isShow: true)
        AccountRestClient.getLinkedWalletBalancesOfUser(userId: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getCurrentUserId()), types: defaultLinkedWallet.type!,viewController: parentViewController, handler: { [weak self] (responseObject, error) in
            self?.showLOTAnimation(isShow: false)
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let linkedWalletBalances = Mapper<LinkedWalletBalance>().mapArray(JSONObject: responseObject!["resultData"])!
                for linkedWalletBalance in linkedWalletBalances {
                    if linkedWalletBalance.type == defaultLinkedWallet.type {
                        UserDataCache.getInstance()?.getDefaultLinkedWallet()?.balance = linkedWalletBalance.balance
                        self?.setupDefaultPaymentMethod(linkedWalletBalance: linkedWalletBalance)
                        break
                    }
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self?.parentViewController, handler: nil)
            }
        })
    }
    
    private func showLOTAnimation(isShow: Bool) {
        if isShow {
            walletTypeimageView.isHidden = true
            walletTypeTextShowingLabel.isHidden = true
            amountLabel.isHidden = true
            insufficientLabel.isHidden = true
            loadingAnimationView.isHidden = false
            loadingAnimationView.animationView.animation = Animation.named("simple-dot-loader")
            loadingAnimationView.animationView.play()
            loadingAnimationView.animationView.loopMode = .loop
        } else {
            loadingAnimationView.isHidden = true
            loadingAnimationView.animationView.stop()
            walletTypeimageView.isHidden = false
            walletTypeTextShowingLabel.isHidden = false
            amountLabel.isHidden = false
        }
    }
    
    private func setupDefaultPaymentMethod(linkedWalletBalance : LinkedWalletBalance) {
        amountLabel.isHidden = false
        amountLabel.text = StringUtils.getPointsInDecimal(points: linkedWalletBalance.balance)
        
        if let outStationTaxiAdvancePaymentPercentage = ConfigurationCache.getInstance()?.getClientConfiguration()?.outStationTaxiAdvancePaymentPercentage {
            lowBalanceFare = (estimateFare*Double(outStationTaxiAdvancePaymentPercentage)/100)
        }
        
        if linkedWalletBalance.balance < lowBalanceFare.roundToPlaces(places: 2) {
            insufficientLabel.isHidden = false
        } else {
            insufficientLabel.isHidden = true
        }
        setTitleAndImage(type: linkedWalletBalance.type!)
        if linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM ||
            linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK ||
            linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE ||
            linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY {
            
            if linkedWalletBalance.expired! {
                addMoneyButton.setTitle(Strings.relink, for: .normal)
            }else{
                addMoneyButton.setTitle(Strings.add_money, for: .normal)
            }
            addMoneyButton.isHidden = false
        } else {
            addMoneyButton.isHidden = true
            insufficientLabel.isHidden = true
        }
        if linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE || linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI {
            amountLabel.isHidden = true
        }
    }
    
    private func setTitleAndImage(type: String) {
        switch type {
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            walletTypeimageView.image = UIImage(named: "paytm_new")
            walletTypeTextShowingLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.paytm_wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            walletTypeimageView.image = UIImage(named: "lazypay_logo")
            walletTypeTextShowingLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.lazyPay_wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            walletTypeimageView.image = UIImage(named: "simpl_new")
            walletTypeTextShowingLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.simpl_Wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            walletTypeimageView.image = UIImage(named: "tmw_new")
            walletTypeTextShowingLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.tmw])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            walletTypeimageView.image = UIImage(named: "mobikwik_logo")
            walletTypeTextShowingLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.mobikwik_wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            walletTypeimageView.image = UIImage(named: "frecharge_logo")
            walletTypeTextShowingLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.frecharge_wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            walletTypeimageView.image = UIImage(named : "apay_linked_wallet")
            walletTypeTextShowingLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.amazon_Wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            walletTypeimageView.image = UIImage(named : "upi")
            walletTypeTextShowingLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.upi])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            walletTypeimageView.image = UIImage(named : "gpay_icon_with_border")
            walletTypeTextShowingLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.gpay])
        default:
            walletTypeimageView.isHidden = true
            walletTypeTextShowingLabel.text = ""
        }
    }
}
