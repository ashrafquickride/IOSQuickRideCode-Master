//
//  AddRequirementTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 12/10/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddRequirementTableViewCell: UITableViewCell {

    @IBOutlet weak var titleView: QuickRideCardView!
    @IBOutlet weak var descriptionView: QuickRideCardView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contactNoSecView: UIView!
    
    @IBOutlet weak var contactNoTextField: UITextField!
    @IBOutlet weak var contactNoView: QuickRideCardView!
    private var requestProduct: RequestProduct?
    private var isFromCovid = false
    
    func initialiseView(requestProduct: RequestProduct,isFromCovid: Bool){
        self.requestProduct = requestProduct
        self.isFromCovid = isFromCovid
        if let title = requestProduct.title{
           titleTextField.text = title
        }else{
           titleTextField.becomeFirstResponder()
        }
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        if requestProduct.description != nil{
            descriptionTextView.text = requestProduct.description
            descriptionTextView.textColor = .black
        }else{
            descriptionTextView.text =  Strings.type_your_message
            descriptionTextView.textColor = UIColor.black.withAlphaComponent(0.4)
        }
        if isFromCovid{
            contactNoSecView.isHidden = false
            contactNoTextField.delegate = self
            if let contactNo = requestProduct.contactNo,!contactNo.isEmpty{
                contactNoTextField.text = contactNo
            }
        }else{
            contactNoSecView.isHidden = true
        }
    }
}
//MARK:UITextFieldDelegate
extension AddRequirementTableViewCell: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: titleView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
        contactNoView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: contactNoView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
        ViewCustomizationUtils.addBorderToView(view: descriptionView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
        NotificationCenter.default.post(name: .changeButtonColorIfAllFieldsFilled, object: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        requestProduct?.title = titleTextField.text
        requestProduct?.contactNo = titleTextField.text
        var userInfo = [String: Any]()
        userInfo["requestProduct"] = self.requestProduct
        NotificationCenter.default.post(name: .productDetailsAddedOrChanged, object: nil, userInfo: userInfo)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,text.isEmpty,string == " "{
            return false
        }
        var threshold : Int?
        if textField == titleTextField{
            threshold = 100
        }else if textField == contactNoTextField{
            threshold = 10
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
}
//MARK:UITextViewDelegate
extension AddRequirementTableViewCell:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if descriptionTextView.text.isEmpty{
            resignFirstResponder()
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        if descriptionTextView.text == nil || descriptionTextView.text.isEmpty || descriptionTextView.text ==  Strings.type_your_message{
            descriptionTextView.text = ""
            descriptionTextView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        descriptionTextView.endEditing(true)
        resignFirstResponder()
        requestProduct?.description = descriptionTextView.text
        var userInfo = [String: Any]()
        userInfo["requestProduct"] = self.requestProduct
        NotificationCenter.default.post(name: .productDetailsAddedOrChanged, object: nil, userInfo: userInfo)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let enteredText = textView.text,enteredText.isEmpty,text == " "{
            return false
        }
        var threshold : Int?
        if textView == descriptionTextView{
            threshold = 300
        }else{
            return true
        }
        let currentCharacterCount = textView.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + text.count - range.length
        return newLength <= threshold!
    }
}
