//
//  PayTaxiAmountTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 10/10/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class PayTaxiAmountTableViewCell: UITableViewCell {

    
    @IBOutlet weak var walletImage: UIImageView!
    @IBOutlet weak var walletTypeLabel: UILabel!
    @IBOutlet weak var walletBalanceLabel: UILabel!
    @IBOutlet weak var payNowButton: QRCustomButton!
    @IBOutlet weak var addMoneyButton: QRCustomButton!
    @IBOutlet weak var lowBalanceLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var walletAndBalanceStackView: UIStackView!
    @IBOutlet weak var expiredTag: UILabel!
    @IBOutlet weak var relinkButton: QRCustomButton!
    @IBOutlet weak var rideFareContainerView: UIView!
    @IBOutlet weak var rideFareLabel: UILabel!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var changePaymentButton: UIButton!
    @IBOutlet weak var changePaymentMethodButton: UIButton!
    
    private var actionComplitionHandler: actionComplitionHandler?
    private var viewModel = TaxiPoolLiveRideViewModel()
    
    func initialisePaymentDetails(viewModel: TaxiPoolLiveRideViewModel, isFromBottomDrawer: Bool, actionComplitionHandler: actionComplitionHandler?){
        self.viewModel = viewModel
        self.viewModel.paymentMode = viewModel.getTaxiRidePassenger()?.paymentMode
        self.actionComplitionHandler = actionComplitionHandler
        showWalletAndPayingOption()
        if isFromBottomDrawer {
            changePaymentMethodButton.isUserInteractionEnabled = true
            rideFareContainerView.isHidden = false
            informationView.isHidden = true
            changePaymentButton.isHidden = true
            if let pendingAmount = viewModel.outstationTaxiFareDetails?.pendingAmount, pendingAmount > 0 {
                rideFareLabel.text = String(format: Strings.points_with_rupee_symbol, arguments: [StringUtils.getStringFromDouble(decimalNumber: pendingAmount)])
            }else {
                rideFareContainerView.isHidden = true
            }
        }else {
            changePaymentMethodButton.isUserInteractionEnabled = false
            rideFareContainerView.isHidden = true
            informationView.isHidden = false
            changePaymentButton.isHidden = false
        }
    }
    
    private  func showBalance(){
        walletBalanceLabel.isHidden = false
        if let linkedWalletBalance = viewModel.linkedWalletBalance {
            walletBalanceLabel.text = String(linkedWalletBalance.balance)
            let account = UserDataCache.getInstance()?.userAccount
            let remainingBalance = (account?.balance ?? 0)  - (account?.reserved ?? 0)
            let taxiFare = (viewModel.outstationTaxiFareDetails?.initialFare ?? 0) - (viewModel.outstationTaxiFareDetails?.couponBenefit ?? 0)
            if (linkedWalletBalance.balance + remainingBalance) <  taxiFare && (linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM || linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK || linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE || linkedWalletBalance.type == AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY){
                addMoneyButton.isHidden = false
                payNowButton.isHidden = true
                lowBalanceLabel.isHidden = true
            }else{
                payNowButton.isHidden = false
                lowBalanceLabel.isHidden = true
                addMoneyButton.isHidden = true
            }
        }else if let balance  = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.balance {
            walletBalanceLabel.text = StringUtils.getStringFromDouble(decimalNumber: balance)
        }else {
            getBalance()
        }
        
    }
   
    private func showLOTAnimation(isShow: Bool) {
        if isShow {
            animationView.isHidden = false
            animationView.animation = Animation.named("simple-dot-loader")
            animationView.play()
            animationView.loopMode = .loop
            lowBalanceLabel.isHidden = true
            addMoneyButton.isHidden = true
            payNowButton.isHidden = true
            walletAndBalanceStackView.isHidden = true
        } else {
            animationView.isHidden = true
            animationView.stop()
            walletAndBalanceStackView.isHidden = false
        }
    }

    private func checkWalletTypeAndExpiredity(linkedWallet: LinkedWallet){
        setTitleAndImage(type: linkedWallet.type ?? "")
        if linkedWallet.status == LinkedWallet.EXPIRED{
            walletBalanceLabel.isHidden = true
            addMoneyButton.isHidden = true
            payNowButton.isHidden = true
            expiredTag.isHidden = false
            relinkButton.isHidden = false
        }else if linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY || linkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL{
            lowBalanceLabel.isHidden = true
            walletBalanceLabel.isHidden = true
            addMoneyButton.isHidden = true
            expiredTag.isHidden = true
            relinkButton.isHidden = true
            payNowButton.isHidden = false
        }else{
            expiredTag.isHidden = true
            relinkButton.isHidden = true
            showBalance()
        }
    }
    
    private func showWalletAndPayingOption(){
        showLOTAnimation(isShow: false)
        if viewModel.paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH {
            walletAndBalanceStackView.isHidden = false
            walletImage.image = UIImage(named: "payment_type_cash")
            walletBalanceLabel.isHidden = true
            walletTypeLabel.text = Strings.payment_type_cash
            expiredTag.isHidden = true
            payNowButton.isHidden = true
            relinkButton.isHidden = true
            addMoneyButton.isHidden = true
            return
        }
      
        if let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet(){
            checkWalletTypeAndExpiredity(linkedWallet: linkedWallet)
        }else{
            walletImage.image = UIImage(named: "qr_wallet")
            walletBalanceLabel.isHidden = false
            walletTypeLabel.text = Strings.quickride_wallet
            let account = UserDataCache.getInstance()?.userAccount
            walletBalanceLabel.text = StringUtils.getStringFromDouble(decimalNumber: account?.balance)
            addMoneyButton.isHidden = true
            guard let accountbalance = account?.balance, let outstationTaxiFareDetails = viewModel.outstationTaxiFareDetails else { return  }
            if accountbalance > (outstationTaxiFareDetails.initialFare  - outstationTaxiFareDetails.couponBenefit){
                payNowButton.isHidden = false
            }
        }
    }
    

    private func setTitleAndImage(type: String) {
        switch type {
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            walletImage.image = UIImage(named: "paytm_new")
            walletTypeLabel.text = Strings.paytm_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            walletImage.image = UIImage(named: "lazypay_logo")
            walletTypeLabel.text = Strings.lazyPay_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            walletImage.image = UIImage(named: "simpl_new")
            walletTypeLabel.text = Strings.simpl_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            walletImage.image = UIImage(named: "tmw_new")
            walletTypeLabel.text = Strings.tmw
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            walletImage.image = UIImage(named: "mobikwik_logo")
            walletTypeLabel.text = Strings.mobikwik_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            walletImage.image = UIImage(named: "frecharge_logo")
            walletTypeLabel.text = Strings.frecharge_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            walletImage.image = UIImage(named : "apay_linked_wallet")
            walletTypeLabel.text = Strings.amazon_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            walletImage.image = UIImage(named : "upi")
            walletTypeLabel.text = Strings.upi
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            walletImage.image = UIImage(named : "gpay_icon_with_border")
            walletTypeLabel.text = Strings.gpay
        default:
            walletImage.isHidden = true
            walletTypeLabel.text = ""
        }
    }
    

    @IBAction func payNowTapped(_ sender: Any) {
        NotificationCenter.default.post(name: .payTaxiPendingBill, object: nil)
    }

    @IBAction func addMoneyButtonTapped(_ sender: Any){
        let linkedWalletAddMoneyViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
        linkedWalletAddMoneyViewController.initializeView(errorMsg: "") { [weak self] (data) in
            if data == .addMoney {
                self?.getBalance()
            }else if data == .changePayment {
                self?.showPaymentDrawer()
            }else{
                self?.showWalletAndPayingOption()
                NotificationCenter.default.post(name: .updatePaymentView, object: nil)
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: linkedWalletAddMoneyViewController)
    }

    
    
    @IBAction func changePaymentButtonTapped(_ sender: Any) {
        showPaymentDrawer()
        
    }
    @IBAction func showFareBreakupTapped(_ sender: Any) {
        if let actionComplitionHandler = actionComplitionHandler {
            actionComplitionHandler(true)
        }
    }
    
    private func showPaymentDrawer(){
        let setPaymentMethodViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SetPaymentMethodViewController") as! SetPaymentMethodViewController
        var isDefaultPaymentModeCash = false
        if let paymentMode = viewModel.paymentMode, paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH{
            isDefaultPaymentModeCash = true
        }
        setPaymentMethodViewController.initialiseData(isDefaultPaymentModeCash: isDefaultPaymentModeCash, isRequiredToShowCash: true, isRequiredToShowCCDC: true) {(data) in
            var params = [String: String]()
            if let  taxiRidePassenger = self.viewModel.taxiRidePassengerDetails?.taxiRidePassenger {
                params["userId"] = String(UserDataCache.getCurrentUserId())
                params["taxiPassengerId"] = String(taxiRidePassenger.id ?? 0);
                params["tripType"] = taxiRidePassenger.tripType
                params["fromAddress"] = taxiRidePassenger.startAddress ?? ""
                params["toAddress"] = taxiRidePassenger.endAddress ?? ""
                params["startTime"] = DateUtils.getTimeStringFromTimeInMillis(timeStamp: taxiRidePassenger.startTimeMs, timeFormat: DateUtils.DATE_FORMAT_YYYY_MM_DD_HH_SS)
                params["shareType"] = taxiRidePassenger.shareType
            }
            if data == .cashSelected {
                params["paymentMode"] = TaxiRidePassenger.PAYMENT_MODE_CASH
            }else{
                params["paymentMode"] = TaxiRidePassenger.PAYMENT_MODE_ONLINE
                params["paymentType"] = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type ?? ""
            }
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.qrTaxiPaymentMode, params: params, uniqueField: User.FLD_USER_ID)
        
            if data == .cashSelected {
                self.viewModel.paymentMode = TaxiRidePassenger.PAYMENT_MODE_CASH
            }else if data == .ccdcSelected {
                self.displayPayByOtherModes()
                self.viewModel.paymentMode = nil
                self.getBalance()
            }else {
                self.viewModel.paymentMode = nil
                self.getBalance()
            }
            self.changePaymentMode()
            self.showWalletAndPayingOption()
            NotificationCenter.default.post(name: .updatePaymentView, object: nil)
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: setPaymentMethodViewController)
    }

    private func displayPayByOtherModes(){
        guard let taxiRidePassengerId = viewModel.taxiRidePassengerDetails?.taxiRidePassenger?.id else {
            return
        }
        TaxiPoolRestClient.getPaymentLinkForPayment(taxiRidePassengerId: taxiRidePassengerId) { responseObject, error in
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
                        ViewControllerUtils.displayViewController(currentViewController: self.parentViewController, viewControllerToBeDisplayed: webViewController, animated: false)
                    } else {
                        UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
                    }
                }
            }
        }
    }
    

    @IBAction func relinkButtonTapped(_ sender: Any) {
        guard let linkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet() else { return }
        AccountUtils().linkRequestedWallet(walletType: linkedWallet.type ?? "") { [weak self] (walletAdded, walletType) in
            if walletAdded{
                self?.getBalance()
                self?.showWalletAndPayingOption()
                NotificationCenter.default.post(name: .updatePaymentView, object: nil)
            }
        }
    }
    private func getBalance(){
        showLOTAnimation(isShow: true)
        walletBalanceLabel.isHidden = true
        viewModel.getBalanceOfLinkedWallet(complitionHandler: { [weak self](result) in
            self?.showLOTAnimation(isShow: false)
            if result{
                self?.showBalance()
            }
        })
    }
    private func changePaymentMode(){
        var selectedPaymentType = ""
        if let paymentMode = viewModel.paymentMode, paymentMode == TaxiRidePassenger.PAYMENT_MODE_CASH{
            selectedPaymentType = paymentMode
        }else{
            selectedPaymentType = UserDataCache.getInstance()?.getDefaultLinkedWallet()?.type ?? ""
            viewModel.paymentMode = TaxiRidePassenger.PAYMENT_MODE_ONLINE
        }
        viewModel.chandePaymentMode(paymentType: selectedPaymentType)
    }
    
}
