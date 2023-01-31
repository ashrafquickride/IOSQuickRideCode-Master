//
//  VerficationController.swift
//  Quickride
//
//  Created by KNM Rao on 18/09/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import MessageUI


class VerificationViewController : UIViewController, UITextFieldDelegate,MFMailComposeViewControllerDelegate
{
    
    var userId : String?
    var countryCode : String?
    var password : String!
    var userObj : User?
    var email :String?
    var companyName :String?
    var userProfile : UserProfile?
    var isSuspendedUser : Bool = false
    var isVerified : Bool = false
    var isKeyBoardVisible = false
    var sessionIntialisationInProgress = false
    var resendCodeRequired = false
    @IBOutlet weak var verificationtextfield1: UITextField!
    @IBOutlet weak var verificationTextField2: UITextField!
    @IBOutlet weak var verificationTextField3: UITextField!
    @IBOutlet weak var verificationTextField4: UITextField!
    
    @IBOutlet weak var needHelpLabel: UIButton!
    
    @IBOutlet var verificationTextLabel1: UILabel!
    @IBOutlet var otpErrorMsg: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var resendOtpTopSpaceConstraint: NSLayoutConstraint!
    
    private static let ACTIVATE_USER = 01
    private static let RESEND_ACTIVATION_CODE = 02
    
    @IBAction func resendActivationCode(_ sender: UIButton) {
        self.resendActivationCode()
    }
    func initializeDataBeforePresenting(userId : String,countryCode : String?,password : String,email : String?,companyName : String?,userObj : User?,userProfile : UserProfile?,isSuspendedUser : Bool,resendCodeRequired : Bool){
        self.userId = userId
        self.countryCode = countryCode
        self.password = password
        self.userObj = userObj
        self.userProfile = userProfile
        self.isSuspendedUser = isSuspendedUser
        self.resendCodeRequired = resendCodeRequired
        self.email = email
        self.companyName = companyName
    }
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.verificationtextfield1.delegate = self
        self.verificationTextField2.delegate = self
        self.verificationTextField3.delegate = self
        self.verificationTextField4.delegate = self
        self.automaticallyAdjustsScrollViewInsets = false
        
