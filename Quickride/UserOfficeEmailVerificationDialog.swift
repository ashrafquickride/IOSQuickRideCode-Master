//
//  UserOfficeEmailVerificationDialog.swift
//  Quickride
//
//  Created by QuickRideMac on 6/3/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import MessageUI

protocol UserEmailVerificationReceiver
{
    func emailVerified()
}
class UserOfficeEmailVerificationDialog: ModelViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var verificationDialogView: UIView!
    
    @IBOutlet weak var verificationCodeEditText1: UITextField!
    
    @IBOutlet weak var verificationCodeEditText2: UITextField!
    
    @IBOutlet weak var verificationCodeEditText3: UITextField!
    
    @IBOutlet weak var verificationCodeEditText4: UITextField!
    
    @IBOutlet weak var ResendOTPBtn: UIButton!
    
    @IBOutlet weak var HelpBtn: UIButton!
    
    @IBOutlet weak var VerifyBtn: UIButton!
    
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var verificationViewCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelErrorMsg: UILabel!
    
    var isKeyBoardVisible = false
    var profileId : String?
    var officeEmail : String?
    var viewController : UIViewController?
    var receiver : UserEmailVerificationReceiver?
    var clientConfiguration : ClientConfigurtion?

    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        definesPresentationContext = true
        self.verificationCodeEditText1.delegate = self
        self.verificationCodeEditText2.delegate = self
        self.verificationCodeEditText3.delegate = self
        self.verificationCodeEditText4.delegate = self
        verificationCodeEditText1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        verificationCodeEditText2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        verificationCodeEditText3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        verificationCodeEditText4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        
        verificationCodeEditText1.attributedPlaceholder = NSAttributedString(string: "-",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        verificationCodeEditText2.attributedPlaceholder = NSAttributedString(string: "-",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        verificationCodeEditText3.attributedPlaceholder = NSAttributedString(string: "-",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        verificationCodeEditText4.attributedPlaceholder = NSAttributedString(string: "-",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        let emailVerificationInitiatedDate = ConfigurationCache.getInstance()?.emailVerificationInitiatedDate
        if emailVerificationInitiatedDate != nil && emailVerificationInitiatedDate != 0{
            let date = DateUtils.getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: (emailVerificationInitiatedDate!/1000)), dateFormat: DateUtils.DATE_FORMAT_dd_MM_yyyy)
            titleLabel.text = String(format: Strings.otp_sent_to_email_on_initiated_date, arguments: [self.officeEmail!, date!])
        }
        else{
            titleLabel.text = String(format: Strings.otp_sent_to_email, arguments: [self.officeEmail!])
        }
        ViewCustomizationUtils.addCornerRadiusToView(view: verificationDialogView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: VerifyBtn, cornerRadius: 5.0)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserOfficeEmailVerificationDialog.dismissView(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(UserOfficeEmailVerificationDialog.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(UserOfficeEmailVerificationDialog.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func initializeDataBeforePresentingView(profileId : String?, officeEmail : String?, viewController: UIViewController?, receiver : UserEmailVerificationReceiver)
    {
        self.profileId = profileId
        self.officeEmail = officeEmail
        self.viewController = viewController
        self.receiver = receiver
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CustomExtensionUtility.changeBtnColor(sender: self.VerifyBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
    }
    
    @objc func dismissView(_ sender: UITapGestureRecognizer)
    {   
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton(textField: textField)
        self.labelErrorMsg.isHidden = true
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        let text = textField.text
        if text?.utf16.count == 1{
            
            switch textField {
            case verificationCodeEditText1:
                verificationCodeEditText2.becomeFirstResponder()
            case verificationCodeEditText2:
                verificationCodeEditText3.becomeFirstResponder()
            case verificationCodeEditText3:
                verificationCodeEditText4.becomeFirstResponder()
            case verificationCodeEditText4:
                verificationCodeEditText4.resignFirstResponder()
            default:
                break
            }
            
        }
    }
    
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        textField.inputAccessoryView = keyToolBar
    }
    func textFieldShouldReturn(_ textField : UITextField) -> Bool{
        textField.endEditing(true)
        return false
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        verificationViewCenterYConstraint.constant = -120
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            verificationViewCenterYConstraint.constant = 0
            return
        }
    }
    
    @IBAction func resendOTPBtnTapped(_ sender: Any) {
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.resendVerificationEmail(userId: self.profileId!, viewController: self, completionHandler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( Strings.verification_resend_toast)
            }
            else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
    @IBAction func HelpBtnTapped(_ sender: Any) {
        sendEmailToSupport()
    }
    @IBAction func VerifyBtnTapped(_ sender: Any) {
        
        if verificationCodeEditText1.text == nil || verificationCodeEditText1.text!.isEmpty || verificationCodeEditText2 == nil || verificationCodeEditText2.text!.isEmpty || verificationCodeEditText3 == nil || verificationCodeEditText3.text!.isEmpty || verificationCodeEditText4 == nil || verificationCodeEditText4.text!.isEmpty
        {
            MessageDisplay.displayAlert(messageString: Strings.verification_code,  viewController: self,handler: nil)
            return
        }
        let verificationText = verificationCodeEditText1.text! + verificationCodeEditText2.text! + verificationCodeEditText3.text! + verificationCodeEditText4.text!
        QuickRideProgressSpinner.startSpinner()
        
        UserRestClient.passUserOfficeEmailVerification(userId: Double(self.profileId!)!, email: self.officeEmail!, verificationCode: verificationText , viewController: self, responseHandler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
         
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
              self.view.removeFromSuperview()
              self.removeFromParent()
                self.checkGenderAndUpdateVerificationStatus()
                self.receiver!.emailVerified()
                self.view.removeFromSuperview()
                self.removeFromParent()
            }else if responseObject != nil && responseObject!["result"] as! String == "FAILURE"{
              
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                self.verificationCodeEditText1.text = ""
                self.verificationCodeEditText2.text = ""
                self.verificationCodeEditText3.text = ""
                self.verificationCodeEditText4.text = ""
                self.labelErrorMsg.isHidden = false
                self.labelErrorMsg.text = ErrorProcessUtils.getErrorMessageFromErrorObject(error: responseError!)
                
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: self, handler: nil)
                
            }
            
        })
        
    }
    
    func sendEmailToSupport(){
        AppDelegate.getAppDelegate().log.debug("sendEmailToSupport()")
        if MFMailComposeViewController.canSendMail() {
            let userProfile = UserDataCache.getInstance()?.userProfile
            let mailComposeViewController = MFMailComposeViewController()
            var subject = ""
            if UserDataCache.getInstance()!.isReVerifyShouldDisplay != nil && UserDataCache.getInstance()!.isReVerifyShouldDisplay!{
            subject = Strings.reverification_mail_not_received
            }
            else{
              subject = Strings.verification_mail_not_received
            }
            if userProfile?.userName != nil{
                subject = subject+(userProfile?.userName)!
            }
            if userProfile?.userId != nil{
                subject = subject + " UserId: \(StringUtils.getStringFromDouble(decimalNumber : userProfile?.userId))"
            }
            subject = subject + " ContactNo:" + QRSessionManager.getInstance()!.getCurrentSession().contactNo
            if userProfile?.email != nil{
                subject = subject + " Email:"+(userProfile?.email)!
            }
            if userProfile?.companyName != nil
            {
                subject = subject + " CompanyName:"+(userProfile?.companyName)!
            }
            mailComposeViewController.setSubject(subject)
            mailComposeViewController.mailComposeDelegate = self
            var recepients = [String]()
            recepients.append(clientConfiguration!.verificationSupportMail)
            mailComposeViewController.setToRecipients(recepients)
            if let fileData = NSData(contentsOf: AppDelegate.getAppDelegate().logPath! as URL) {
                mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName)
            }
            let logPathBackup = AppDelegate.getAppDelegate().logPathBackup
            if logPathBackup != nil{
                if let fileData = NSData(contentsOf: logPathBackup! as URL){
                    mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName_Backup)
                }
            }
            self.present(mailComposeViewController, animated: false, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_send_mail)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
    
    func checkGenderAndUpdateVerificationStatus(){
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData()
        if profileVerificationData != nil && userProfile != nil{
            if userProfile!.gender == User.USER_GENDER_FEMALE && profileVerificationData!.emailVerified{
                profileVerificationData!.profileVerified = true
                
            }else if profileVerificationData!.emailVerified && profileVerificationData!.imageVerified {
                profileVerificationData!.profileVerified = true
            }
          UserDataCache.getInstance()?.storeProfileVerificationDataForCurrentUser(profileVerificationData: profileVerificationData!)
        }
        
        
    }
}
