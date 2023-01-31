//
//  SignUpSecondPhaseViewController.swift
//  Quickride
//
//  Created by Admin on 14/10/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import TransitionButton

class SignUpSecondPhaseViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var mobileNumberView: UIView!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var nextButtonBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextBtn: TransitionButton!
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var whatsappSwitch: UISwitch!
    
    //MARK: Properties
    var signUpSecondPhaseViewModel = SignUpSecondPhaseViewModel()
    private var isKeyboardVisible = false
    
    func initializeView(mobileNo: String){
        signUpSecondPhaseViewModel.mobileNo = mobileNo
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addObservers()
        handleViewCustomization()
        mobileNumberTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        fillPhoneNumberIfExists()
        continueActnColorChange()
        whatsappSwitch.setOn(true, animated: false)
        errorMessageLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.isUserInteractionEnabled = true
        self.navigationController?.isNavigationBarHidden = true
        mobileNumberTextField.becomeFirstResponder()
    }
    
    //MARK: Actions
    @IBAction func backButtonTapped(_ sender: UIButton) {
       
          let signUpFirstPhaseVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SignUpFirstPhaseViewController") as! SignUpFirstPhaseViewController
        self.navigationController?.pushViewController(signUpFirstPhaseVC, animated: false)
    }
    @IBAction func switchTapped(_ sender: UISwitch) {
        if sender.isOn{
            whatsappSwitch.setOn(true, animated: true)
            signUpSecondPhaseViewModel.enableWhatsAppPreferences = true
        }else{
            whatsappSwitch.setOn(false, animated: true)
            signUpSecondPhaseViewModel.enableWhatsAppPreferences = false
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: TransitionButton) {
        view.endEditing(false)
        if let errorMsg = validateFieldAndReturnErrorIfAny(){
            errorMessageLabel.text = errorMsg
            errorMessageLabel.isHidden = false
            return
        }
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.CONTACT_NUMBER_ENTERED, params: ["DeviceId" : DeviceUniqueIDProxy().getDeviceUniqueId() ?? 0], uniqueField: AnalyticsUtils.deviceId)
        sender.startAnimation()
        view.isUserInteractionEnabled = false
        signUpSecondPhaseViewModel.sendOTPToUser(contactNo: mobileNumberTextField.text!, viewController: self) { [weak self] (responseObject, error) in

            
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    sender.stopAnimation(animationStyle: .expand, completion: {
                        self?.navigateToOTPScreen(user: self?.signUpSecondPhaseViewModel.getUserObject(responseObject: responseObject,contactNo: self?.mobileNumberTextField.text))
                    })
                }
                   
            }else{
                sender.stopAnimation()
                self?.view.isUserInteractionEnabled = true
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    //MARK: Methods
    
    private func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        
        textField.inputAccessoryView = keyToolBar
    }
    
    @objc private func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        
        if (!isKeyboardVisible) {
            if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                nextButtonBottomSpaceConstraint.constant = keyBoardSize.height
            }
        }
        isKeyboardVisible = true
    }
    
    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if (isKeyboardVisible) {
            nextButtonBottomSpaceConstraint.constant = 0
        }
        isKeyboardVisible = false
    }
    
    private func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpSecondPhaseViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpSecondPhaseViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func handleViewCustomization(){
        ViewCustomizationUtils.addCornerRadiusToView(view: mobileNumberView, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: headerView, cornerRadius: 3.0)
        addDoneButton(textField: mobileNumberTextField)
    }
    
    private func navigateToOTPScreen(user : User?){
        let otpVerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OTPVerificationViewController") as! OTPVerificationViewController
        otpVerificationViewController.otpVerificationViewModel.initializeData(user: user, contactNo: mobileNumberTextField.text!, enableWhatsAppPreferences: signUpSecondPhaseViewModel.enableWhatsAppPreferences)
        let transition: CATransition = CATransition()
        transition.duration = 0.3
        transition.type = CATransitionType.fade
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(otpVerificationViewController, animated: false)
    }
    
    private func continueActnColorChange(){
        if mobileNumberTextField.text != nil && !mobileNumberTextField.text!.isEmpty && mobileNumberTextField.text!.count == 10 {
            CustomExtensionUtility.changeBtnColor(sender: nextBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            nextBtn.isUserInteractionEnabled = true
        } else {
            CustomExtensionUtility.changeBtnColor(sender: nextBtn, color1: UIColor.lightGray, color2: UIColor.lightGray)
            nextBtn.isUserInteractionEnabled = true
        }
    }
    @objc func textFieldDidChange(textField : UITextField){
        continueActnColorChange()
        mobileNumberTextField.becomeFirstResponder()
    }
    
    private func validateFieldAndReturnErrorIfAny() -> String?{
        if mobileNumberTextField.text == nil || mobileNumberTextField.text!.isEmpty{
            mobileNumberView.backgroundColor = .white
            mobileNumberView.shake()
            ViewCustomizationUtils.addBorderToView(view: mobileNumberView, borderWidth: 1.0, color: .systemRed)
            return Strings.enter_mobile_number
        }
        if !AppUtil.isValidPhoneNo(phoneNo: mobileNumberTextField.text!, countryCode: AppConfiguration.DEFAULT_COUNTRY_CODE_IND){
            mobileNumberView.backgroundColor = .white
            mobileNumberView.shake()
            ViewCustomizationUtils.addBorderToView(view: mobileNumberView, borderWidth: 1.0, color: .systemRed)
            return Strings.enter_valid_phone_no
        }
        return nil
    }
    
    private func fillPhoneNumberIfExists() {
        if let contactNo = UserDataCache.contactNo,contactNo != 0 {
            mobileNumberTextField.text = StringUtils.getStringFromDouble(decimalNumber: contactNo)
        }else if let mobileNo = signUpSecondPhaseViewModel.mobileNo{
            mobileNumberTextField.text = mobileNo
        }else{
           mobileNumberTextField.becomeFirstResponder()
        }
    }

    //MARK: DeIntializer
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

//MARK: UITextFieldDelegate
extension SignUpSecondPhaseViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        mobileNumberView.backgroundColor = UIColor(netHex: 0xe7e7e7)
        ViewCustomizationUtils.addBorderToView(view: mobileNumberView, borderWidth: 1.0, color: .white)
        errorMessageLabel.text = nil
        continueActnColorChange()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(false)
        continueActnColorChange()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentString: NSString = textField.text as NSString? else {
            return false
        }
        let maxLength = 10
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        if newString.length <= maxLength{
            return true
        }
        return false
        
    }
}
