//
//  PaymentInfoCardTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 18/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import ObjectMapper

class PaymentInfoCardTableViewCell: UITableViewCell {

    //MARK: Outlets
    @IBOutlet weak var paymentHeadingLabel: UILabel!
    @IBOutlet weak var totalPointsLabel: UILabel!
    @IBOutlet weak var totalPointsLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ridePointsLabel: UILabel!
    @IBOutlet weak var defaultPaymentView: UIView!
    @IBOutlet weak var paymentImageView: UIImageView!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var lowBalanceLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var addMoneyButton: UIButton!
    @IBOutlet weak var addMoneyHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var defaultPaymentViewHeight: NSLayoutConstraint!
    //    //MARK: Apply coupon code view
//    @IBOutlet weak var applyCouponButton: UIButton!
//    @IBOutlet weak var applyCouponHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var couponAppliedView: UIView!
//    @IBOutlet weak var couponAppliedLabel: UILabel!
    @IBOutlet weak var passengerWalletView: UIView!
    @IBOutlet weak var riderWalletView: UIView!
    @IBOutlet weak var numberOfRideTakersLabel: UILabel!
    @IBOutlet weak var earnedWalletLabel: UILabel!
    @IBOutlet weak var earnedPointsLabel: UILabel!
    @IBOutlet weak var earnedWalletImage: UIImageView!
    
    
    
    //MARK: Properties
    private var rideObj: Ride?
    var ridePaymentDetails: RidePaymentDetails?
    weak var viewController: UIViewController?
    private var applyPromoCodeView : ApplyPromoCodeDialogueView?
    private var actionComplitionHandler: actionComplitionHandler?
    
    //MARK: Initializer
    func initializeData(rideObj: Ride, ridePaymentDetails: RidePaymentDetails?, viewController: UIViewController?, actionComplitionHandler: @escaping actionComplitionHandler) {
        self.ridePaymentDetails = ridePaymentDetails
        self.actionComplitionHandler = actionComplitionHandler
        self.rideObj = rideObj
        self.viewController = viewController
        updateUI()
    }
    
