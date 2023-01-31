//
//  PaytmOTPValidationViewController.swift
//  Quickride
//
//  Created by rakesh on 10/2/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import BottomPopup

public typealias linkExternalWalletReciever = (_ walletAdded : Bool,_ walletType: String?) -> Void

class OTPValidationViewController : BottomPopupViewController {
    
    @IBOutlet weak var walletTypeImageView: UIImageView!
    @IBOutlet weak var otpSentLabel: UILabel!
    
    @IBOutlet weak var OTPTextField: UITextField!
    
    @IBOutlet weak var txtFieldBtn: UIButton!
    
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var positiveActnBtn: UIButton!
    
    @IBOutlet weak var lazyPayTermsAndConditionLbl: UIButton!
    
    @IBOutlet weak var lazyPayTermsAndConditionHeightConstraint: NSLayoutConstraint!
    
    var phoneNo : String?
    var linkWalletResponse : LinkWalletResponse?
    var linkExternalWalletReceiver : linkExternalWalletReciever?
    var walletType : String?
    var otpId : String?
    var isKeyBoardVisible = false
    
    func initializeDataBeforePresenting(phoneNo : String,walletType : String,linkWalletResponse : LinkWalletResponse?,linkExternalWalletReceiver : linkExternalWalletReciever?,otpId: String?){
        self.phoneNo = phoneNo
        self.linkWalletResponse = linkWalletResponse
        self.linkExternalWalletReceiver = linkExternalWalletReceiver
        self.walletType = walletType
        self.otpId = otpId
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updatePopupHeight(to: 350)
        if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
            walletTypeImageView.image = UIImage(named: "paytm_logo")
            lazyPayTermsAndConditionLbl.isHidden = true
            lazyPayTermsAndConditionHeightConstraint.constant = 0
        }else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY{
            walletTypeImageView.image = UIImage(named: "lazypay")
            lazyPayTermsAndConditionLbl.isHidden = false
            lazyPayTermsAndConditionHeightConstraint.constant = 25
        }else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_TMW{
            walletTypeImageView.image = UIImage(named: "tmw")
            lazyPayTermsAndConditionLbl.isHidden = true
            lazyPayTermsAndConditionHeightConstraint.constant = 0
        }else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK{
            walletTypeImageView.image = UIImage(named: "mobikwik_logo_with_text")
            lazyPayTermsAndConditionLbl.isHidden = true
            lazyPayTermsAndConditionHeightConstraint.constant = 0
        }else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE{
            walletTypeImageView.image = UIImage(named: "frecharge_with_text")
            lazyPayTermsAndConditionLbl.isHidden = true
            lazyPayTermsAndConditionHeightConstraint.constant = 0
        }
        OTPTextField.delegate = self
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 20.0)
        otpSentLabel.text = String(format: Strings.we_sent_otp, phoneNo!)
        ViewCustomizationUtils.addCornerRadiusToView(view: positiveActnBtn, cornerRadius: 20.0)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func backGroundViewTapped(_ gesture : UITapGestureRecognizer){
        AccountPaymentViewController.OTPValidationViewController = nil
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    @IBAction func cancelBtnClicked(_ sender: Any) {
        AccountPaymentViewController.OTPValidationViewController = nil
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton(textField: OTPTextField)
    }
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(OTPValidationViewController.closeKeyboard))
        keyToolBar.items = [flexBarButton,doneBarButton]
        textField.inputAccessoryView = keyToolBar
    }
    @objc func closeKeyboard(){
        self.view.endEditing(true)
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            isKeyBoardVisible = true
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        updatePopupHeight(to: 350)
        txtFieldBtn.isHidden = false
    }
    @IBAction func confirmBtnClicked(_ sender: Any) {
        self.view.endEditing(true)
        if OTPTextField.text == nil || OTPTextField.text!.isEmpty{
            UIApplication.shared.keyWindow?.makeToast(String(format: Strings.we_sent_otp, phoneNo!))
            positiveActnBtn.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.positiveActnBtn.isUserInteractionEnabled = true
            }
            return
        }
        
        if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_PAYTM{
           validateOTPForPaytmWalletLinking()
        }else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_LAZYPAY{
            validateOTPForLazyPayWalletLinking()
        }else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_TMW{
            validateOTPForTMWWalletLinking()
        }else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_MOBIQWIK{
            validateOTPForMobikwikWalletLinking()
        }else if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_FREECHARGE{
            validateOTPForFrechargeWalletLinking()
        }
    }
    
    func validateOTPForPaytmWalletLinking(){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.verifyOTPForLinkingPaytm(userId: QRSessionManager.getInstance()!.getUserId(), mobileNo: phoneNo!,otp: OTPTextField.text!, uuid: self.linkWalletResponse!.state!, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet!)
                UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet!)
                self.linkExternalWalletReceiver?(true, nil)
                AccountPaymentViewController.OTPValidationViewController = nil
                self.dismiss(animated: true)
                AccountUtils().showActivatedAlert(walletType: linkedWallet!.type!)
            }else{
                self.displayErrorMessage(responseObject: responseObject, error: error)
            }
        }
    }
    
    private func displayErrorMessage(responseObject: NSDictionary?,error : NSError?){
        guard let errorMessage = ErrorProcessUtils.getErrorMessage(responseObject: responseObject, error: error) else {
            return
        }
        UIApplication.shared.keyWindow?.makeToast(String(format: errorMessage))
    }
    
    func validateOTPForTMWWalletLinking(){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.verifyOTPForLinkingTMW(userId: QRSessionManager.getInstance()!.getUserId(), mobileNo: phoneNo!, otp: OTPTextField.text!, transactionId: self.linkWalletResponse!.transactionID!, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet!)
                UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet!)
                self.linkExternalWalletReceiver?(true, nil)
                AccountPaymentViewController.OTPValidationViewController = nil
                self.dismiss(animated: true)
                AccountUtils().showActivatedAlert(walletType: linkedWallet!.type!)
            }else{
                self.displayErrorMessage(responseObject: responseObject, error: error)
            }
        }
    }
    func validateOTPForLazyPayWalletLinking(){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.verifyOTPForLinkingLazyPay(userId: QRSessionManager.getInstance()!.getUserId(), mobileNo: phoneNo!, otp:  OTPTextField.text!, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet!)
                UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet!)
                self.linkExternalWalletReceiver?(true, nil)
                AccountPaymentViewController.OTPValidationViewController = nil
                self.dismiss(animated: true)
                AccountUtils().showActivatedAlert(walletType: linkedWallet!.type!)
            }else{
                self.displayErrorMessage(responseObject: responseObject, error: error)
            }
        }
    }
    
    func validateOTPForMobikwikWalletLinking(){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.verifyOTPForLinkingMobikwik(userId: QRSessionManager.getInstance()!.getUserId(), mobileNo: phoneNo!, otp: OTPTextField.text!, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet!)
                UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet!)
                self.linkExternalWalletReceiver?(true, nil)
                AccountPaymentViewController.OTPValidationViewController = nil
                self.view.removeFromSuperview()
                self.removeFromParent()
                AccountUtils().showActivatedAlert(walletType: linkedWallet!.type!)
            }else{
                self.displayErrorMessage(responseObject: responseObject, error: error)
            }
        }
    }
    
    @IBAction func txtFieldBtnTapped(_ sender: Any) {
        if UIDevice.current.hasNotch {
            updatePopupHeight(to: 650)
        }else {
            updatePopupHeight(to: 560)
        }
        OTPTextField.becomeFirstResponder()
        txtFieldBtn.isHidden = true
    }
    @IBAction func lazyPayTermsAndCondiTapped(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("")
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  AppConfiguration.lazyPay_terms_url)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.terms_and_conditions, url: (urlcomps?.url!)!, actionComplitionHandler: nil)
            ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: webViewController, animated: false)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    func validateOTPForFrechargeWalletLinking(){
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.verifyOTPForLinkingFrecharge(userId: QRSessionManager.getInstance()!.getUserId(), mobileNo: phoneNo!, otp: OTPTextField.text!,otpId: otpId, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let linkedWallet = Mapper<LinkedWallet>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserLinkedWallet(linkedWallet: linkedWallet!)
                UserCoreDataHelper.storeLinkedWallet(linkedWallet: linkedWallet!)
                self.linkExternalWalletReceiver?(true, nil)
                AccountPaymentViewController.OTPValidationViewController = nil
                self.view.removeFromSuperview()
                self.removeFromParent()
                AccountUtils().showActivatedAlert(walletType: linkedWallet!.type!)
            }else{
                self.displayErrorMessage(responseObject: responseObject, error: error)
            }
        }
    }
}

