//
//  LoginController.swift
//  Quickride
//
//  Created by KNM Rao on 18/09/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import MRCountryPicker
import NetCorePush


class LoginController: UIViewController, UITextFieldDelegate, SessionChangeCompletionListener,ResetPasswordDelegate, MRCountryPickerDelegate{
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet var loginButton: UIButton!
    
    
    @IBOutlet weak var countryPickerView: UIView!
    
    @IBOutlet weak var countryPickerflag: UIImageView!
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var countryPickerLabel: UILabel!
    
    @IBOutlet weak var forgotPasswordButton: UIButton!
    
    @IBOutlet weak var countryPicker: MRCountryPicker!
    
    @IBOutlet weak var seperationView: UIView!
    
    @IBOutlet weak var emptyFieldAlertLabel: UILabel!
    
    @IBOutlet weak var emptyFieldAlertHeightConstraint: NSLayoutConstraint!
    
    var appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var isKeyBoardVisible = false
    
    @IBOutlet weak var bottomSpaceToSuperView: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var PhoneNoSeperationView: UIView!
    
    @IBOutlet weak var passwordSeperationView: UIView!
    
    @IBAction func loginUser(_ sender: UIButton) {
        doLogin()
    }
    
    
    private var phoneNumber : String?
    private var password : String?
    var countryCode : String?
    
    func initializeDataBeforePresentingView(phone: String?, password: String?) {
        self.phoneNumber = phone
        self.password = password
    }
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToView(view: loginButton, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: seperationView, cornerRadius: 3.0)
         #if GRIDE
            signUpButton.isHidden = false
        #elseif MYRIDE
            signUpButton.isHidden = false
            forgotPasswordButton.setTitleColor(UIColor.red, for: .normal)
        #else
            signUpButton.isHidden = true
        #endif
        self.phoneTextField.delegate = self
        self.passwordTextField.delegate = self
        self.scrollView.isScrollEnabled = true
        self.scrollView.contentSize = CGSize(width: 320, height: 800)
        self.automaticallyAdjustsScrollViewInsets = false
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        SharedPreferenceHelper.setNotificationCount(notificationCount: -1)
        
        countryCode = AppConfiguration.DEFAULT_COUNTRY_CODE
        
        countryPicker?.countryPickerDelegate = self
        countryPicker?.setCountry(countryCode!)
        if (self.phoneNumber != nil) {
            self.phoneTextField.text = self.phoneNumber!
        }
        
