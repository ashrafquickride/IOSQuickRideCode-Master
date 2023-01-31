//
//  UpiWalletTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 30/08/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class UpiWalletTableViewCell: UITableViewCell, UITextFieldDelegate {
    
  
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet weak var upiNumberField: UITextField!
    var walletType: String?
    var handlePhoneNumber: handlePhoneNumber?
    
    func intialiseDataForNumber(walletType: String?, handlePhoneNumber: @escaping handlePhoneNumber) {
        self.walletType = walletType
        upiNumberField.delegate = self
        self.handlePhoneNumber = handlePhoneNumber
        ViewCustomizationUtils.addCornerRadiusToView(view: verifyBtn, cornerRadius: 6.0)
        upiNumberField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }

    @objc func textFieldDidChange(textField : UITextField){
           verifyActnColorChange()
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(false)
        verifyActnColorChange()
       
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        verifyActnColorChange()
       
    }
    
    
    func verifyActnColorChange(){
        if upiNumberField.text != nil && !upiNumberField.text!.isEmpty{
            CustomExtensionUtility.changeBtnColor(sender: self.verifyBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            verifyBtn.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: self.verifyBtn, color1: UIColor.lightGray, color2: UIColor.lightGray)
            verifyBtn.isUserInteractionEnabled = true
        }
    }
    
    @IBAction func verifyUpiTapped(_ sender: Any) {
        upiNumberField.endEditing(false)
        if upiNumberField.text == nil || upiNumberField.text!.isEmpty{
          MessageDisplay.displayAlert( messageString: Strings.fill_all_required_fields, viewController: nil,handler: nil)
            return
        }
        if walletType == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE{
            let upiId = upiNumberField.text!.components(separatedBy: "@")
            if upiId.count > 1 && !AccountUtils().isValidGpayUPIId(upiId: upiId[1]){
                MessageDisplay.displayAlert( messageString: Strings.enter_valid_gpay_id, viewController: nil, handler: nil)
                return
            }
        }
        handlePhoneNumber?(upiNumberField.text, true)
    }
   
    
    
}
