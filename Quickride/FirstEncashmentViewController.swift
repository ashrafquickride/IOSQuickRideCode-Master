//
//  FirstEncashmentViewController.swift
//  Quickride
//
//  Created by KNM Rao on 25/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

typealias fuelCardRegistrationReceiver = (_ cardRegistered : Bool) -> Void

class FirstEncashmentViewController : ModelViewController,UITextFieldDelegate{
    
    @IBOutlet weak var EncashView: UIView!
    
    @IBOutlet weak var DismissView: UIView!
    
    @IBOutlet var submitButton: UIButton!
    
    @IBOutlet var bottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var houseNoTextField: UITextField!
    
    @IBOutlet weak var streetTextField: UITextField!
    
    @IBOutlet weak var areaTextField: UITextField!
    
    @IBOutlet weak var cityTextField: UITextField!
    
    @IBOutlet weak var stateTextField: UITextField!
    
    @IBOutlet weak var pinCodeTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var errorLblHeightConstraint: NSLayoutConstraint!
    
    var fuelCardRegistrationReceiver : fuelCardRegistrationReceiver?
    var isKeyBoardVisible = false
    var preferredFuelCompany : String?
    
    func initializeDataBeforePresentingView (preferredFuelCompany : String, fuelCardRegistrationReceiver : @escaping fuelCardRegistrationReceiver)
    {
        AppDelegate.getAppDelegate().log.debug("")
        self.preferredFuelCompany = preferredFuelCompany
        self.fuelCardRegistrationReceiver = fuelCardRegistrationReceiver
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AppDelegate.getAppDelegate().log.debug("")
        handleBrandingChanges()
        houseNoTextField.delegate = self
        streetTextField.delegate = self
        areaTextField.delegate = self
        stateTextField.delegate = self
        pinCodeTextField.delegate = self
        DismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FirstEncashmentViewController.dismissView(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(FirstEncashmentViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirstEncashmentViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func handleBrandingChanges()
    {
        ViewCustomizationUtils.addCornerRadiusToView(view: submitButton, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: EncashView, cornerRadius: 10.0)
    }
    override func viewDidLayoutSubviews() {
        CustomExtensionUtility.changeBtnColor(sender: self.submitButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
    }
    @objc func dismissView(_ sender: UITapGestureRecognizer)
    {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func keyBoardWillShow(notification : NSNotification)
    {
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        bottomSpaceConstraint.constant = -100
    }
    @objc func keyBoardWillHide(notification: NSNotification)
    {
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        bottomSpaceConstraint.constant = 0
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLblHeightConstraint.constant = 0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == houseNoTextField{
            threshold = 500
        }else if textField == streetTextField{
            threshold = 100
        }else if textField == areaTextField{
            threshold = 100
        }else if textField == cityTextField{
            threshold = 100
        }else if textField == pinCodeTextField{
            threshold = 6
        }else if textField == stateTextField{
            threshold = 100
        }else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount{
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
    
    @IBAction func submitClicked(_ sender: Any)
    {
        self.view.endEditing(false)
        if validateAllFields(){
            if QRReachability.isConnectedToNetwork() == false {
                ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
                return
            }
            registerForShellCard()
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    func validateAllFields() -> Bool{
         if houseNoTextField.text!.isEmpty{
            errorLabel.text = Strings.home_no_error
            errorLblHeightConstraint.constant = 20
            return false
        }else if streetTextField.text!.isEmpty{
            errorLabel.text = Strings.steet_address_error
            errorLblHeightConstraint.constant = 20
            return false
        }else if areaTextField.text!.isEmpty{
            errorLabel.text = Strings.area_error
            errorLblHeightConstraint.constant = 20
            return false
        }else if cityTextField.text!.isEmpty{
            errorLabel.text = Strings.city_error
            errorLblHeightConstraint.constant = 20
            return false
        }else if stateTextField.text!.isEmpty{
            errorLabel.text = Strings.state_error
            errorLblHeightConstraint.constant = 20
            return false
         }else if pinCodeTextField.text!.isEmpty{
            errorLabel.text = Strings.pincode_error
            errorLblHeightConstraint.constant = 20
            return false
         }else{
            errorLblHeightConstraint.constant = 0
            return true
        }
    }
    
    func registerForShellCard(){
        let fuelCardRegistration = FuelCardRegistration(cardType: preferredFuelCompany!, userId: (QRSessionManager.getInstance()?.getUserId())!, contactNo: SharedPreferenceHelper.getLoggedInUserContactNo(), houseNo: houseNoTextField.text!, streetName: streetTextField.text!, areaName: areaTextField.text!, state: stateTextField.text!, city: cityTextField.text!, pincode: pinCodeTextField.text!)
            QuickRideProgressSpinner.startSpinner()
        AccountRestClient.registerShellCard( fuelCardRegistration: fuelCardRegistration, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.fuelCardRegistrationReceiver!(true)
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any)
    {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}