        if (self.password != nil) {
            self.passwordTextField.text = self.password!
        }
        countryPickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(LoginController.selectCountryCode(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        phoneTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loginActionColorChange()
        self.seperationView.applyGradient(colours: [UIColor(netHex:0x74fb8f), UIColor(netHex:0x47c760)])
    }
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.countryPickerflag.image = flag
        self.countryPickerLabel.text = phoneCode
        self.countryLabel.text = countryCode
    }
    @objc func selectCountryCode(_ gesture : UITapGestureRecognizer){
        self.view.endEditing(false)
        let countryCodeSelector = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "CountryPickerViewController") as! CountryPickerViewController
        countryCodeSelector.initializeDataBeforePresenting(currentCountryCode: self.countryCode) { (name, countryCode, phoneCode, flag) in
            self.countryCode = countryCode
            self.countryPickerLabel.text = phoneCode
            self.countryPickerflag.image = flag
            self.countryLabel.text = countryCode
        }
        self.present(countryCodeSelector, animated: false, completion: {
            
        })
    }
    
    func doLogin() {
        AppDelegate.getAppDelegate().log.debug("")
        self.phoneTextField.endEditing(true)
        self.passwordTextField.endEditing(true)
        
        let validationErrorMsg = validateFieldsAndReturnErrorMsgIfAny()
        if (validationErrorMsg != nil) {
            self.emptyFieldAlertLabel.isHidden = false
            self.emptyFieldAlertHeightConstraint.constant = 20
            self.emptyFieldAlertLabel.text = "* " + validationErrorMsg!
            return
        }
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        
        let userDefaults = UserDefaults.standard
        let deviceToken = userDefaults.string(forKey: "deviceTokenString")
        var phoneCode = AppConfiguration.DEFAULT_COUNTRY_CODE_IND
        if countryPickerLabel.text != nil && countryPickerLabel.text?.isEmpty == false{
            phoneCode = countryPickerLabel.text!
        }

        let modelName = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion

        QuickRideProgressSpinner.startSpinner()
        UserRestClient.validateAndUpdateUserActiveSessionDetails(appVersionName: AppUtil.getCurrentAppVersionName(), userId: phoneTextField.text!, phoneCode: phoneCode, password: passwordTextField.text!, appName : AppConfiguration.APP_NAME, phoneModel: modelName + " " + systemVersion, uiViewController: self){
            responseObject, error in
            if responseObject != nil {
                AppDelegate.getAppDelegate().log.debug("Response in login is \(String(describing: responseObject)) and \(String(describing: error))")
                if responseObject!["result"] as! String == "SUCCESS" {
                    let user = Mapper<User>().map(JSONObject: responseObject!["resultData"])
                    let userId = user!.phoneNumber
                    if (deviceToken != nil) {
                        let deviceRegistrationHelper = DeviceRegistrationHelper(sourceViewController: self, phone: StringUtils.getStringFromDouble(decimalNumber : userId), deviceToken: deviceToken!)
                        deviceRegistrationHelper.registerDeviceTokenWithQRServer()
                    }
                    let password = self.passwordTextField.text!
                    let contactNo = self.phoneTextField.text!
                
                NetCoreInstallation.sharedInstance().netCorePushLogin(StringUtils.getStringFromDouble(decimalNumber: userId), block: nil)
                    
                    let profilePushDictionary = ["NAME": user?.userName,"MOBILE": StringUtils.getStringFromDouble(decimalNumber: user?.contactNo)]
                    NetCoreInstallation.sharedInstance().netCoreProfilePush(StringUtils.getStringFromDouble(decimalNumber: userId), payload:profilePushDictionary as [AnyHashable : Any], block:nil)
                    
                   
                    GCDUtils.GlobalUserInitiatedQueue.async(execute: { () -> Void in
                        SessionManagerController.sharedInstance.reinitializeUserSession(userId: StringUtils.getStringFromDouble(decimalNumber: userId), userPassword: password, contactNo: contactNo,countryCode: phoneCode, sessionChangeCompletionListener: self)
                    })

                }

                else if responseObject!["result"] as! String == "FAILURE" {
                    QuickRideProgressSpinner.stopSpinner()
                    let responseError = Mapper<ResponseError>().map(JSONObject:  responseObject!["resultData"])
                    if (responseError?.errorCode)! == ServerErrorCodes.USER_NOT_ACTIVATED_ERROR {
                        self.initializeDataAndNavigate(responseError: responseError!, countryCode: phoneCode)
                    }else if (responseError?.errorCode)! == ServerErrorCodes.ACCOUNT_SUSPENDED_BY_THE_USER {
                        self.navigateToActivationView(responseError: responseError!, suspended : true)
                    }
                    else if (responseError?.errorCode)! == ServerErrorCodes.USER_NOT_REGISTERED_ERROR {
                        self.navigateToRegistrationView(responseError: responseError!)
                    } else if (responseError?.errorCode)! == ServerErrorCodes.USER_SUBSCRIPTION_REQUIRED_ERROR{
                         UserDataCache.SUBSCRIPTION_STATUS = true
                        self.continueToApplication(deviceToken: deviceToken)
                    }
                    else if responseError?.errorCode == ServerErrorCodes.ACCOUNT_SUSPENDED_FOR_ETIQUETTE_VIOLATION{
                        MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self,handler: nil)
                    }
                    else {
                        DispatchQueue.main.async {
                            MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self,handler: nil)
                        }
                    }
                }
            }else{
                QuickRideProgressSpinner.stopSpinner()
                ErrorProcessUtils.handleError(error: error, viewController: self, handler: nil)
            }
        }
    }

    private func validateFieldsAndReturnErrorMsgIfAny() -> String? {
        AppDelegate.getAppDelegate().log.debug("")
        if (passwordTextField.text?.isEmpty == true ) && (phoneTextField.text?.isEmpty == true){
            self.passwordSeperationView.backgroundColor = Colors.red
            self.PhoneNoSeperationView.backgroundColor = Colors.red
            return Strings.fill_all_required_fields
        }
        if (phoneTextField.text?.isEmpty == true)
        {
            self.PhoneNoSeperationView.backgroundColor = Colors.red
            return Strings.fill_all_required_fields
        }
        if (passwordTextField.text?.isEmpty == true )
        {
            self.passwordSeperationView.backgroundColor = Colors.red
            return Strings.fill_all_required_fields
        }
        if (AppUtil.isValidPhoneNo(phoneNo: phoneTextField.text!, countryCode: self.countryPickerLabel.text)) {
            return nil
        }
        else {
            self.PhoneNoSeperationView.backgroundColor = Colors.red
            return Strings.phone_no_not_valid
        }
    }
    
    func initializeDataAndNavigate(responseError: ResponseError, countryCode: String){
        AppDelegate.getAppDelegate().log.debug("")
        QuickRideProgressSpinner.stopSpinner()
        DispatchQueue.main.async {
            MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: self, handler: { (result) in
                NewUserDataInitialiser(phoneNo : self.phoneTextField.text!,countryCode : countryCode, password : self.passwordTextField.text!, newUser: nil, userProfile: nil, isSuspendedUser : false,viewController : self).getUserAndInitializeSession()
            })
        }
    }
    func navigateToActivationView(responseError: ResponseError, suspended : Bool){
        AppDelegate.getAppDelegate().log.debug("")
        QuickRideProgressSpinner.stopSpinner()
        DispatchQueue.main.async {
            MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: self, handler: { (result) in
                let verificationViewController : VerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerificationViewController") as! VerificationViewController
                
                verificationViewController.initializeDataBeforePresenting(userId: self.phoneTextField.text!,countryCode : self.countryPickerLabel.text,password: self.passwordTextField.text!, email : nil,companyName : nil,userObj: nil, userProfile: nil,isSuspendedUser : suspended, resendCodeRequired : true)
                self.navigationController?.pushViewController(verificationViewController, animated: false)
            })
        }
    }
    
    func navigateToRegistrationView(responseError: ResponseError) {
        AppDelegate.getAppDelegate().log.debug("")
        DispatchQueue.main.async {
            QuickRideProgressSpinner.stopSpinner()
            MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: self, handler: { (result) in
                let registrationViewController  = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.registrationController) as! RegistrationBaseViewController
                registrationViewController.initializeDataBeforePresentingView(phone: self.phoneTextField.text!, password: self.passwordTextField.text!, phoneCode: self.countryPickerLabel.text,email: nil)
               self.navigationController?.view.layer.add(CustomExtensionUtility.transitionEffectWhilePushingView(), forKey: kCATransition)
                self.navigationController?.pushViewController(registrationViewController, animated: false)
            })
        }
    }
    
    func makeContainerViewController(){
        //        appDelegate.window = UIApplication.sharedApplication().keyWindow
        let containerViewController = ContainerViewController()
        
        appDelegate.window!.rootViewController = containerViewController
        //        appDelegate.window!.makeKeyAndVisible()
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("")
        let resetPasswordController = UIStoryboard(name: StoryBoardIdentifiers.resetpassword, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.resetPasswordViewController) as! ResetPasswordBaseController
        resetPasswordController.initializeDataBeforePresenting(phoneNumber: self.phoneTextField.text!, phoneCode: self.countryLabel.text!, domainName: nil, delegate: self)
    self.navigationController?.view.layer.add(CustomExtensionUtility.transitionEffectWhilePushingView(), forKey: kCATransition)
        self.navigationController?.pushViewController(resetPasswordController, animated: false)
    }
    
    // MARK: View Controller related methods
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        if (self.phoneNumber != nil) {
            self.phoneTextField.text = phoneNumber
        }
        self.navigationController?.isNavigationBarHidden = true
        self.emptyFieldAlertLabel.isHidden = true
        self.emptyFieldAlertHeightConstraint.constant = 0
        forgotPasswordButton.addTarget(self, action:#selector(LoginController.HoldForgotPasswordBtn(_:)), for: UIControl.Event.touchDown)
        forgotPasswordButton.addTarget(self, action:#selector(LoginController.HoldRelease(_:)), for: UIControl.Event.touchUpInside)
    }
    @objc func HoldRelease(_ sender:UIButton){
        forgotPasswordButton.backgroundColor = UIColor.white
        forgotPasswordButton.layer.borderColor = UIColor.clear.cgColor
    }
    @objc func HoldForgotPasswordBtn(_ sender:UIButton){
        forgotPasswordButton.backgroundColor = Colors.lightGrey
        ViewCustomizationUtils.addBorderToView(view: forgotPasswordButton, borderWidth: 1.0, color: Colors.lightGrey)
        ViewCustomizationUtils.addCornerRadiusToView(view: forgotPasswordButton, cornerRadius: 5.0)
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        loginActionColorChange()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(false)
        return false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sessionChangeOperationCompleted() {
        AppDelegate.getAppDelegate().log.debug("")
        if let userProfile = UserDataCache.getInstance()?.userProfile,let user = UserDataCache.getInstance()?.currentUser{
           CleverTapAnalyticsUtils.getInstance().trackProfileEvent(userProfile: userProfile, user: user)
        }
        
        DispatchQueue.main.async {
            QuickRideProgressSpinner.stopSpinner()
            let userNotifications = SharedPreferenceHelper.getRecentNotifications()
            LocationChangeListener.getInstance().refreshLocationUpdateRequirementStatus()
            if (userNotifications != nil && userNotifications!.isEmpty == false) {
                for notification in userNotifications!{
                    let notificationHandler: NotificationHandler? = NotificationHandlerFactory.getNotificationHandler(clientNotification: notification)
                    if notificationHandler != nil{
                        let notification = notificationHandler!.saveNotification(clientNotification: notification)
                        if notification != nil{
                            if NotificationStore.getInstance().totalNotifications[notification!.notificationId!] != nil{
                                let notificationHandler = NotificationHandlerFactory.getNotificationHandler(clientNotification: notification!)
                                if NotificationStore.notificationAction == nil{
                                    notificationHandler?.displayNotification(clientNotification: notification!)
                                }else{
                                    notificationHandler?.handleAction(identifier: NotificationStore.notificationAction!, userNotification: notification!)
                                }
                            }
                        }
                    }
                }
            }
            NotificationStore.getInstance().getAllPendingNotificationsFromServer()
            SharedPreferenceHelper.deleteRecentNotification()
            
            if SharedPreferenceHelper.getViewPrefixForDeepLink() != nil
            {
                
              ViewControllerNavigationUtils.openSpecificViewController()
            }else{
              RideManagementUtils.checkAnyRideEtiquetteToDisplayAndNavigate(isFromSignupFlow: false, viewController: self, handler: nil)
            }
            
        }
    }
    
    func sessionChangeOperationFailed(exceptionCause : SessionManagerOperationFailedException?) {
        AppDelegate.getAppDelegate().log.debug("")
        GCDUtils.GlobalMainQueue.async(execute: { () -> Void in
            QuickRideProgressSpinner.stopSpinner()
        })
        
        
        if (exceptionCause == SessionManagerOperationFailedException.NetworkConnectionNotAvailable) {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
        }
        else if (exceptionCause == SessionManagerOperationFailedException.SessionChangeOperationTimedOut) {
            GCDUtils.GlobalMainQueue.async() { () -> Void in
                ErrorProcessUtils.displayRequestTimeOutError(viewController: self, handler: nil)
            }
        }
        else {
            ErrorProcessUtils.displayServerError(viewController: self)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.emptyFieldAlertLabel.isHidden = true
        self.emptyFieldAlertHeightConstraint.constant = 0
        self.PhoneNoSeperationView.backgroundColor = Colors.lightGrey
        self.passwordSeperationView.backgroundColor = Colors.lightGrey
        if textField == phoneTextField{
            addDoneButton(textField: phoneTextField)
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        bottomSpaceToSuperView.constant = 200
        
    }
    
    func loginActionColorChange(){
        if phoneTextField.text != nil && phoneTextField.text?.isEmpty == false && passwordTextField.text != nil && passwordTextField.text?.isEmpty == false{
            CustomExtensionUtility.changeBtnColor(sender: self.loginButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            loginButton.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: self.loginButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
            loginButton.isUserInteractionEnabled = false
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        bottomSpaceToSuperView.constant = 55
        
    }
    
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        
        textField.inputAccessoryView = keyToolBar
    }
    func receiveResetPhoneNumber(phoneNumber: String) {
        self.phoneNumber = phoneNumber
    }
    
    @IBAction func signUpClicked(_ sender: Any) {
        let registrationViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.registrationController) as! RegistrationBaseViewController
        registrationViewController.initializeDataBeforePresentingView(phone: self.phoneTextField.text!, password: self.passwordTextField.text!, phoneCode: self.countryPickerLabel.text,email: nil)
        self.navigationController?.pushViewController(registrationViewController, animated: false)
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.view.layer.add(CustomExtensionUtility.transitionEffectWhilePopingView(), forKey:kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        CustomExtensionUtility.changeBtnColor(sender: self.loginButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
        loginButton.isUserInteractionEnabled = false
        return true
    }
    
    func continueToApplication(deviceToken : String?){
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.getCurrentUser(phoneNo: self.phoneTextField.text!, countryCode: countryPickerLabel.text!, appName: AppConfiguration.APP_NAME, viewController: self) { (responseObject, error) in
                      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                        let user = Mapper<User>().map(JSONObject: responseObject!["resultData"])
                        let userId = user!.phoneNumber
                        if (deviceToken != nil) {
                            let deviceRegistrationHelper = DeviceRegistrationHelper(sourceViewController: self, phone: StringUtils.getStringFromDouble(decimalNumber : userId), deviceToken: deviceToken!)
                            deviceRegistrationHelper.registerDeviceTokenWithQRServer()
                        }
                        let modelName = UIDevice.current.model
                        let systemVersion = UIDevice.current.systemVersion
                        UserRestClient.updateUserPhoneModel(userId: StringUtils.getStringFromDouble(decimalNumber : userId), phoneModal: modelName + " " + systemVersion, uiViewController: self, completionController: { (responseObject, error) -> Void in
                            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                                AppDelegate.getAppDelegate().log.debug("Updating PhoneModel \(modelName)\(systemVersion)")
                            }
                        })
            
                        let phoneCode = self.phoneTextField.text!
                        let password = self.passwordTextField.text!
                        let countryCode = self.countryPickerLabel.text!
            
                        GCDUtils.GlobalUserInitiatedQueue.async(execute: { () -> Void in
                            SessionManagerController.sharedInstance.reinitializeUserSession(userId: StringUtils.getStringFromDouble(decimalNumber: userId), userPassword:password , contactNo: phoneCode,countryCode: countryCode, sessionChangeCompletionListener: self)
                        })
            
            
                      }else{
                        QuickRideProgressSpinner.stopSpinner()
                         ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                      }
        }
   }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
