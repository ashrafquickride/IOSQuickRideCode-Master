//
//  EncashConfirmationViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 1/8/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

protocol PayTmRedemptionReceiver
{
    func payTmRedemptionReceived(payTmAccountId : String, encashType : String)
}
class EncashConfirmationViewController : ModelViewController, UITextFieldDelegate
{
    @IBOutlet weak var serviceFeeLabel: UILabel!
    
    @IBOutlet weak var encashAmount: UILabel!
    
    @IBOutlet weak var serviceFeeAmount: UILabel!
    
    @IBOutlet weak var payTmAccountNoTextField: UITextField!
    
    @IBOutlet weak var netAmount: UILabel!
    
    @IBOutlet weak var redeemBtn: UIButton!
    
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var descriptionTextHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var payTmNo: UILabel!
    
    @IBOutlet weak var payTmNoWidthConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var userInfoTextView: UILabel!
    
    
    @IBOutlet weak var serviceFeeLblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var superViewWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var superViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var superView: UIView!
    
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var amountToRedeem: UILabel!
    
    @IBOutlet weak var rechargedAmount: UILabel!
    
    @IBOutlet weak var paymentGateWayCharges: UILabel!
    
    @IBOutlet weak var totalAmounttoRedeem: UILabel!
    
    @IBOutlet weak var rechargedAmountRedeemedView: UIView!
    
    @IBOutlet weak var paytmOrTMWTxnsFees: UILabel!
    
    @IBOutlet weak var redeemAmountViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var TxnFeesView: UIView!
    
    @IBOutlet weak var netAmountView: UIView!
    
    @IBOutlet weak var amountView: UIView!
    
    @IBOutlet weak var rechargedAmountredeemedViewHeight: NSLayoutConstraint!
   
    @IBOutlet weak var paytmAndTMWTxnFeeLabel: UILabel!
    
    @IBOutlet weak var paymentGateWayChargesLabel: UILabel!
    
    @IBOutlet weak var kycInfoLabel: UILabel!
    
    @IBOutlet weak var kycInfoLblHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var editBankButton: UIButton!
    @IBOutlet weak var accountNumberView: UIView!
    var userId : String?
    var amount : String?
    var serviceFee : String?
    var isKeyboardVisible = false
    var encashType : String?
    var clientConfiguration :ClientConfigurtion?
    var payTmRedemptionReceiver : PayTmRedemptionReceiver?
    var rechargedPoints : Int?
    
