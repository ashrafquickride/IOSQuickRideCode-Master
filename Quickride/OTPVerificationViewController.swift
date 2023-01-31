//
//  OTPVerificationViewController.swift
//  Quickride
//
//  Created by Admin on 14/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie
import MessageUI

class OTPVerificationViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var otpSentTextLabel: UILabel!
    @IBOutlet weak var activationCodeTextField1: UITextField!
    @IBOutlet weak var activationCodeTextField2: UITextField!
    @IBOutlet weak var activationCodeTextField3: UITextField!
    @IBOutlet weak var activationCodeTextField4: UITextField!
    @IBOutlet weak var progressBarAnimationView: AnimationView!
    @IBOutlet weak var activationCodeView: UIStackView!
    @IBOutlet weak var errorMsgLabel: UILabel!
    @IBOutlet weak var sessionLoadingView: UIView!
    @IBOutlet weak var sessionLoadingAnimationView: AnimationView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var needSupportBtn: UIButton!
    @IBOutlet weak var resendOtpBtn: UIButton!
    
    //MARK: Properties
    var otpVerificationViewModel = OTPVerificationViewModel()
    
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        handleViewCustomization()
        addTargetToTextFields()
        otpVerificationViewModel.delegate = self
        otpSentTextLabel.text = String(format: Strings.we_sent_activationcode, arguments: [otpVerificationViewModel.contactNo!])
        NotificationCenter.default.addObserver(self, selector: #selector(handleUIForErrorCase), name: Notification.Name.init(otpVerificationViewModel.INCORRECT_VERIFICATION_CODE), object: nil)
        resendOtpBtn.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
            self.resendOtpBtn.isHidden = false
             }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activationCodeTextField1.becomeFirstResponder()
    }
 
    //MARK: Methods
    
    private func handleViewCustomization(){
        ViewCustomizationUtils.addCornerRadiusToView(view: activationCodeTextField1, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: activationCodeTextField2, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: activationCodeTextField3, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: activationCodeTextField4, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: headerView, cornerRadius: 3.0)
    }
    
    private func addTargetToTextFields(){
        activationCodeTextField1.addTarget(self, action: #selector(textFieldDidChangeActivationCode(textField:)), for: UIControl.Event.editingChanged)
        activationCodeTextField2.addTarget(self, action: #selector(textFieldDidChangeActivationCode(textField:)), for: UIControl.Event.editingChanged)
        activationCodeTextField3.addTarget(self, action: #selector(textFieldDidChangeActivationCode(textField:)), for: UIControl.Event.editingChanged)
        activationCodeTextField4.addTarget(self, action: #selector(textFieldDidChangeActivationCode(textField:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChangeActivationCode(textField : UITextField){
        let text = textField.text
        if text?.utf16.count == 1{
            
            switch textField {
            case activationCodeTextField1:
                handleUIUpdateBasedOnTextFieldText(textField: activationCodeTextField1)
                activationCodeTextField2.becomeFirstResponder()
            case activationCodeTextField2:
                handleUIUpdateBasedOnTextFieldText(textField: activationCodeTextField2)
                activationCodeTextField3.becomeFirstResponder()
            case activationCodeTextField3:
                handleUIUpdateBasedOnTextFieldText(textField: activationCodeTextField3)
                activationCodeTextField4.becomeFirstResponder()
            case activationCodeTextField4:
                handleUIUpdateBasedOnTextFieldText(textField: activationCodeTextField4)
                activationCodeTextField4.resignFirstResponder()
                checkUserObjHandleOTPVerification()
            default:
                break
            }
            
        }else{
            switch textField {
            case activationCodeTextField4:
                resetTextFieldBackGroundColor(textField: activationCodeTextField4)
                activationCodeTextField4.resignFirstResponder()
                activationCodeTextField3.becomeFirstResponder()
            case activationCodeTextField3:
                resetTextFieldBackGroundColor(textField: activationCodeTextField3)
                activationCodeTextField3.resignFirstResponder()
                activationCodeTextField2.becomeFirstResponder()
            case activationCodeTextField2:
                resetTextFieldBackGroundColor(textField: activationCodeTextField2)
                activationCodeTextField2.resignFirstResponder()
                activationCodeTextField1.becomeFirstResponder()
            case activationCodeTextField1:
                resetTextFieldBackGroundColor(textField: activationCodeTextField1)
                activationCodeTextField1.becomeFirstResponder()
            default:
                break
            }
        }
    }
    
    private func resetTextFieldBackGroundColor(textField : UITextField){
        textField.backgroundColor = UIColor(netHex: 0xe7e7e7)
        ViewCustomizationUtils.addBorderToView(view: textField, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
    }
    
    private func handleUIUpdateBasedOnTextFieldText(textField : UITextField){
        if textField.text!.isEmpty{
            textField.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: textField, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
        }else{
            textField.backgroundColor = .white
            ViewCustomizationUtils.addBorderToView(view: textField, borderWidth: 1.0, color: UIColor(netHex: 0xe1e1e1))
        }
    }
    
    private func resendOTPToExistingUser(user : User){
        QuickRideProgressSpinner.startSpinner()
        otpVerificationViewModel.sendVerificationCodeToUser(viewController: self, user: user) { [weak self](responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( Strings.otp_resent, duration: 2.0)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    private func resendOTPToNewUser(){
        QuickRideProgressSpinner.startSpinner()
        otpVerificationViewModel.resendOTPToNewUser(contactNo: otpVerificationViewModel.contactNo ?? "", appName: AppConfiguration.APP_NAME, countryCode: AppConfiguration.DEFAULT_COUNTRY_CODE_IND, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( Strings.otp_resent, duration: 2.0)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    private func checkUserObjHandleOTPVerification(){
        if let user = otpVerificationViewModel.user{
            let otp = activationCodeTextField1.text! + activationCodeTextField2.text! + activationCodeTextField3.text! + activationCodeTextField4.text!
            user.iosAppVersionName = AppConfiguration.APP_CURRENT_VERSION_NO
            loginWithOTP(activationCodeText: otp, user: user)
        }else{
            handleOTPVerificationForNewUser()
        }
    }
    
    private func startLoadingAnimation(){
        activationCodeView.isHidden = true
        progressBarAnimationView.animation = Animation.named("loading_otp")
        progressBarAnimationView.isHidden = false
        progressBarAnimationView.play()
        progressBarAnimationView.loopMode = .loop
        needSupportBtn.isHidden = true
        resendOtpBtn.isHidden = true
    }
    
    private func stopAnimation(){
        activationCodeView.isHidden = false
        progressBarAnimationView.isHidden = true
        progressBarAnimationView.stop()
        needSupportBtn.isHidden = false
        resendOtpBtn.isHidden = false
    }
    
    private func loginWithOTP(activationCodeText : String,user : User){
        startLoadingAnimation()
        otpVerificationViewModel.loginWithOTP(userObj: user , activationCodeText: activationCodeText, viewController: self) { [weak self] (responseObject, error) in
            self?.stopAnimation()
            self?.resetTextFields()
            self?.handleLoginWithOTPResponse(otp: activationCodeText, user: user, responseObject: responseObject, error: error)
        }
    }
    
    
    private func resetTextFields(){
        activationCodeTextField1.text = ""
        activationCodeTextField2.text = ""
        activationCodeTextField3.text = ""
        activationCodeTextField4.text = ""
        activationCodeTextField1.backgroundColor = UIColor(netHex: 0xe7e7e7)
        ViewCustomizationUtils.addBorderToView(view: activationCodeTextField1, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
        activationCodeTextField2.backgroundColor = UIColor(netHex: 0xe7e7e7)
        ViewCustomizationUtils.addBorderToView(view: activationCodeTextField2, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
        activationCodeTextField3.backgroundColor = UIColor(netHex: 0xe7e7e7)
        ViewCustomizationUtils.addBorderToView(view: activationCodeTextField3, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
        activationCodeTextField4.backgroundColor = UIColor(netHex: 0xe7e7e7)
        ViewCustomizationUtils.addBorderToView(view: activationCodeTextField4, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
    }
    
    private func handleLoginWithOTPResponse(otp : String,user : User,responseObject : NSDictionary?,error : NSError?){
        guard let responseObject = responseObject else {
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            return
        }
        AppDelegate.getAppDelegate().log.debug("Response in login is \(String(describing: responseObject)) and \(String(describing: error))")
        
        if responseObject["result"] as! String == "SUCCESS" {
            handleSuccessResponseForOTPLogin(otp: otp, responseObject: responseObject)
        }else if responseObject["result"] as! String == "FAILURE" {
            handleFailureResponseForOTPLogin(otp: otp, user: user, responseObject: responseObject)
        }
        
    }
    
    private func handleSuccessResponseForOTPLogin(otp : String,responseObject : NSDictionary?){
        if let user = otpVerificationViewModel.getUserObj(responseObject: responseObject){
            otpVerificationViewModel.handleSuccessResponseForOTPLogin(otp: otp, user: user, viewController: self)
            otpVerificationViewModel.storeUserWhatsAppPreferences()
        }
    }
    
    private func handleFailureResponseForOTPLogin(otp : String,user : User,responseObject : NSDictionary?){
        otpVerificationViewModel.handleFailureResponseForOTPLogin(otp: otp, responseObject: responseObject, countryCode: user.countryCode, viewController: self)
    }
    
    private func handleOTPVerificationForNewUser(){
        let otp = activationCodeTextField1.text! + activationCodeTextField2.text! + activationCodeTextField3.text! + activationCodeTextField4.text!
        startLoadingAnimation()
        otpVerificationViewModel.verifyOtpForNewUser(contactNo: otpVerificationViewModel.contactNo ?? "", otp: otp, countryCode: AppConfiguration.DEFAULT_COUNTRY_CODE_IND, viewController: self) { [weak self](responseObject, error) in
            self?.stopAnimation()
            
            self?.resetTextFields()
            guard let self = `self` else{
                return
            }
            if responseObject != nil {
                
                if responseObject!["result"] as! String == "SUCCESS"{
                    self.otpVerificationViewModel.navigateToUserDetailsScreen(otp: otp, viewController: self)
                    AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_MOBILE_VERIFIED, params: [
                        "mobileNumber" : self.otpVerificationViewModel.contactNo ?? "","attributionType" : "otp","status" : "New","DeviceId": DeviceUniqueIDProxy().getDeviceUniqueId() ?? ""], uniqueField: AnalyticsUtils.deviceId)
                }else{
                    if let responseError = self.otpVerificationViewModel.getResponseError(responseObject: responseObject){
                        if responseError.errorCode == ServerErrorCodes.VERIFICATION_OTP_INCORRECT_ERROR{
                            self.handleUIForErrorCase()
                        }else{
                            ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                        }
                    }
                }
                
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
            
        }
    }
    
    @objc func handleUIForErrorCase(){
        activationCodeTextField1.backgroundColor = .white
        activationCodeTextField2.backgroundColor = .white
        activationCodeTextField3.backgroundColor = .white
        activationCodeTextField4.backgroundColor = .white
        ViewCustomizationUtils.addBorderToView(view: activationCodeTextField1, borderWidth: 1.0, color: .systemRed)
        ViewCustomizationUtils.addBorderToView(view: activationCodeTextField2, borderWidth: 1.0, color: .systemRed)
        ViewCustomizationUtils.addBorderToView(view: activationCodeTextField3, borderWidth: 1.0, color: .systemRed)
        ViewCustomizationUtils.addBorderToView(view: activationCodeTextField4, borderWidth: 1.0, color: .systemRed)
        activationCodeView.shake()
        errorMsgLabel.text = Strings.incorrect_verification_code
    }
    
   
    
    
    //MARK: Actions
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func resendOtpBtnClicked(_ sender: Any) {
        view.endEditing(false)
        if let user = otpVerificationViewModel.user{
            resendOTPToExistingUser(user: user)
        }else{
            resendOTPToNewUser()
        }
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.RESEND_OTP, params: ["DeviceId" : DeviceUniqueIDProxy().getDeviceUniqueId() ?? 0,"mobileNumber" : "\(String(describing: self.otpVerificationViewModel.contactNo))","attributionType" : "otp","status" : "New"], uniqueField: AnalyticsUtils.deviceId)
    }
    
    @IBAction func needSupportBtnClicked(_ sender: Any) {
        view.endEditing(false)
        MessageDisplay.displayInfoViewAlert(title: Strings.need_support_title, titleColor: nil, message: Strings.need_support_msg_new, infoImage: nil, imageColor: nil, isLinkBtnRequired: true, linkTxt: Strings.raise_ticket, linkImage: UIImage(named: "email_new"), buttonTitle: Strings.got_it_caps) {
            self.sendEmailToCustomerCare()
        }
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.OTP_NEED_SUPPORT, params: ["DeviceId" : DeviceUniqueIDProxy().getDeviceUniqueId() ?? 0], uniqueField: AnalyticsUtils.deviceId)
    }
    
}


//MARK: MFMailComposerDelegate

extension OTPVerificationViewController : MFMailComposeViewControllerDelegate{
    func sendEmailToCustomerCare(){
        HelpUtils.sendMailToSupportWithSubject(delegate: self, viewController: self, messageBody: nil,subject: Strings.otp_not_recieved, contactNo: otpVerificationViewModel.contactNo, image: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}

//MARK: UITextFieldDelegate
extension OTPVerificationViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if errorMsgLabel.text != nil && !errorMsgLabel.text!.isEmpty{
            errorMsgLabel.text = ""
            activationCodeTextField1.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: activationCodeTextField1, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
            activationCodeTextField2.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: activationCodeTextField2, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
            activationCodeTextField3.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: activationCodeTextField3, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
            activationCodeTextField4.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: activationCodeTextField4, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
        }
    }
}

//MARK: SessionManagerUIDelegate

extension OTPVerificationViewController : OTPVerificationViewModelDelegate{
    func startSpinning() {
        
        sessionLoadingView.isHidden = false
        sessionLoadingAnimationView.animation = Animation.named("loading_otp")
        sessionLoadingAnimationView.play()
        sessionLoadingAnimationView.loopMode = .loop
        
    }
    
    func stopSpinning() {
        
        sessionLoadingView.isHidden = true
        sessionLoadingAnimationView.stop()
        
    }
    
    
}

