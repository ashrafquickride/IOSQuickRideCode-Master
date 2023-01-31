//
//  EnterNumberTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 29/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias handlePhoneNumber = (_ phoneNumber :String?, _ ispressed: Bool?) -> Void

class EnterNumberTableViewCell: UITableViewCell, UITextFieldDelegate{

    @IBOutlet weak var phoneNumberField: UITextField!
    var handlePhoneNumber: handlePhoneNumber?
    func intialiseDataForNumber(handlePhoneNumber: @escaping handlePhoneNumber) {
        self.handlePhoneNumber = handlePhoneNumber
        phoneNumberField.delegate = self
        
        }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let charsLimit = 10
        let startingLength = textField.text?.count ?? 0
        let lengthToAdd = string.count
        let lengthToReplace =  range.length
        let newLength = startingLength + lengthToAdd - lengthToReplace
        return newLength <= charsLimit
    }
        func validateFieldsAndReturnErrorMsgIfAny() -> String? {
            AppDelegate.getAppDelegate().log.debug("validateFieldsAndReturnErrorMsgIfAny()")
            if phoneNumberField.text == nil || phoneNumberField.text!.isEmpty{
                return Strings.enter_your_registered_paytm_number
            }
            return nil
        }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton(textField : phoneNumberField)
    }
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(closeKeyboard))
        keyToolBar.items = [flexBarButton,doneBarButton]
        textField.inputAccessoryView = keyToolBar
    }

        @objc func closeKeyboard(){
            phoneNumberField.endEditing(true)
        }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
     
    @IBAction func requestOtpTapped(_ sender: Any) {
       
        let validationErrorMsg = validateFieldsAndReturnErrorMsgIfAny()
        if (validationErrorMsg != nil) {
            MessageDisplay.displayAlert( messageString: validationErrorMsg!, viewController: nil, handler: nil)
            return
        }
        phoneNumberField.endEditing(true)
        handlePhoneNumber?(phoneNumberField.text, true)
}
}
