//
//  ResetPasswordController.swift
//  Quickride
//
//  Created by KNM Rao on 30/09/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import ObjectMapper


class ResetPasswordController : ResetPasswordBaseController{
    
    @IBOutlet var phoneTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func resetButtonTapped()
        
    {
        super.resetButtonTapped()
        if (phoneTextField.text?.isEmpty == true || AppUtil.isValidPhoneNo(phoneNo: phoneTextField.text!, countryCode: countryPickerLabel.text) == false) {
            self.errorAlertLabel.isHidden = false
            self.errorAlertLabel.text = "* " + Strings.enter_valid_phone_no
            self.phoneNoSeperationView.backgroundColor = Colors.red
            return
            }
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.resetPassword(phoneNumber: self.phoneTextField.text!, phoneCode: self.countryPickerLabel.text, uiViewController: self, completionHandler: {
            responseObject, error in
            QuickRideProgressSpinner.stopSpinner()
            self.handleResponse(responseObject: responseObject,error: error)
        })
    }
    

    
}
