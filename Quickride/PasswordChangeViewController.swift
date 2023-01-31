//
//  PasswordChangeViewController.swift
//  Quickride
//
//  Created by KNM Rao on 02/11/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import UIKit
import ObjectMapper

class PasswordChangeViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var bottomSpaceToSuperView: NSLayoutConstraint!
    
    @IBOutlet var changePasswordButton: UIButtonBordered!
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    @IBOutlet weak var emailIdLabel: UILabel!
    @IBOutlet weak var seperationView: UIView!
    
    @IBOutlet weak var errorAlertLabel: UILabel!
    
    @IBOutlet weak var errorAlertLabelHeight: NSLayoutConstraint!
    
    @IBOutlet weak var currentPasswdSeperationView: UIView!
    
    @IBOutlet weak var newPasswdSeperationView: UIView!
    
    @IBOutlet weak var repeatPasswdSeperationView: UIView!
    var profile : UserProfile?
    
    var isKeyBoardVisible = false
    var isSecure = true
    
    var appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var userId : String?
    var phoneNumber: String?
    var phoneCode: String?
    
    func initializeDataBeforePresenting(phoneNumber : String,  phoneCode : String,isSecure : Bool){
        AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresenting()")
        self.phoneNumber = phoneNumber
        self.phoneCode = phoneCode
        self.isSecure = isSecure
        
    }
    
    @IBAction func changePassword(_ sender: UIButton) {
        self.view.endEditing(false)
        doChangePassword()
    }
    
    private func doChangePassword() {
        AppDelegate.getAppDelegate().log.debug("doChangePassword()")
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        
        if ((currentPasswordTextField.text?.isEmpty)! || (newPasswordTextField.text?.isEmpty)! || (repeatPasswordTextField.text?.isEmpty)!){
            self.errorAlertLabel.isHidden = false
            self.errorAlertLabelHeight.constant = 35
            self.errorAlertLabel.text = "* " + Strings.fill_all_required_fields
            self.currentPasswdSeperationView.backgroundColor = Colors.lightGrey
            self.newPasswdSeperationView.backgroundColor = Colors.lightGrey
            self.repeatPasswdSeperationView.backgroundColor = Colors.lightGrey
        }
        else {
            if self.checkRepeatPassword(newPassword: newPasswordTextField.text!, oldPassword: repeatPasswordTextField.text!) && self.checkOldAndNewPassword(oldPassword: self.currentPasswordTextField.text! , newPassword: self.newPasswordTextField.text!){
                QuickRideProgressSpinner.startSpinner()
                
                var putBodyDictionary : [String : String] = [String : String]()
                putBodyDictionary["phone"] = self.userId!
                putBodyDictionary["oldPassword"] = self.currentPasswordTextField.text!
                putBodyDictionary["newPassword"] = self.newPasswordTextField.text!
                
                UserRestClient.changePassword(putBodyParams: putBodyDictionary ,isSecure: self.isSecure,uiViewController: self, completionHandler: { (responseObject, error) -> Void in
                    if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                        QuickRideProgressSpinner.stopSpinner()
                        QRSessionManager.getInstance()?.getCurrentSession().userPassword = self.newPasswordTextField.text!
                        var user : User?
                        if let userObject = UserDataCache.getInstance()?.getUser(){
                            user = userObject
                            user?.password = self.newPasswordTextField.text!
                            UserDataCache.getInstance()?.storeUSer(userId: self.userId!, user: user!)
                            SharedPreferenceHelper.storeLoggedInUserPwd(password: self.newPasswordTextField.text!)
                        }
                        DispatchQueue.main.async(execute: { () -> Void in
                            UIApplication.shared.keyWindow?.makeToast(message: Strings.password_changed_successful)
                            self.navigateToLoginDisplay()
                        })
                    }
                    else {
                        QuickRideProgressSpinner.stopSpinner()
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                    }
                })
            }
        }
    }
    
    func navigateToLoginDisplay(){
        var loginViewController : UIViewController?
        if self.navigationController != nil{
            for viewController in self.navigationController!.viewControllers{
                if viewController.isKind(of: LoginController.classForCoder()){
                    loginViewController = viewController
                }
            }
        }
        if loginViewController == nil{
            self.navigationController?.popViewController(animated: false)
        }else{
            self.navigationController?.popToViewController(loginViewController!, animated: false)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        self.errorAlertLabel.isHidden = true
        self.errorAlertLabelHeight.constant = 0
    }
    
    func checkRepeatPassword(newPassword: String, oldPassword: String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("checkRepeatPassword()")
        if newPassword != oldPassword{
            self.errorAlertLabel.isHidden = false
            self.errorAlertLabelHeight.constant = 35
            self.errorAlertLabel.text = "* " + Strings.new_and_cnfrm_pwd_match
            self.newPasswdSeperationView.backgroundColor = Colors.lightGrey
            self.repeatPasswdSeperationView.backgroundColor = Colors.lightGrey
            self.newPasswordTextField.text = nil
            self.newPasswordTextField.placeholder = Strings.new
            self.repeatPasswordTextField.text = nil
            self.repeatPasswordTextField.placeholder = Strings.confirm
            return false
        }else{
            return true
        }
    }
    
    func checkOldAndNewPassword(oldPassword : String, newPassword : String) -> Bool{
        AppDelegate.getAppDelegate().log.debug("checkOldAndNewPassword()")
        if oldPassword == newPassword {
            self.errorAlertLabel.isHidden = false
            self.errorAlertLabelHeight.constant = 35
            self.errorAlertLabel.text = "* " + Strings.giving_same_pass
            self.newPasswdSeperationView.backgroundColor = Colors.lightGrey
            self.repeatPasswdSeperationView.backgroundColor = Colors.lightGrey
            self.newPasswordTextField.text = nil
            self.newPasswordTextField.placeholder = Strings.new
            self.repeatPasswordTextField.text = nil
            self.repeatPasswordTextField.placeholder = Strings.confirm
            return false
        }else{
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToView(view: changePasswordButton, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: seperationView, cornerRadius: 3.0)
        // Do any additional setup after loading the view.
        #if WERIDE
        profile = UserDataCache.getInstance()?.getLoggedInUserProfile()?.copy() as? UserProfile
        
        self.emailIdLabel.text = "For" + " " + profile!.email!
        
        NotificationCenter.default.addObserver(self, selector: #selector(PasswordChangeViewController.keyBoardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PasswordChangeViewController.keyBoardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        #else
        handleBrandingChanges()
        #endif
        
        if self.userId == nil {
            self.userId = QRSessionManager.getInstance()?.getUserId()
        }
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.currentPasswordTextField.delegate = self
        self.newPasswordTextField.delegate = self
        self.repeatPasswordTextField.delegate = self
        self.scrollView.isScrollEnabled = true
        
        self.automaticallyAdjustsScrollViewInsets = false
        currentPasswordTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        newPasswordTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        if userId == "0" && phoneNumber != nil{
            self.currentPasswordTextField.placeholder = Strings.received_password
            self.newPasswordTextField.placeholder = Strings.new_password
            self.repeatPasswordTextField.placeholder = Strings.confirm_password
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.getUserIdForPhoneNo(phoneNo: phoneNumber!, countryCode: phoneCode, uiViewController: self, completionController: { (responseObject, error) -> Void in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.userId = StringUtils.getStringFromDouble(decimalNumber: (responseObject!["resultData"] as? Double))
                }
                else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            })
        }
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        changePasswordColorChange()
        self.seperationView.applyGradient(colours: [UIColor(netHex:0x74fb8f), UIColor(netHex:0x47c760)])
    }
    func handleBrandingChanges(){
        changePasswordButton.backgroundColor = Colors.mainButtonColor
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func backButtonAction(_ sender: Any) {
        self.navigationController?.view.layer.add(CustomExtensionUtility.transitionEffectWhilePopingView(), forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
    
    func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            bottomSpaceToSuperView.constant = keyBoardSize.height
        }
    }
    func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        bottomSpaceToSuperView.constant = 0
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        changePasswordColorChange()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.errorAlertLabel.isHidden = true
        self.errorAlertLabelHeight.constant = 0
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        CustomExtensionUtility.changeBtnColor(sender: self.changePasswordButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
        changePasswordButton.isUserInteractionEnabled = false
        return true
    }
    
    func changePasswordColorChange(){
        if currentPasswordTextField.text != nil && currentPasswordTextField.text?.isEmpty == false && newPasswordTextField.text != nil && newPasswordTextField.text?.isEmpty == false && repeatPasswordTextField.text != nil && repeatPasswordTextField.text?.isEmpty == false{
            CustomExtensionUtility.changeBtnColor(sender: self.changePasswordButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            changePasswordButton.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: self.changePasswordButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
            changePasswordButton.isUserInteractionEnabled = false
        }
    }
    
}