     verificationtextfield1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        verificationTextField2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        verificationTextField3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        verificationTextField4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
       
        
        verificationtextfield1.attributedPlaceholder = NSAttributedString(string: "-",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        verificationTextField2.attributedPlaceholder = NSAttributedString(string: "-",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        verificationTextField3.attributedPlaceholder = NSAttributedString(string: "-",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        verificationTextField4.attributedPlaceholder = NSAttributedString(string: "-",
                                                                          attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
      
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        verificationTextLabel1.text = String(format: Strings.we_sent_activationcode, userId!)
        needHelpLabel.setTitle(clientConfiguration!.emailForSupport, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if resendCodeRequired || isSuspendedUser
        {
            self.resendActivationCode()
        }
        
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        let text = textField.text
        if text?.utf16.count == 1{
            
            switch textField {
            case verificationtextfield1:
                verificationTextField2.becomeFirstResponder()
            case verificationTextField2:
                verificationTextField3.becomeFirstResponder()
            case verificationTextField3:
                verificationTextField4.becomeFirstResponder()
            case verificationTextField4:
                verificationTextField4.resignFirstResponder()
                doActivateUser()
            default:
                break
            }
            
        }
    }
    private func resendActivationCode() {
        AppDelegate.getAppDelegate().log.debug("")
        self.view.endEditing(false)
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        QuickRideProgressSpinner.startSpinner()
       
        var putBodyDictionary = ["phone" : self.userId!]
        putBodyDictionary[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
        putBodyDictionary[User.FLD_COUNTRY_CODE] = countryCode
        UserRestClient.resendVerficiationCode(putBodyDictionary: putBodyDictionary, uiViewController: self, completionHandler: {
            
            responseObject, error in
                QuickRideProgressSpinner.stopSpinner()
            
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                AppDelegate.getAppDelegate().log.debug("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
                if self.isSuspendedUser || self.resendCodeRequired{
                    UIApplication.shared.keyWindow?.makeToast(message: Strings.activation_code_resend)
                }
                else{
                    UIApplication.shared.keyWindow?.makeToast(message: Strings.activation_code_resent)
                }
            }
            else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }


    // MARK: ViewController specific methods
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    private func doActivateUser()
    {
        AppDelegate.getAppDelegate().log.debug("")
        if verificationtextfield1.text?.isEmpty == true || verificationTextField2.text?.isEmpty ==  true || verificationTextField3.text?.isEmpty ==  true || verificationTextField4.text?.isEmpty == true {
            MessageDisplay.displayAlert(messageString: Strings.enter_activation_code, viewController: self,handler: nil)
            return
        }
        
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        activateUser()
    }
    
    func activateUser(){
        QuickRideProgressSpinner.startSpinner()
        let verificationText = verificationtextfield1.text! + verificationTextField2.text! + verificationTextField3.text! + verificationTextField4.text!
        UserRestClient.verifyUser(phoneNumber: self.userId!, activationCode: verificationText.trimmingCharacters(in: NSCharacterSet.whitespaces), phoneCode :countryCode, activationStatus: nil, uiViewController: self){
            responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            self.handleResponseAfterVerification(responseObject: responseObject, error: error)
        }
    }
    
    func handleResponseAfterVerification(responseObject : NSDictionary?,error : NSError?){
        AppDelegate.getAppDelegate().log.debug("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
        if responseObject != nil {
            if responseObject!["result"] as! String == "SUCCESS"
            {
                var points = responseObject!["resultData"] as? Int
                if points == nil{
                    points = 0
                }
                UserDataCache.storeTotalBonusPoints(totalBonusPoints: points!)
                UserSessionInitialiser(phoneNo : self.userId!,countryCode : self.countryCode,password : self.password, newUser: nil, userProfile: nil, isSuspendedUser : self.isSuspendedUser,viewController : self).getUserAndInitializeSession()
            }
            else if responseObject!["result"] as! String == "FAILURE"{
                self.verificationtextfield1.text = ""
                self.verificationTextField2.text = ""
                self.verificationTextField3.text = ""
                self.verificationTextField4.text = ""
                DispatchQueue.main.async {
                    let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                    self.otpErrorMsg.isHidden = false
                    self.otpErrorMsg.text = ErrorProcessUtils.getErrorMessageFromErrorObject(error: responseError!)
                    self.resendOtpTopSpaceConstraint.constant = 90
                }
            }
        }
        else {
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    {
        let threshold = 1
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton()
        otpErrorMsg.isHidden = true
        self.resendOtpTopSpaceConstraint.constant = 40
        self.scrollView.contentOffset = CGPoint(x: 0, y: textField.frame.origin.y + 100)
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.scrollView.contentOffset = CGPoint(x: 0, y: 0)
    }
    func addDoneButton(){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        verificationtextfield1.inputAccessoryView = keyToolBar
        verificationTextField2.inputAccessoryView = keyToolBar
        verificationTextField3.inputAccessoryView = keyToolBar
        verificationTextField4.inputAccessoryView = keyToolBar
    }
    
    @IBAction func backButtonAction(_ sender: Any) {
        self.view.endEditing(false)
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func neeHelpAction(_ sender: Any)
    {
        AppDelegate.getAppDelegate().log.debug("")
        self.view.endEditing(false)
        if MFMailComposeViewController.canSendMail() {
            
            let modelName = UIDevice.current.model
            let systemVersion = UIDevice.current.systemVersion
            
            let mailComposeViewController = MFMailComposeViewController()
            
            var subject = Strings.otp_not_recieved
            if self.userProfile != nil && self.userProfile!.userName != nil
            {
                subject = subject+" - "+"Name : "+self.userProfile!.userName! + "- Phone : "+self.userId!
            }
            else
            {
                subject = subject + "Phone : "+self.userId!
            }
            #if WERIDE
                subject = subject + "Device Information : "+modelName+","+systemVersion+"- WR App Version : "+AppConfiguration.APP_CURRENT_VERSION_NO
            #elseif GRIDE
                subject = subject + "Device Information : "+modelName+","+systemVersion+"- GR App Version : "+AppConfiguration.APP_CURRENT_VERSION_NO
            #elseif MYRIDE
                subject = subject + "Device Information : "+modelName+","+systemVersion+"- MR App Version : "+AppConfiguration.APP_CURRENT_VERSION_NO
            #else
                subject = subject + "- Device Information : "+modelName+","+systemVersion+"- QR App Version : "+AppConfiguration.APP_CURRENT_VERSION_NO
            #endif
            
            mailComposeViewController.setSubject(subject)
            mailComposeViewController.mailComposeDelegate = self
            
            var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
            if clientConfiguration == nil{
                clientConfiguration = ClientConfigurtion()
            }
            var recepients = [String]()
            recepients.append(clientConfiguration!.emailForSupport)
            mailComposeViewController.setToRecipients(recepients)
            
            let logPath = AppDelegate.getAppDelegate().logPath
            if logPath != nil{
                if let fileData = NSData(contentsOf: AppDelegate.getAppDelegate().logPath! as URL) {
                    mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName)
                }
            }
            
            let logPathBackup = AppDelegate.getAppDelegate().logPathBackup
            if logPathBackup != nil{
                if let fileData = NSData(contentsOf: logPathBackup! as URL){
                    mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName_Backup)
                }
            }
            self.present(mailComposeViewController, animated: false, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.makeToast(message: Strings.cant_send_mail)
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}