extension OTPValidationViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if OTPTextField.text == nil || OTPTextField.text?.isEmpty == true {
            OTPTextField.text = ""
            positiveActnBtn.backgroundColor = .lightGray
            positiveActnBtn.isUserInteractionEnabled = false
        }else{
            positiveActnBtn.backgroundColor = UIColor(netHex: 0x00b557)
            positiveActnBtn.isUserInteractionEnabled = true
        }
        return true
    }
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if(OTPTextField.text?.isEmpty == true){
            positiveActnBtn.backgroundColor = .lightGray
            positiveActnBtn.isUserInteractionEnabled = false
        }else if OTPTextField.text?.trimmingCharacters(in: NSCharacterSet.whitespaces).count == 0 {
            positiveActnBtn.backgroundColor = .lightGray
            positiveActnBtn.isUserInteractionEnabled = false
        }else {
            positiveActnBtn.backgroundColor = UIColor(netHex: 0x00b557)
            positiveActnBtn.isUserInteractionEnabled = true
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if OTPTextField.text == nil || OTPTextField.text?.isEmpty == true || OTPTextField.text ==  Strings.feedback{
            positiveActnBtn.backgroundColor = .lightGray
            positiveActnBtn.isUserInteractionEnabled = false
        }else {
            positiveActnBtn.backgroundColor = UIColor(netHex: 0x00B557)
            positiveActnBtn.isUserInteractionEnabled = true
        }
    }
}

