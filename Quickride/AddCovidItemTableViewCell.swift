//
//  AddCovidItemTableViewCell.swift
//  Quickride
//
//  Created by HK on 27/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddCovidItemTableViewCell: UITableViewCell {

    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var shareView: QuickRideCardView!
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var donateView: QuickRideCardView!
    @IBOutlet weak var donateLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionView: QuickRideCardView!
    @IBOutlet weak var contactNoView: QuickRideCardView!
    @IBOutlet weak var contactNoTextField: UITextField!
    
    private var product = Product()
    
    func initialiseProductDetails(product: Product){
        self.product = product
        rentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rentViewTapped(_:))))
        sellView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sellViewTapped(_:))))
        shareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shareViewTapped(_:))))
        donateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(donateViewTapped(_:))))
        contactNoTextField.delegate = self
        descriptionTextView.delegate = self
        if let tradeType = product.tradeType{
            productAvailableFor(type: tradeType)
        }else{
            productAvailableFor(type: Product.DONATE)
        }
        if product.description != nil{
            descriptionTextView.text = product.description
            descriptionTextView.textColor = .black
        }else{
            descriptionTextView.text =  Strings.type_your_message
            descriptionTextView.textColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
    @objc func rentViewTapped(_ sender :UITapGestureRecognizer){
        productAvailableFor(type: Product.RENT)
    }
    
    @objc func sellViewTapped(_ sender :UITapGestureRecognizer){
        productAvailableFor(type: Product.SELL)
    }
    
    @objc func shareViewTapped(_ sender :UITapGestureRecognizer){
        productAvailableFor(type: Product.SHARE)
    }
    @objc func donateViewTapped(_ sender :UITapGestureRecognizer){
        productAvailableFor(type: Product.DONATE)
    }
    private func productAvailableFor(type: String?){
        switch type {
        case Product.RENT:
            rentView.backgroundColor = UIColor(netHex: 0x4B4B4B)
            sellView.backgroundColor = .white
            shareView.backgroundColor = .white
            donateView.backgroundColor = .white
            rentLabel.textColor = .white
            sellLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            shareLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            donateLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        case Product.SELL:
            rentView.backgroundColor = .white
            sellView.backgroundColor = UIColor(netHex: 0x4B4B4B)
            shareView.backgroundColor = .white
            donateView.backgroundColor = .white
            rentLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            sellLabel.textColor = .white
            shareLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            donateLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        case Product.DONATE:
            rentView.backgroundColor = .white
            sellView.backgroundColor = .white
            shareView.backgroundColor = .white
            donateView.backgroundColor = UIColor(netHex: 0x4B4B4B)
            rentLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            sellLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            shareLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            donateLabel.textColor = .white
        case Product.SHARE:
            rentView.backgroundColor = .white
            sellView.backgroundColor = .white
            shareView.backgroundColor = UIColor(netHex: 0x4B4B4B)
            donateView.backgroundColor = .white
            rentLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            sellLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            shareLabel.textColor = .white
            donateLabel.textColor = UIColor.black.withAlphaComponent(0.6)

          default:
            rentView.backgroundColor = .white
            sellView.backgroundColor = .white
            shareView.backgroundColor = .white
            donateView.backgroundColor = .white
            rentLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            sellLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            shareLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            donateLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        }
        product.tradeType = type
        var userInfo = [String: Any]()
        userInfo["product"] = product
        NotificationCenter.default.post(name: .productDetailsAddedOrChanged, object: nil, userInfo: userInfo)
    }
}
//MARK:UITextViewDelegate
extension AddCovidItemTableViewCell:UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        if descriptionTextView.text == nil || descriptionTextView.text.isEmpty || descriptionTextView.text ==  Strings.type_your_message{
            descriptionTextView.text = ""
            descriptionTextView.textColor = UIColor.black
        }
        return true
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
    
    func textViewDidChange(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if descriptionTextView.text.isEmpty{
            resignFirstResponder()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        descriptionTextView.endEditing(true)
        resignFirstResponder()
        var userInfo = [String: Any]()
        product.description = descriptionTextView.text
        userInfo["product"] = product
        NotificationCenter.default.post(name: .productDetailsAddedOrChanged, object: nil, userInfo: userInfo)
        if descriptionTextView.text.isEmpty == true {
            descriptionTextView.text =  Strings.type_your_message
            descriptionTextView.textColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
}
//MARK:UITextFieldDelegate
extension AddCovidItemTableViewCell: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        contactNoView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: contactNoView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == contactNoTextField && contactNoTextField.text?.count ?? 0 < 10{
            ViewCustomizationUtils.addBorderToView(view: contactNoView, borderWidth: 1.0, color: UIColor(netHex: 0xE20000))
        }
        product.contactNo = contactNoTextField.text
        var userInfo = [String: Any]()
        userInfo["product"] = self.product
        NotificationCenter.default.post(name: .productDetailsAddedOrChanged, object: nil, userInfo: userInfo)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,text.isEmpty,string == " "{
            return false
        }
        var threshold : Int?
        if textField == contactNoTextField{
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
