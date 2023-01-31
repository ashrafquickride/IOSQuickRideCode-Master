//
//  ResetPasswordBaseController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 15/06/17.
//  Copyright © 2017 iDisha. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper
import MRCountryPicker

protocol ResetPasswordDelegate {
    func receiveResetPhoneNumber(phoneNumber : String)
}


class ResetPasswordBaseController: UIViewController, UITextFieldDelegate, MRCountryPickerDelegate
{
    
    var userId: String?
    var countryCode : String?
    var domainName : String?
    var delegate : ResetPasswordDelegate?
    
    @IBOutlet weak var phoneTextField: UITextField!
    
    @IBOutlet weak var countryPickerView: UIView!
    
    @IBOutlet weak var countryPickerflag: UIImageView!
    
    @IBOutlet weak var countryPickerLabel: UILabel!
    
    @IBOutlet weak var countryPicker: MRCountryPicker!
    
     @IBOutlet var resetPasswordButton: UIButtonBordered!
    
    @IBOutlet weak var countryCodeLabel: UILabel!
    
    @IBOutlet weak var seperationView: UIView!
    
    @IBOutlet weak var errorAlertLabel: UILabel!
    
    @IBOutlet weak var phoneNoSeperationView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    func initializeDataBeforePresenting(phoneNumber : String , phoneCode : String, domainName : String?, delegate : ResetPasswordDelegate?){
        AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresenting()")
        self.userId = phoneNumber
        self.countryCode = phoneCode
        self.domainName = domainName
        self.delegate = delegate
    }
    
  

    override func viewDidLoad()
    {
         AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        self.phoneTextField.delegate = self
        if self.userId?.isEmpty == false {
            self.phoneTextField.text = userId!
        }
        
        countryCode = AppConfiguration.DEFAULT_COUNTRY_CODE
        countryPicker?.countryPickerDelegate = self
        countryPicker?.setCountry(countryCode!)
        countryPickerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ResetPasswordBaseController.selectCountryCode(_:))))
        ViewCustomizationUtils.addCornerRadiusToView(view: resetPasswordButton, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: seperationView, cornerRadius: 3.0)
        phoneTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        resetActionColorChange()
        self.seperationView.applyGradient(colours: [UIColor(netHex:0x74fb8f), UIColor(netHex:0x47c760)])
    }
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.countryPickerflag.image = flag
        self.countryPickerLabel.text = phoneCode
        self.countryCodeLabel.text = countryCode
    }
    @objc func selectCountryCode(_ gesture : UITapGestureRecognizer){
        self.view.endEditing(false)
        let countryCodeSelector = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "CountryPickerViewController") as! CountryPickerViewController
        countryCodeSelector.initializeDataBeforePresenting(currentCountryCode: self.countryCode) { (name, countryCode, phoneCode, flag) in
            self.countryCode = countryCode
            self.countryPickerLabel.text = phoneCode
            self.countryPickerflag.image = flag
            self.countryCodeLabel.text = countryCode
        }
        self.present(countryCodeSelector, animated: false, completion: {
            
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func handleResponse(responseObject: NSDictionary?, error: NSError?){
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            AppDelegate.getAppDelegate().log.debug("Response in login is \(String(describing: responseObject)) and \(String(describing: error))")
            QuickRideProgressSpinner.stopSpinner()
            UIApplication.shared.keyWindow?.makeToast(message: Strings.password_sent)
            let passwordChangeViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PasswordChangeViewController") as! PasswordChangeViewController
            passwordChangeViewController.initializeDataBeforePresenting(phoneNumber: phoneTextField.text!, phoneCode: self.countryPickerLabel.text!,isSecure : false)
            
            self.navigationController?.pushViewController(passwordChangeViewController, animated: false)
        }else{
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
    }
    
   @IBAction func resetPassword(_ sender: UIButton) {
    self.view.endEditing(false)
    resetButtonTapped()
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
    self.navigationController?.view.layer.add(CustomExtensionUtility.transitionEffectWhilePopingView(), forKey: kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
    
     func resetButtonTapped()
     {
        AppDelegate.getAppDelegate().log.debug("resetPassword()")
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
       

    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.errorAlertLabel.isHidden = true
        self.phoneNoSeperationView.backgroundColor = Colors.lightGrey
        if textField == phoneTextField{
            addDoneButton(textField: phoneTextField)
            ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0,y: 150))
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(true)
        ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0,y: 0))
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.phoneTextField.resignFirstResponder()
        return false
    }
    @objc func textFieldDidChange(textField : UITextField){
        resetActionColorChange()
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        CustomExtensionUtility.changeBtnColor(sender: self.resetPasswordButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
        resetPasswordButton.isUserInteractionEnabled = false
        return true
    }
    func resetActionColorChange(){
        if phoneTextField.text != nil && phoneTextField.text?.isEmpty == false{
            CustomExtensionUtility.changeBtnColor(sender: self.resetPasswordButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            resetPasswordButton.isUserInteractionEnabled = true
            
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: self.resetPasswordButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
            resetPasswordButton.isUserInteractionEnabled = false
        }
    }
    func HoldResetBtn(_ sender:UIButton)
    {
        resetPasswordButton.backgroundColor = Colors.darkGreen
    }
    func HoldRelease(_ sender:UIButton){
        self.resetPasswordButton.backgroundColor = UIColor(netHex:0x40A33F)
        self.resetPasswordButton.applyGradient(colours: [UIColor(netHex:0x00b557), UIColor(netHex:0x008a41)])
    }
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        
        textField.inputAccessoryView = keyToolBar
    }
    
    
    
}
