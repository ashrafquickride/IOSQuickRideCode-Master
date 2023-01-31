//
//  BankAccountRegistrationViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 10/02/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias bankAccountRegistrationComplitionHandler = (_ isBankAccountRegistered: Bool) -> Void

class BankAccountRegistrationViewController: UIViewController {
    
    //MARK: OUtlets
    @IBOutlet weak var accountNoView: QuickRideCardView!
    @IBOutlet weak var accountNoTextField: UITextField!
    
    @IBOutlet weak var confirmAccountNoView: QuickRideCardView!
    @IBOutlet weak var confirmAccountNoTextField: UITextField!
    
    @IBOutlet weak var bankNameView: QuickRideCardView!
    @IBOutlet weak var bankNameTextField: UITextField!
    
    @IBOutlet weak var ifscCodeView: QuickRideCardView!
    @IBOutlet weak var ifscCodeTextField: UITextField!
    
    @IBOutlet weak var beneficiaryNameView: QuickRideCardView!
    @IBOutlet weak var beneficiaryNameTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var buttonBottomSpace: NSLayoutConstraint!
    
    //MARK: Variables
    private var viewModel = BankAccountRegistrationViewModel()
    private var isKeyBoardVisible = false
    
    func initialiseRegistration(isRequiredToEditBankDetails: Bool,handler: @escaping bankAccountRegistrationComplitionHandler){
        viewModel = BankAccountRegistrationViewModel(isRequiredToEditBankDetails: isRequiredToEditBankDetails,handler: handler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewModel.isRequiredToEditBankDetails && SharedPreferenceHelper.getBankRegistration(){
            viewModel.getBankDetails { [weak self] (isDetailsReceived) in
                self?.accountNoTextField.text = self?.viewModel.userBankAccountInfo.bankAccountNo
                self?.confirmAccountNoTextField.text = self?.viewModel.userBankAccountInfo.bankAccountNo
                self?.bankNameTextField.text = self?.viewModel.userBankAccountInfo.bankName
                self?.ifscCodeTextField.text = self?.viewModel.userBankAccountInfo.ifscCode
                self?.beneficiaryNameTextField.text = self?.viewModel.userBankAccountInfo.accountHolderName
            }
        }
        setUpUi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        handleObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setUpUi(){
        accountNoTextField.delegate = self
        confirmAccountNoTextField.delegate = self
        bankNameTextField.delegate = self
        ifscCodeTextField.delegate = self
        beneficiaryNameTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    private func handleObserver(){
        NotificationCenter.default.addObserver(forName: .handleApiFailureError, object: nil, queue: nil) { [weak self] (notification) in
            QuickRideProgressSpinner.stopSpinner()
            let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
            let error = notification.userInfo?["error"] as? NSError
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
        
        NotificationCenter.default.addObserver(forName: .stopSpinner, object: nil, queue: nil) { [weak self] (notification) in
            QuickRideProgressSpinner.stopSpinner()
            UIApplication.shared.keyWindow?.makeToast("Bank account details saved successfully")
            self?.viewModel.handler?(true)
            self?.navigationController?.popViewController(animated: false)
        }
    }
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func saveDetailsTapped(_ sender: Any) {
        if validateTextFields(){
            QuickRideProgressSpinner.startSpinner()
            viewModel.registerProvidedBankDetails()
        }
    }
    
    private func validateTextFields() -> Bool{
        if let accountNo = accountNoTextField.text,accountNo.isEmpty{
            errorLabel.text = Strings.account_no_error
            ViewCustomizationUtils.addBorderToView(view: accountNoView, borderWidth: 1.0, color: UIColor(netHex: 0xE20000))
            return false
        }else if let confirnAccountNo = confirmAccountNoTextField.text,confirnAccountNo.isEmpty{
            errorLabel.text = Strings.confirm_account_no_error
            ViewCustomizationUtils.addBorderToView(view: confirmAccountNoView, borderWidth: 1.0, color: UIColor(netHex:0xE20000))
            return false
        }else if accountNoTextField.text != confirmAccountNoTextField.text{
            errorLabel.text = Strings.account_not_matched_error
            ViewCustomizationUtils.addBorderToView(view: confirmAccountNoView, borderWidth: 1.0, color: UIColor(netHex:0xE20000))
            return false
        }else if let bankName = bankNameTextField.text,bankName.isEmpty{
            errorLabel.text = Strings.bank_name_error
            ViewCustomizationUtils.addBorderToView(view: bankNameView, borderWidth: 1.0, color: UIColor(netHex:0xE20000))
            return false
        }else if let ifscCode = ifscCodeTextField.text,ifscCode.isEmpty{
            errorLabel.text = Strings.ifsc_code_error
            ViewCustomizationUtils.addBorderToView(view: ifscCodeView, borderWidth: 1.0, color: UIColor(netHex:0xE20000))
            return false
        }else if let beneficiaryName = beneficiaryNameTextField.text, beneficiaryName.isEmpty{
            errorLabel.text = Strings.beneficiary_name_error
            ViewCustomizationUtils.addBorderToView(view: beneficiaryNameView, borderWidth: 1.0, color: UIColor(netHex:0xE20000))
            return false
        }else{
            errorLabel.text = ""
            viewModel.userBankAccountInfo = UserBankAccountInfo(bankName: bankNameTextField.text ?? "", bankAccountNo: accountNoTextField.text ?? "", accountHolderName: beneficiaryNameTextField.text ?? "", mobileNo: SharedPreferenceHelper.getLoggedInUserContactNo() ?? "", ifscCode: ifscCodeTextField.text ?? "")
            return true
        }
    }
}
//MARK:UITextFieldDelegate
extension BankAccountRegistrationViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.text = ""
        ViewCustomizationUtils.addBorderToView(view: accountNoView, borderWidth: 1.0, color: UIColor(netHex: 0xEFEFEF))
        ViewCustomizationUtils.addBorderToView(view: confirmAccountNoView, borderWidth: 1.0, color: UIColor(netHex: 0xEFEFEF))
        ViewCustomizationUtils.addBorderToView(view: bankNameView, borderWidth: 1.0, color: UIColor(netHex: 0xEFEFEF))
        ViewCustomizationUtils.addBorderToView(view: ifscCodeView, borderWidth: 1.0, color: UIColor(netHex: 0xEFEFEF))
        ViewCustomizationUtils.addBorderToView(view: beneficiaryNameView, borderWidth: 1.0, color: UIColor(netHex: 0xEFEFEF))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == accountNoTextField{
            threshold = 20
        }else if textField == confirmAccountNoTextField{
            threshold = 20
        }else if textField == bankNameTextField{
            threshold = 50
        }else if textField == ifscCodeTextField{
            threshold = 20
        }else if textField == beneficiaryNameTextField{
            threshold = 50
        }else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
    @objc private func keyBoardWillShow(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            buttonBottomSpace.constant = keyBoardSize.height
        }
    }
    
    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        buttonBottomSpace.constant = 0
    }
}
