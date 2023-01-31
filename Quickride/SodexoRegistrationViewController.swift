//
//  SodexoRegistrationViewController.swift
//  Quickride
//
//  Created by Halesh on 05/08/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import MessageUI

class SodexoRegistrationViewController: UIViewController,UITextFieldDelegate,MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var pinCodeTextField: UITextField!
    
    @IBOutlet weak var stateNameTextField: UITextField!
    
    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var editView: UIView!
    
    @IBOutlet weak var regSuccessView: UIView!
    
    @IBOutlet weak var homeNoTextField: UITextField!
    
    @IBOutlet weak var streatTextField: UITextField!
    
    @IBOutlet weak var areaTextField: UITextField!
    
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var addressView: UIView!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var errorLabelHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var queryEmailBtn: UIButton!
    
    @IBOutlet weak var firstContactNo: UIButton!
    
    @IBOutlet weak var secondContactNo: UIButton!
    
    var isKeyBoardVisible : Bool = false
    var cardStatus : String?
    
    func initializeView(cardStatus: String?){
        self.cardStatus = cardStatus
    }
    override func viewDidLoad() {
        if cardStatus == FuelCardRegistration.PENDING{
            regSuccessView.isHidden = false
            editView.isHidden = true
        }else{
            firstNameTextField.delegate = self
            lastNameTextField.delegate = self
            lastNameTextField.delegate = self
            homeNoTextField.delegate = self
            streatTextField.delegate = self
            areaTextField.delegate = self
            pinCodeTextField.delegate = self
            NotificationCenter.default.addObserver(self, selector: #selector(SodexoRegistrationViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(SodexoRegistrationViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
            firstNameTextField.autocapitalizationType = UITextAutocapitalizationType.words
            lastNameTextField.autocapitalizationType = UITextAutocapitalizationType.words
            cityTextField.autocapitalizationType = UITextAutocapitalizationType.words
            fillUserDetails()
            self.addressView.isHidden = true
            scrollView.isScrollEnabled = false
            pinCodeTextField.becomeFirstResponder()
        }
        self.automaticallyAdjustsScrollViewInsets = false
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToView(view: submitButton, cornerRadius: 8.0)
        CustomExtensionUtility.changeBtnColor(sender: self.submitButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
    }
    func fillUserDetails(){
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        if let firstName = userProfile?.userName?.components(separatedBy: " ").first{
            firstNameTextField.text = firstName
        }
        if let range = userProfile?.userName?.range(of: " ") {
            let LastName = userProfile?.userName?[range.upperBound...]
            lastNameTextField.text = String(LastName!)
        } 
    }
    
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            scrollViewBottomSpaceConstraint.constant = keyBoardSize.height + 35
            
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        scrollViewBottomSpaceConstraint.constant = 0
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabelHeightConstraint.constant = 0
        if textField == pinCodeTextField{
            addDoneButton(textField: pinCodeTextField)
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 0))
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == firstNameTextField{
            threshold = 25
        }else if textField == lastNameTextField{
            threshold = 25
        }else if textField == homeNoTextField{
            threshold = 50
        }else if textField == streatTextField{
            threshold = 50
        }else if textField == areaTextField{
            threshold = 50
        }else if textField == pinCodeTextField{
            threshold = 6
        }else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        let newLength = currentCharacterCount + string.count - range.length
        
        if range.length + range.location > currentCharacterCount{
            return false
        }else if newLength > threshold!{
            return false
        }else if textField == homeNoTextField || textField == streatTextField || textField == areaTextField{
            return UserProfileValidationUtils.validateStringFromCertainCharacters(string: string, ristrictedCharacters: ".;/()@!")
        }else{
            return true
        }
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        self.view.endEditing(false)
        if validateFields(){
            QuickRideProgressSpinner.startSpinner()
            let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
            AccountRestClient.getSodexoCard(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, mobileNo: SharedPreferenceHelper.getLoggedInUserContactNo()!, emailId: userProfile!.emailForCommunication!, userId: (QRSessionManager.getInstance()?.getUserId())!, homeNo: homeNoTextField.text!, streat: streatTextField.text!, area: areaTextField.text!, city: cityTextField.text!, pinCode: pinCodeTextField.text!, state: stateNameTextField.text!, viewController: self){ (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.editView.isHidden = true
                    self.regSuccessView.isHidden = false
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if addressView.isHidden == false{
            addressView.isHidden = true
            scrollView.isScrollEnabled = false
            errorLabelHeightConstraint.constant = 0
        }else{
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @IBAction func checkPincodeIsValidOrNot(_ sender: Any) {
        self.view.endEditing(false)
        if pinCodeTextField.text!.isEmpty{
            errorLabel.text = Strings.pincode_error
            errorLabelHeightConstraint.constant = 15
        }else{
            errorLabelHeightConstraint.constant = 0
            QuickRideProgressSpinner.startSpinner()
            AccountRestClient.getStateAndCity(pinCode: pinCodeTextField.text!, viewController: self) { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    self.addressView.isHidden = false
                    self.scrollView.isScrollEnabled = true
                    let stateCityPincodeMappingForSodexoRegistration = Mapper<StateCityPincodeMappingForSodexoRegistration>().map(JSONObject: responseObject!["resultData"])
                    self.stateNameTextField.text = stateCityPincodeMappingForSodexoRegistration?.state?.capitalizingFirstLetter()
                    self.cityTextField.text = stateCityPincodeMappingForSodexoRegistration?.city?.capitalizingFirstLetter()
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            }
        }
    }
    func validateFields() -> Bool{
        if firstNameTextField.text!.isEmpty || UserProfileValidationUtils.validateStringForAlphabatic(string: firstNameTextField.text!) == false{
            errorLabel.text = Strings.first_name_error
            errorLabelHeightConstraint.constant = 15
            return false
        }else if lastNameTextField.text!.isEmpty || UserProfileValidationUtils.validateStringForAlphabatic(string: lastNameTextField.text!) == false{
            errorLabel.text = Strings.last_name_error
            errorLabelHeightConstraint.constant = 15
            return false
        }else if pinCodeTextField.text!.isEmpty{
            errorLabel.text = Strings.pincode_error
            errorLabelHeightConstraint.constant = 15
            return false
        }else if homeNoTextField.text!.isEmpty{
            errorLabel.text = Strings.home_no_error
            errorLabelHeightConstraint.constant = 15
            return false
        }else if streatTextField.text!.isEmpty{
            errorLabel.text = Strings.steet_address_error
            errorLabelHeightConstraint.constant = 15
            return false
        }else if areaTextField.text!.isEmpty{
            errorLabel.text = Strings.area_error
            errorLabelHeightConstraint.constant = 15
            return false
        }else{
            errorLabelHeightConstraint.constant = 0
            return true
        }
    }
    @IBAction func queryEmailTapped(_ sender: Any) {
        HelpUtils.sendMailToSpecifiedAddress(delegate: self, viewController: self, subject: nil, toRecipients: [queryEmailBtn.titleLabel!.text!],ccRecipients: [],mailBody: "")
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
    @IBAction func firstContactNoTapped(_ sender: Any) {
        AppUtilConnect.dialNumber(phoneNumber: firstContactNo.titleLabel!.text!, viewController: self)
    }
    
    @IBAction func secondContactNoTapped(_ sender: Any) {
        AppUtilConnect.dialNumber(phoneNumber: secondContactNo.titleLabel!.text!, viewController: self)
    }
}
