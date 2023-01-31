//
//  ChangeMobileNumber.swift
//  Quickride
//
//  Created by QuickRideMac on 12/23/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper
import BottomPopup
import MRCountryPicker

typealias handlingDataComplitionHandler = (_ phoneNumber : String?, _ countryCode : String?) -> Void


class ChangeMobileNumber: BottomPopupViewController, UITextFieldDelegate,MRCountryPickerDelegate {
    
    
    @IBOutlet weak var changeNumberBtn: UIButton!
    @IBOutlet weak var newMobileNumberText: UITextField!
    @IBOutlet var countryPicker: MRCountryPicker!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet var countryCodeLabel: UILabel!
    @IBOutlet var countryFlag: UIImageView!
    @IBOutlet var countrySelectionView: UIView!
    @IBOutlet weak var textFieldBtn: UIButton!
    var phoneNo : String?
    var userId : String?
    var isKeyBoardVisible = false
    var isHandled: handlingDataComplitionHandler?
    var accountUpdateDelegate : AccountUpdateDelegate?
    var countryCode : String?
    
    
    func initialisingDataHandling(handlingDataComplitionHandler : @escaping handlingDataComplitionHandler) {
        self.isHandled = handlingDataComplitionHandler
    }
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        definesPresentationContext = true
        newMobileNumberText.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(ChangeMobileNumber.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChangeMobileNumber.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        updatePopupHeight(to: 225)
        countryCode = AppConfiguration.DEFAULT_COUNTRY_CODE
        countryPicker?.countryPickerDelegate = self
        countryPicker?.setCountry(countryCode!)
        countrySelectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChangeMobileNumber.selectCountryCode(_:))))
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    func countryPhoneCodePicker(_ picker: MRCountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.countryFlag.image = flag
        self.countryCodeLabel.text = phoneCode
        self.countryLabel.text = countryCode
    }
    @objc func selectCountryCode(_ gesture : UITapGestureRecognizer){
        self.view.endEditing(false)
        let countryCodeSelector = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "CountryPickerViewController") as! CountryPickerViewController
        countryCodeSelector.initializeDataBeforePresenting(currentCountryCode: self.countryCode) { (name, countryCode, phoneCode, flag) in
            self.countryCode = countryCode
            self.countryCodeLabel.text = phoneCode
            self.countryFlag.image = flag
            self.countryLabel.text = countryCode
            
        }
        self.present(countryCodeSelector, animated: false, completion: {
            
        })
    }
    
    
    @IBAction func changeNumberTapped(_ sender: Any) {
        
        phoneNo = newMobileNumberText.text
        if newMobileNumberText.text?.isEmpty == true {
            self.view.removeFromSuperview()
            self.removeFromParent()
            dismiss(animated: false)
            accountUpdateDelegate?.accountUpdated()
            return
        }
        self.isHandled?(self.phoneNo!, self.countryCodeLabel.text)
    }
    
    func validatePhoneNumber(phoneNumber : String) -> Bool
    {
        if AppUtil.isValidPhoneNo(phoneNo: newMobileNumberText.text!, countryCode: countryCodeLabel.text ) == false
        {
            
            MessageDisplay.displayAlert(messageString: Strings.phone_no_not_valid,viewController: self,handler: nil)
            return false
        }
        return true
    }
    
    func checkTheOldAndNewContactNumber(phoneNumber : String) -> Bool
    {
        if(QRSessionManager.getInstance()!.getCurrentSessionStatus() == UserSessionStatus.Unknown){
            return true
        }    else {
            return false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton(textField: textField)
    }
    
    @IBAction func tappedOnTextFieldBtn(_ sender: Any) {
        
        if UIDevice.current.hasNotch {
            updatePopupHeight(to: 560)
        }else {
            updatePopupHeight(to: 483)
        }
        newMobileNumberText.becomeFirstResponder()
        textFieldBtn.isHidden = true
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
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            isKeyBoardVisible = true
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        updatePopupHeight(to: 225)
        textFieldBtn.isHidden = false
    }
}
