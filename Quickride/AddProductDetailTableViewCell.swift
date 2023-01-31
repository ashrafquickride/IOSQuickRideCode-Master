//
//  AddProductDetailTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 12/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class AddProductDetailTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var rentView: QuickRideCardView!
    @IBOutlet weak var rentLabel: UILabel!
    @IBOutlet weak var sellView: QuickRideCardView!
    @IBOutlet weak var sellLabel: UILabel!
    @IBOutlet weak var bothView: QuickRideCardView!
    @IBOutlet weak var conditionView: QuickRideCardView!
    @IBOutlet weak var bothLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    @IBOutlet weak var yearOfPurchaseView: QuickRideCardView!
    @IBOutlet weak var purchaseYearTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionView: QuickRideCardView!
    
    private var product = Product() 
    
    func initialiseProductDetails(product: Product){
        self.product = product
        conditionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showConditionsOptions(_:))))
        rentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(rentViewTapped(_:))))
        sellView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(sellViewTapped(_:))))
        bothView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(bothViewTapped(_:))))
        purchaseYearTextField.delegate = self
        descriptionTextView.delegate = self
        if let condition = product.condition{
            conditionLabel.text = condition
        }else{
            conditionLabel.text = Strings.candition1
            self.product.condition = Strings.candition1
        }
        if product.manufacturedDate != 0{
            purchaseYearTextField.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: Double(product.manufacturedDate), timeFormat: DateUtils.DATE_FORMAT_yyyy)
        }else{
            purchaseYearTextField.text = String(Calendar.current.component(.year, from: Date()))
            self.product.manufacturedDate = Int(DateUtils.getTimeStampFromString(dateString: purchaseYearTextField.text, dateFormat: DateUtils.DATE_FORMAT_yyyy) ?? 0)
        }
        if let tradeType = product.tradeType{
            productAvailableFor(type: tradeType)
        }else{
            productAvailableFor(type: Product.SELL)
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
    
    @objc func bothViewTapped(_ sender :UITapGestureRecognizer){
        productAvailableFor(type: Product.BOTH)
    }
    
    private func productAvailableFor(type: String?){
        switch type {
        case Product.RENT:
            rentView.backgroundColor = UIColor(netHex: 0x4B4B4B)
            sellView.backgroundColor = .white
            bothView.backgroundColor = .white
            rentLabel.textColor = .white
            sellLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            bothLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        case Product.SELL:
            rentView.backgroundColor = .white
            sellView.backgroundColor = UIColor(netHex: 0x4B4B4B)
            bothView.backgroundColor = .white
            rentLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            sellLabel.textColor = .white
            bothLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        case Product.BOTH:
            rentView.backgroundColor = .white
            sellView.backgroundColor = .white
            bothView.backgroundColor = UIColor(netHex: 0x4B4B4B)
            rentLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            sellLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            bothLabel.textColor = .white
        default:
            rentView.backgroundColor = .white
            sellView.backgroundColor = .white
            bothView.backgroundColor = .white
            rentLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            sellLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            bothLabel.textColor = UIColor.black.withAlphaComponent(0.6)
        }
        product.tradeType = type
        var userInfo = [String: Any]()
        userInfo["product"] = product
        NotificationCenter.default.post(name: .productDetailsAddedOrChanged, object: nil, userInfo: userInfo)
    }
    
    @objc func showConditionsOptions(_ sender :UITapGestureRecognizer){
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction : UIAlertAction = UIAlertAction(title: Strings.candition4, style: .default) { action -> Void in
            self.product.condition = Strings.candition4
            self.conditionLabel.text = Strings.candition4
            var userInfo = [String: Any]()
            userInfo["product"] = self.product
            NotificationCenter.default.post(name: .productDetailsAddedOrChanged, object: nil, userInfo: userInfo)
        }
        let secondAction: UIAlertAction = UIAlertAction(title: Strings.candition1, style: .default) { action -> Void in
            self.product.condition = Strings.candition1
            self.conditionLabel.text = Strings.candition1
            var userInfo = [String: Any]()
            userInfo["product"] = self.product
            NotificationCenter.default.post(name: .productDetailsAddedOrChanged, object: nil, userInfo: userInfo)
        }
        let thirdAction: UIAlertAction = UIAlertAction(title: Strings.candition3, style: .default) { action -> Void in
            self.product.condition = Strings.candition3
            self.conditionLabel.text = Strings.candition3
            var userInfo = [String: Any]()
            userInfo["product"] = self.product
            NotificationCenter.default.post(name: .productDetailsAddedOrChanged, object: nil, userInfo: userInfo)
        }
        let forthAction: UIAlertAction = UIAlertAction(title: Strings.candition2, style: .default) { action -> Void in
            self.product.condition = Strings.candition2
            self.conditionLabel.text = Strings.candition2
            var userInfo = [String: Any]()
            userInfo["product"] = self.product
            NotificationCenter.default.post(name: .productDetailsAddedOrChanged, object: nil, userInfo: userInfo)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(thirdAction)
        actionSheetController.addAction(forthAction)
        actionSheetController.addAction(cancelAction)
        parentViewController?.present(actionSheetController, animated: true) {
        }
    }
}
//MARK:UITextFieldDelegate
extension AddProductDetailTableViewCell: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        yearOfPurchaseView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: yearOfPurchaseView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let year = Calendar.current.component(.year, from: Date())
        if textField == purchaseYearTextField && ((Int(purchaseYearTextField.text ?? "") ?? 0 > year || purchaseYearTextField.text?.count ?? 0 < 4) || Int(purchaseYearTextField.text ?? "") ?? 0 < 1600){
            purchaseYearTextField.text = ""
            UIApplication.shared.keyWindow?.makeToast("Enter valid purchased year")
        }
        let manufacturedDate = DateUtils.getTimeStampFromString(dateString: purchaseYearTextField.text, dateFormat: DateUtils.DATE_FORMAT_yyyy)
        product.manufacturedDate = Int(manufacturedDate ?? 0)
        var userInfo = [String: Any]()
        userInfo["product"] = self.product
        NotificationCenter.default.post(name: .productDetailsAddedOrChanged, object: nil, userInfo: userInfo)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,text.isEmpty,string == " "{
            return false
        }
        var threshold : Int?
        if textField == purchaseYearTextField{
            threshold = 4
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
extension AddProductDetailTableViewCell:UITextViewDelegate{
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