    //MARK: Methods
    private func updateUI() {
        if let passengerRide = rideObj as? PassengerRide {
            passengerWalletView.isHidden = false
            riderWalletView.isHidden = true
            if passengerRide.status == Ride.RIDE_STATUS_REQUESTED {
                paymentHeadingLabel.text = Strings.payment_method_caps
                totalPointsLabel.isHidden = true
                ridePointsLabel.isHidden = true
                totalPointsLabelHeightConstraint.constant = 0
            } else {
                paymentHeadingLabel.text = Strings.payment_caps
                totalPointsLabel.isHidden = false
                ridePointsLabel.isHidden = false
                totalPointsLabelHeightConstraint.constant = 27
                var points = 0.0
                if passengerRide.newFare > -1{
                    points = passengerRide.newFare
                }else{
                    points = passengerRide.points
                }
                self.ridePointsLabel.text = StringUtils.getStringFromDouble(decimalNumber: points)
            }
            balanceLabel.isHidden = true
            setTitleAndImage(type: ridePaymentDetails?.walletType ?? "")
        }else{
            passengerWalletView.isHidden = true
            riderWalletView.isHidden = false
            if let defaultLinkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet(),defaultLinkedWallet.type == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
                earnedWalletImage.image = UIImage(named: "paytm_new")
                earnedWalletLabel.text = Strings.paytm_wallet
                earnedPointsLabel.isHidden = true
                getDefaultLinkedWalletBalance()
            }else{
                earnedWalletImage.image = UIImage(named: "qr_wallet")
                earnedWalletLabel.text = Strings.quickride_wallet
                earnedPointsLabel.text = String(UserDataCache.getInstance()?.userAccount?.earnedPoints ?? 0)
            }
            if let riderRide = rideObj as? RiderRide, riderRide.noOfPassengers > 0 {
                if riderRide.noOfPassengers == 1{
                    numberOfRideTakersLabel.text = "\(riderRide.noOfPassengers ) Ride taker"
                }else{
                    numberOfRideTakersLabel.text = "\(riderRide.noOfPassengers) Ride takers"
                }
            }
        }
    }
    func getDefaultLinkedWalletBalance() {
        

        guard let defaultLinkedWallet = UserDataCache.getInstance()?.getDefaultLinkedWallet() else {
            self.defaultPaymentView.isHidden = true
            self.defaultPaymentViewHeight.constant = 0
            return
        }
        AccountRestClient.getLinkedWalletBalancesOfUser(userId: StringUtils.getStringFromDouble(decimalNumber: UserDataCache.getCurrentUserId()), types: defaultLinkedWallet.type!,viewController: viewController, handler: { (responseObject, error) in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let linkedWalletBalances = Mapper<LinkedWalletBalance>().mapArray(JSONObject: responseObject!["resultData"])!
                    for linkedWalletBalance in linkedWalletBalances {
                        if linkedWalletBalance.type == defaultLinkedWallet.type {
                            if self.rideObj?.rideType == Ride.PASSENGER_RIDE{
                                self.defaultPaymentView.isHidden = false
                                self.defaultPaymentViewHeight.constant = 72
                                self.setupDefaultPaymentMethod(linkedWalletBalance: linkedWalletBalance)
                                break
                            }else{
                                self.earnedPointsLabel.isHidden = false
                                self.earnedPointsLabel.text = StringUtils.getPointsInDecimal(points: linkedWalletBalance.balance)
                            }
                            
                        }
                    }
                }else{
                    self.defaultPaymentView.isHidden = true
                    self.defaultPaymentViewHeight.constant = 0
                }
            })
        }
    
    
    private func setupDefaultPaymentMethod(linkedWalletBalance : LinkedWalletBalance) {
        balanceLabel.isHidden = false
        balanceLabel.text = StringUtils.getPointsInDecimal(points: linkedWalletBalance.balance)
        if linkedWalletBalance.balance < 100 {
            lowBalanceLabel.isHidden = false
        } else {
            lowBalanceLabel.isHidden = true
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
            addMoneyHeightConstraint.constant = 30
            
        } else {
            addMoneyButton.isHidden = true
            addMoneyHeightConstraint.constant = 0
            lowBalanceLabel.isHidden = true
            balanceLabel.isHidden = true
        }
        
    }
    
    private func setTitleAndImage(type: String) {
        switch type {
        case AccountTransaction.TRANSACTION_WALLET_TYPE_INAPP:
            paymentImageView.image = UIImage(named : "qr_wallet")
            paymentMethodLabel.text = Strings.quickride_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM:
            paymentImageView.image = UIImage(named: "paytm_new")
            paymentMethodLabel.text = Strings.paytm_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY:
            paymentImageView.image = UIImage(named: "lazypay_logo")
            paymentMethodLabel.text = Strings.lazyPay_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_SIMPL:
            paymentImageView.image = UIImage(named: "simpl_new")
            paymentMethodLabel.text = Strings.simpl_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_TMW:
            paymentImageView.image = UIImage(named: "tmw_new")
            paymentMethodLabel.text = Strings.tmw
        case AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK:
            paymentImageView.image = UIImage(named: "mobikwik_logo")
            paymentMethodLabel.text = Strings.mobikwik_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE:
            paymentImageView.image = UIImage(named: "frecharge_logo")
            paymentMethodLabel.text = Strings.frecharge_wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_AMAZON_PAY:
            paymentImageView.image = UIImage(named : "apay_linked_wallet")
            paymentMethodLabel.text = Strings.amazon_Wallet
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI:
            paymentImageView.image = UIImage(named : "upi")
            paymentMethodLabel.text = Strings.upi
        case AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE:
            paymentImageView.image = UIImage(named : "gpay_icon_with_border")
            paymentMethodLabel.text = Strings.gpay
        default:
            paymentImageView.isHidden = true
            paymentMethodLabel.text = ""
        }
    }
    
    
    //MARK: Actions
    @IBAction func addMoneyTapped(_ sender: UIButton) {
        let linkedWalletAddMoneyViewController  = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AddMoneyViewController") as! AddMoneyViewController
        linkedWalletAddMoneyViewController.initializeView(errorMsg: "") { result in
            if result == .changePayment {
                if let actionComplitionHandler = self.actionComplitionHandler {
                    actionComplitionHandler(true)
                }
            }
        }
         ViewControllerUtils.addSubView(viewControllerToDisplay: linkedWalletAddMoneyViewController)
    }
    
    private func verifyPromoCode(promoCode : String) {
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.applyProcode(promoCode: promoCode ,userId: QRSessionManager.getInstance()?.getUserId() ?? "0", uiViewController: viewController, completionHandler: { [weak self] responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            guard let self = `self` else {
                return
            }
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                AppDelegate.getAppDelegate().log.debug("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
                //                self.ride!.promocode = promoCode
                self.applyPromoCodeView?.showPromoAppliedMessage(message: String(format: Strings.promo_code_applied, arguments: [promoCode]))
            } else if responseObject != nil && responseObject!["result"] as! String == "FAILURE" {
                //                self.ride!.promocode = nil
                if let responseError = Mapper<ResponseError>().map(JSONObject: responseObject?["resultData"]) {
                    self.applyPromoCodeView?.handleResponseError(responseError: responseError,responseObject: responseObject,error: error)
                } else {
                    self.applyPromoCodeView?.handleResponseError(responseError: nil,responseObject: responseObject,error: error)
                }
            } else {
                //                self.ride!.promocode = nil
                self.applyPromoCodeView?.handleResponseError(responseError: nil,responseObject: responseObject,error: error)
            }
            if self.viewController != nil && self.viewController!.isKind(of: LiveRideCardViewController.classForCoder()) {
                (self.viewController as! LiveRideCardViewController).liveRideTableView.reloadData()
            }
        })
    }
    
    //MARK: Actions
//    @IBAction func applyCouponTapped(_ sender: UIButton) {
//        applyPromoCodeView = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard,bundle: nil).instantiateViewController(withIdentifier: "ApplyPromoCodeDialogueView") as? ApplyPromoCodeDialogueView
//
//        applyPromoCodeView!.initializeDataBeforePresentingView(title: Strings.apply_promo_code, positiveBtnTitle: Strings.apply_caps, negativeBtnTitle: Strings.cancel_caps, promoCode: rideObj?.promocode, isCapitalTextRequired: true, viewController: viewController, placeHolderText: Strings.promo_code_hint, promoCodeAppliedMsg: String(format: Strings.promo_code_applied, arguments: [rideObj?.promocode ?? ""]), handler: { (text, result) in
//            if Strings.apply_caps == result{
//                if text != nil {
//                    self.verifyPromoCode(promoCode : text!)
//                }
//            }
//        })
//        ViewControllerUtils.addSubView(viewControllerToDisplay: applyPromoCodeView!)
//    }
    
//    @IBAction func couponCloseButtonTapped(_ sender: UIButton) {
//        couponAppliedView.isHidden = true
//        applyCouponButton.isHidden = false
//        applyCouponHeightConstraint.constant = 18
//        rideObj?.promocode = nil
//    }
}
