//
//  DriverBookingViewController.swift
//  Quickride
//
//  Created by Ashutos on 01/01/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

typealias DriverBookingSucessHandler = (_ data: Bool) -> Void

class DriverBookingViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    
    @IBOutlet weak var amountShowingLabel: UILabel!
    @IBOutlet weak var paymentTitleLabel: UILabel!
    
    @IBOutlet weak var walletDetailsView: UIView!
    @IBOutlet weak var walletImageView: UIImageView!
    @IBOutlet weak var walletTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var walletLoadingView: AnimatedControl!
    @IBOutlet weak var addMoneyBtn: UIButton!
    @IBOutlet weak var shallBeAvialableLabel: UILabel!
    
    @IBOutlet weak var addPaymentMethodView: UIView!
    
    @IBOutlet weak var paymentButton: UIButton!
    
    @IBOutlet weak var walletHeightConstraint: NSLayoutConstraint!
    
    
    private var driverBookingVM: DriverBookingViewModel?
    private var handler : DriverBookingSucessHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        // Do any additional setup after loading the view.
    }
    
    func initialiseData(startLocation: Location, endLocation: Location,journeyType:String,vehicleType: String,startTime: Double,complitionHandler: DriverBookingSucessHandler?) {
        driverBookingVM = DriverBookingViewModel(startLocation: startLocation, endLocation: endLocation, journeyType: journeyType, vehicleType: vehicleType,startTime: startTime)
        self.handler = complitionHandler
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func setUpUI() {
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        let minDriverBookAmount = ConfigurationCache.getObjectClientConfiguration().driverAdvanceBookingAmount
        amountShowingLabel.text = "₹ \(Int(minDriverBookAmount))"
        if driverBookingVM?.isWalletLinkedOrQrAccountHasBalance() ?? false {
            if UserDataCache.getInstance()?.getDefaultLinkedWallet() != nil{
                setUpUIForWalletDetails()
                paymentTitleLabel.text = Strings.payment_method_caps.capitalizingFirstLetter()
                walletHeightConstraint.constant = 90
                walletDetailsView.isHidden = false
                addPaymentMethodView.isHidden = true
            }else{
                paymentTitleLabel.text = ""
                walletHeightConstraint.constant = 50
                walletDetailsView.isHidden = true
                addPaymentMethodView.isHidden = false
            }
            paymentButton.isUserInteractionEnabled = true
            paymentButton.backgroundColor = UIColor(netHex: 0x00B557)
        }else{
            paymentButton.isUserInteractionEnabled = false
            paymentButton.backgroundColor = UIColor(netHex: 0xA5A5A5)
        }
    }
    
    @IBAction func payNowBtnPressed(_ sender: UIButton) {
        QuickRideProgressSpinner.startSpinner()
        driverBookingVM?.bookDriver(completionHandler: {[weak self] (data) in
            QuickRideProgressSpinner.stopSpinner()
            if data {
                self?.removeView()
                self?.handler?(true)
            }
        })
    }
    
    @IBAction func addMoneyButtonPressed(_ sender: UIButton) {
        let linkedWalletAddMoneyViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
        linkedWalletAddMoneyViewController.initializeView(errorMsg: "") { [weak self] (data) in
            if data == .changePayment {
                self?.showPaymentDrawer()
            }
            self?.setUpUI()
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: linkedWalletAddMoneyViewController)
    }
    
    @IBAction func changeWalletBtnPressed(_ sender: UIButton) {
        showPaymentDrawer()
    }
    
    private func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: false, isRequiredToShowCash: false, isRequiredToShowCCDC: false) {(data) in
            self.setUpUI()
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }
    
    @IBAction func addPaymentMethodBtnPressed(_ sender: UIButton) {
        AccountUtils().addLinkWalletSuggestionAlert(title: nil, message: nil, viewController: self) { [weak self] (walletAdded, walletType) in
            if walletAdded {
                self?.setUpUI()
            }
        }
    }
    
    @objc private func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        removeView()
    }
    
    private func removeView() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

//MARK: Wallet Details UI setUP
extension DriverBookingViewController {
    private func setUpUIForWalletDetails() {
        guard let walletType = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type else {return}
        showLOTAnimation(isShow: true)
        driverBookingVM?.getDefaultLinkedWalletBalance(walletType: walletType, completionHandler: {[weak self] (data) in
            self?.showLOTAnimation(isShow: false)
            if data {
                for linkedWalletBalance in self?.driverBookingVM?.linkedWalletBalances ?? [] {
                    if linkedWalletBalance?.type == walletType {
                        guard let linkedWalletBalance = linkedWalletBalance else{ return }
                        self?.setupDefaultPaymentMethod(linkedWalletBalance: linkedWalletBalance)
                        break
                    }
                }
            }
        })
    }
    
    private func showLOTAnimation(isShow: Bool) {
        if isShow {
            walletImageView.isHidden = true
            walletTypeLabel.isHidden = true
            priceLabel.isHidden = true
            walletLoadingView.isHidden = false
            walletLoadingView.animationView.animation = Animation.named("simple-dot-loader")
            walletLoadingView.animationView.play()
            walletLoadingView.animationView.loopMode = .loop
        } else {
            walletLoadingView.isHidden = true
            walletLoadingView.animationView.stop()
            walletImageView.isHidden = false
            walletTypeLabel.isHidden = false
            priceLabel.isHidden = false
        }
    }
    
    private func setupDefaultPaymentMethod(linkedWalletBalance : LinkedWalletBalance) {
        priceLabel.isHidden = false
        priceLabel.text = StringUtils.getPointsInDecimal(points: linkedWalletBalance.balance)
        setTitleAndImage(type: linkedWalletBalance.type!)
        if linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE || linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI {
            priceLabel.isHidden = true
            shallBeAvialableLabel.isHidden = false
            addMoneyBtn.isHidden = true
            paymentButton.isUserInteractionEnabled = false
            paymentButton.backgroundColor = UIColor(netHex: 0xA5A5A5)
        }else{
            priceLabel.isHidden = false
            shallBeAvialableLabel.isHidden = true
            addMoneyBtn.isHidden = false
            paymentButton.isUserInteractionEnabled = true
            paymentButton.backgroundColor = UIColor(netHex: 0x00B557)
        }
    }
    
    private func setTitleAndImage(type: String) {
        switch type {
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            walletImageView.image = UIImage(named: "paytm_new")
            walletTypeLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.paytm_wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            walletImageView.image = UIImage(named: "lazypay_logo")
            walletTypeLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.lazyPay_wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            walletImageView.image = UIImage(named: "simpl_new")
            walletTypeLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.simpl_Wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            walletImageView.image = UIImage(named: "tmw_new")
            walletTypeLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.tmw])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            walletImageView.image = UIImage(named: "mobikwik_logo")
            walletTypeLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.mobikwik_wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            walletImageView.image = UIImage(named: "frecharge_logo")
            walletTypeLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.frecharge_wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            walletImageView.image = UIImage(named : "apay_linked_wallet")
            walletTypeLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.amazon_Wallet])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            walletImageView.image = UIImage(named : "upi")
            walletTypeLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.upi])
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            walletImageView.image = UIImage(named : "gpay_icon_with_border")
            walletTypeLabel.text = String(format: Strings.wallet_balance, arguments: [Strings.gpay])
        default:
            walletImageView.isHidden = true
            walletTypeLabel.text = ""
        }
    }
}