    func initializeDataBeforePresentingView (amount : String?, userId : String,payTmRedemptionReceiver : PayTmRedemptionReceiver?, encashType : String, rechargedPoints : Int?) {
        AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresentingView()")
        self.amount = amount
        self.userId = userId
        self.payTmRedemptionReceiver = payTmRedemptionReceiver
        self.encashType = encashType
        self.rechargedPoints = rechargedPoints
    }
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        
        payTmAccountNoTextField.delegate = self
        scrollView.isScrollEnabled = true
        self.automaticallyAdjustsScrollViewInsets = false
        self.superViewWidthConstraint.constant = self.view.frame.size.width * 0.90
        self.superViewHeightConstraint.constant = self.superViewHeightConstraint.constant - self.descriptionTextHeightConstraint.constant
        payTmAccountNoTextField.text = userId
        if encashType == EncashPaymentViewController.ENCASH_TYPE_LINKED_PAYTM{
            userInfoTextView.text = Strings.paytm_userInfo
        }
        else if encashType == EncashPaymentViewController.ENCASH_TYPE_LINKED_TMW{
            userInfoTextView.text = Strings.tmw_userInfo
            payTmNo.text = Strings.tmw_no
            payTmNoWidthConstraint.constant = 150
        }
        else if encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM
        {
            userInfoTextView.text = Strings.paytm_userInfo
        }
        else if encashType == RedemptionRequest.REDEMPTION_TYPE_TMW{
            userInfoTextView.text = Strings.tmw_userInfo
            
        }else if encashType == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY {
            userInfoTextView.text = Strings.tmw_userInfo
        }else if encashType == RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER{
            userInfoTextView.text = Strings.tmw_userInfo
            editBankButton.isHidden = false
            accountNumberView.isHidden = true
            if SharedPreferenceHelper.getBankRegistration(){
                editBankButton.setTitle(Strings.editBankDetails, for: .normal)
            }else{
                editBankButton.setTitle(Strings.enterBankDetails, for: .normal)
            }
        }
        handleKYCHeight()
        initializeViewBasedOnTarget()
        NotificationCenter.default.addObserver(self, selector: #selector(EncashConfirmationViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(EncashConfirmationViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToView(view: scrollView, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: superView, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: redeemBtn, cornerRadius: 10.0)
        CustomExtensionUtility.changeBtnColor(sender: self.redeemBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
    }
    func setSuperViewHeight(){
        self.superViewHeightConstraint.constant = self.superViewHeightConstraint.constant + self.descriptionTextHeightConstraint.constant
        if self.superViewHeightConstraint.constant > self.view.frame.size.height * 0.90
        {
            self.superViewHeightConstraint.constant = self.view.frame.size.height * 0.90
        }
    }
    func handleKYCHeight()
    {
        if encashType == RedemptionRequest.REDEMPTION_TYPE_TMW || encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL
        {
            kycInfoLabel.isHidden = true
            kycInfoLblHeightConstraint.constant = 0
        }
        else if encashType == EncashPaymentViewController.ENCASH_TYPE_LINKED_PAYTM || encashType == EncashPaymentViewController.ENCASH_TYPE_LINKED_TMW  || encashType == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY || encashType == RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER{
            self.superViewHeightConstraint.constant = self.superViewHeightConstraint.constant - 50
            kycInfoLabel.isHidden = true
            kycInfoLblHeightConstraint.constant = 0
        }
        else
        {
            kycInfoLabel.isHidden = false
            let attributes = [NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-Bold", size: 13)!]
            let rect = kycInfoLabel.text?.boundingRect(with: CGSize(width: self.superViewWidthConstraint.constant - 40, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
            kycInfoLblHeightConstraint.constant = rect!.height
        }
    }
    func intializeTheRechargeAmountRedeemedView(){
        
        amountToRedeem.text = ": "+amount!
         var serviceFee = 0
        if encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM || encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL
        {
        let netamount = RedemptionRequest.getAmountAfterRemovingServiceFeeForPaytm(points: Int(amount!)!, serviceFee: clientConfiguration!.paytmServiceFee)
          serviceFee = Int(amount!)! - netamount
        }
        setAmount()
        rechargedAmount.text = ": "+String(describing: rechargedPoints!)
        
        let totalnetamount = RedemptionRequest.getAmountAfterRemovingGateWayChargesForRechargePoints(points: rechargedPoints!, gateWayCharges: clientConfiguration!.rechargeServiceFee)
        let serviceForRechargedAmount = rechargedPoints!-totalnetamount
        paymentGateWayCharges.text = ": " + String(serviceForRechargedAmount)
        let calculateNetAmount = (Int(amount!)! - (serviceFee + serviceForRechargedAmount))
        totalAmounttoRedeem.text = ": "+String(calculateNetAmount)
    }

    func initializeViewBasedOnTarget()
    {

        let attributes = [NSAttributedString.Key.font : UIFont(name: ViewCustomizationUtils.FONT_STYLE, size: 14)!]
        let rect = userInfoTextView.text?.boundingRect(with: CGSize(width: self.superViewWidthConstraint.constant - 40, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes, context: nil)
        if encashType == EncashPaymentViewController.ENCASH_TYPE_LINKED_PAYTM || encashType == EncashPaymentViewController.ENCASH_TYPE_LINKED_TMW{
            descriptionTextHeightConstraint.constant = rect!.height-20
            rechargedAmountRedeemedView.isHidden = true
            redeemAmountViewHeight.constant = 0
            rechargedAmountredeemedViewHeight.constant = 10
            amountView.isHidden = true
            TxnFeesView.isHidden = true
            netAmountView.isHidden = true
            serviceFeeLabel.isHidden = true
            redeemBtn.setTitle(Strings.confirm_caps, for: .normal)
            serviceFeeLblHeightConstraint.constant = 0
            self.titleLabel.text = Strings.affidavit
            setSuperViewHeight()
        }
        else{
            clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
            if clientConfiguration == nil{
                clientConfiguration = ClientConfigurtion()
            }
            
            if rechargedPoints! > 0{
                intializeTheRechargeAmountRedeemedView()
                amountView.isHidden = true
                TxnFeesView.isHidden = true
                netAmountView.isHidden = true
                rechargedAmountRedeemedView.isHidden = false
                redeemAmountViewHeight.constant = 0
                rechargedAmountredeemedViewHeight.constant = 196
                paymentGateWayChargesLabel.text = String(format: Strings.payment_gateway_charges, String(clientConfiguration!.rechargeServiceFee)+"%")
            }
            else{
                setAmount()
                amountView.isHidden = false
                TxnFeesView.isHidden = false
                netAmountView.isHidden = false
                rechargedAmountRedeemedView.isHidden = true
                redeemAmountViewHeight.constant = 45
                rechargedAmountredeemedViewHeight.constant = 10
                
            }
            if encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM
            {
                descriptionTextHeightConstraint.constant = rect!.height-20
                let payTmServiceFee : Int = clientConfiguration!.paytmServiceFee
                if payTmServiceFee > 0
                {
                    self.serviceFeeLabel.text = String(format: Strings.paytm_service_fee_msg, String(payTmServiceFee)+"%")
                }
                self.titleLabel.text = Strings.affidavit
                setSuperViewHeight()
            }else if encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL{
                descriptionTextHeightConstraint.constant = 0
                let payTmServiceFee : Int = clientConfiguration!.paytmServiceFee
                if payTmServiceFee > 0
                {
                    self.serviceFeeLabel.text = String(format: Strings.paytm_service_fee_msg, String(payTmServiceFee)+"%")
                }
                self.titleLabel.text = Strings.paytm_fuel_redemption
                if rechargedAmountRedeemedView.isHidden == false{
                    self.superViewHeightConstraint.constant = self.superViewHeightConstraint.constant + rechargedAmountredeemedViewHeight.constant - 40
                }
            }else if encashType == RedemptionRequest.REDEMPTION_TYPE_TMW
            {
                descriptionTextHeightConstraint.constant = rect!.height-20
                payTmNoWidthConstraint.constant = 150
                serviceFeeLabel.isHidden = true
                serviceFeeLblHeightConstraint.constant = 0
                payTmNo.text = Strings.tmw_no
                paytmAndTMWTxnFeeLabel.text = Strings.tmw_trns_fee
                redeemBtn.setTitle(Strings.tmw_btn_title, for: .normal)
                self.titleLabel.text = Strings.affidavit
                setSuperViewHeight()
            }else if encashType == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY
            {
                descriptionTextHeightConstraint.constant = rect!.height-20
                payTmNoWidthConstraint.constant = 115
                rechargedAmountRedeemedView.isHidden = true
                redeemAmountViewHeight.constant = 0
                rechargedAmountredeemedViewHeight.constant = 10
                amountView.isHidden = true
                TxnFeesView.isHidden = true
                netAmountView.isHidden = true
                serviceFeeLabel.isHidden = true
                payTmNo.text = Strings.amazon_pay_no
                redeemBtn.setTitle(Strings.amazon_pay_btn_title, for: .normal)
                serviceFeeLblHeightConstraint.constant = 0
                self.titleLabel.text = Strings.affidavit
                setSuperViewHeight()
            }else if encashType == RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER{
                descriptionTextHeightConstraint.constant = rect!.height-20
                rechargedAmountRedeemedView.isHidden = true
                rechargedAmountredeemedViewHeight.constant = 10
                amountView.isHidden = false
                redeemAmountViewHeight.constant = 45
                encashAmount.text = amount
                let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
                serviceFeeAmount.text = String(clientConfiguration.serviceFeeForBankTransfer)
                netAmount.text = String((Int(amount ?? "") ?? 0) - clientConfiguration.serviceFeeForBankTransfer)
                TxnFeesView.isHidden = false
                netAmountView.isHidden = false
                serviceFeeLabel.isHidden = true
                redeemBtn.setTitle(Strings.redeem_to_bank, for: .normal)
                serviceFeeLblHeightConstraint.constant = 0
                titleLabel.text = Strings.affidavit
                superViewHeightConstraint.constant = superViewHeightConstraint.constant + descriptionTextHeightConstraint.constant + 30
            }
        }
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EncashConfirmationViewController.dismissView(_:))))
    }

    func setAmount()
    {
        if encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM || encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL
        {
            let netamount = RedemptionRequest.getAmountAfterRemovingServiceFeeForPaytm(points: Int(amount!)!, serviceFee: clientConfiguration!.paytmServiceFee)
            let serviceFee = Int(amount!)! - netamount
            serviceFeeAmount.text = String(serviceFee)
            netAmount.text = String(netamount)
            encashAmount.text = amount
            paytmOrTMWTxnsFees.text = ": " + String(serviceFee)
        }
        else if encashType == RedemptionRequest.REDEMPTION_TYPE_TMW
        {
            serviceFeeAmount.text = "0"
            netAmount.text = amount
            encashAmount.text = amount
            paytmOrTMWTxnsFees.text = ": 0"
        }
        else if encashType == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY
        {
            serviceFeeAmount.text = "0"
            netAmount.text = amount
            encashAmount.text = amount
            paytmOrTMWTxnsFees.text = ": 0"
        }
        
    }
    @IBAction func redeemBtnTapped(_ sender: Any) {
        self.payTmAccountNoTextField.endEditing(true)
        let encashAccountNo = payTmAccountNoTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines
        )
        if self.encashType == EncashPaymentViewController.ENCASH_TYPE_LINKED_PAYTM || self.encashType == EncashPaymentViewController.ENCASH_TYPE_LINKED_TMW{
            self.view.removeFromSuperview()
            self.removeFromParent()
            self.payTmRedemptionReceiver!.payTmRedemptionReceived(payTmAccountId: self.payTmAccountNoTextField.text!,encashType: self.encashType!)
            return
        }
        if encashAccountNo == nil || encashAccountNo!.isEmpty == true || !(AppUtil.isValidPhoneNo(phoneNo: payTmAccountNoTextField.text!, countryCode: AppConfiguration.DEFAULT_COUNTRY_CODE_IND)) {
            UIApplication.shared.keyWindow?.makeToast( Strings.enter_valid_phone_number)
            return
        }
        
        self.view.removeFromSuperview()
        self.removeFromParent()
          if self.encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM || self.encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL
            {
                if self.payTmRedemptionReceiver != nil
                {
                    self.payTmRedemptionReceiver!.payTmRedemptionReceived(payTmAccountId: self.payTmAccountNoTextField.text!,encashType: self.encashType!)
                }
            }
          else if self.encashType == RedemptionRequest.REDEMPTION_TYPE_TMW
            {
                QuickRideProgressSpinner.startSpinner()
                AccountRestClient.validateTMWUser(contactNo: self.payTmAccountNoTextField.text!, targetViewController: nil, completionHandler: { (responseObject, error) -> Void in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject != nil {
                        if responseObject!["result"] as! String == "SUCCESS"{
                            self.payTmRedemptionReceiver!.payTmRedemptionReceived(payTmAccountId: self.payTmAccountNoTextField.text!, encashType: self.encashType!)
                        }
                        if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
                            
                            let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                            if (AccountException.TMW_REDEEM_REQUEST_FAILED_DUE_NO_WALLET_ACCOUNT == responseError?.errorCode)
                            {
                                let accountNo = self.payTmAccountNoTextField.text!
                                self.view.removeFromSuperview()
                                self.removeFromParent()
                                MessageDisplay.displayErrorAlertWithAction(title : nil, isDismissViewRequired : false, message1: String(format: Strings.tmw_user_not_registered_alert, (accountNo)), message2: nil, positiveActnTitle: Strings.create_caps, negativeActionTitle : Strings.cancel_caps, linkButtonText: nil, viewController: nil, handler: { (result) in
                                    if Strings.create_caps == result{
                                        
                                        let tmwRegistrationController : TMWRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TMWRegistrationViewController") as! TMWRegistrationViewController
                                        
                                        ViewControllerUtils.addSubView(viewControllerToDisplay: tmwRegistrationController)
                                    }
                                })
                                return
                            }
                            else
                            {
                                ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: nil, handler: nil)
                            }
                        }
                    }
                    else{
                        ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: nil, handler: nil)
                        
                    }
                })
          }else if self.encashType == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY{
            if self.payTmRedemptionReceiver != nil
            {
                self.payTmRedemptionReceiver!.payTmRedemptionReceived(payTmAccountId: self.payTmAccountNoTextField.text!,encashType: self.encashType!)
            }
          }else if encashType == RedemptionRequest.REDEMPTION_TYPE_BANK_TRANSFER{
            payTmRedemptionReceiver!.payTmRedemptionReceived(payTmAccountId: "",encashType: encashType ?? "")
        }
    }
    
    @objc func dismissView(_ sender: UITapGestureRecognizer)
    {
        
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func closeBtnTapped(_ sender: Any) {
        
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    func textFieldShouldReturn(_ textField : UITextField) -> Bool{
        textField.endEditing(true)
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton(textField: textField)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == payTmAccountNoTextField{
            threshold = 10
        }else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
    
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        textField.inputAccessoryView = keyToolBar
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        
        if (!isKeyboardVisible) {
            if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                if self.encashType == RedemptionRequest.REDEMPTION_TYPE_TMW
                {
                    scrollViewBottomSpaceConstraint.constant = keyBoardSize.height - 80
                }
                else if self.encashType == RedemptionRequest.REDEMPTION_TYPE_PAYTM_FUEL
                {
                    scrollViewBottomSpaceConstraint.constant = keyBoardSize.height - 160
                }
                else if self.encashType == RedemptionRequest.REDEMPTION_TYPE_AMAZONPAY
                {
                    scrollViewBottomSpaceConstraint.constant = keyBoardSize.height - 80
                }
                else{
                    scrollViewBottomSpaceConstraint.constant = keyBoardSize.height - 50
                }
            }
        }
        isKeyboardVisible = true
    }
    
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if (isKeyboardVisible) {
            scrollViewBottomSpaceConstraint.constant = 0
        }
        isKeyboardVisible = false
    }
    @IBAction func editBankDetailsTapped(_ sender: Any) {
        let bankAccountRegistrationViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "BankAccountRegistrationViewController") as! BankAccountRegistrationViewController
        bankAccountRegistrationViewController.initialiseRegistration(isRequiredToEditBankDetails: true) { (isBankRegisterd) in
        }
        self.navigationController?.pushViewController(bankAccountRegistrationViewController, animated: false)
    }
}
