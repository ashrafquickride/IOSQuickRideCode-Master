//
//  IOCLRegistrationViewController.swift
//  Quickride
//
//  Created by Vinutha on 12/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class IOCLRegistrationViewController: UIViewController {
    
    @IBOutlet weak var registrationView: UIView!
    @IBOutlet weak var dismissView: UIView!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var registrationViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var errorLblHeightConstraint: NSLayoutConstraint!
    
    private var fuelCardRegistrationReceiver : fuelCardRegistrationReceiver?
    private var isKeyBoardVisible = false
    
    func initializeDataBeforePresentingView(fuelCardRegistrationReceiver : @escaping fuelCardRegistrationReceiver) {
        self.fuelCardRegistrationReceiver = fuelCardRegistrationReceiver
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        mobileNumberTextField.delegate = self
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(FirstEncashmentViewController.dismissView(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(FirstEncashmentViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirstEncashmentViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyBoardWillShow(notification : NSNotification) {
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
            return
        }
        isKeyBoardVisible = true
        registrationViewYConstraint.constant = -50
    }
    @objc func keyBoardWillHide(notification: NSNotification) {
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            return
        }
        isKeyBoardVisible = false
        registrationViewYConstraint.constant = 0
    }
    
    @IBAction func submitClicked(_ sender: Any) {
        self.view.endEditing(false)
        if validateAllFields() {
            if QRReachability.isConnectedToNetwork() == false {
                ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
                return
            }
            registerForIOCL()
        }
    }
    
    private func validateAllFields() -> Bool {
         if firstNameTextField.text!.isEmpty{
            errorLabel.text = Strings.first_name_error
            errorLblHeightConstraint.constant = 20
            return false
        }else if lastNameTextField.text!.isEmpty{
            errorLabel.text = Strings.last_name_error
            errorLblHeightConstraint.constant = 20
            return false
        }else if mobileNumberTextField.text!.isEmpty{
            errorLabel.text = Strings.enter_mobile_number
            errorLblHeightConstraint.constant = 20
            return false
        }else{
            errorLblHeightConstraint.constant = 0
            return true
        }
    }
    
    private func registerForIOCL() {
        QuickRideProgressSpinner.startSpinner()
        AccountRestClient.checkAndRegisterForIOCLFuleCard(firstName: firstNameTextField.text!, lastName: lastNameTextField.text!, newProfile: true, userId: SharedPreferenceHelper.getLoggedInUserId() ?? "0", mobileNo: mobileNumberTextField.text!) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                SharedPreferenceHelper.setUserRegisteredForIOCL(status: true)
                self.fuelCardRegistrationReceiver!(true)
                self.removeView()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    private func removeView() {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @objc func dismissView(_ sender: UITapGestureRecognizer) {
        removeView()
    }
    
}
extension IOCLRegistrationViewController: UITextFieldDelegate {
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
        if textField == firstNameTextField{
            threshold = 50
        }else if textField == lastNameTextField{
            threshold = 50
        }else if textField == mobileNumberTextField{
            threshold = 10
        } else {
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if range.length + range.location > currentCharacterCount{
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
}
