//
//  TextViewAlertController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 15/02/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class TextViewAlertController: BaseTextViewCustomAlertController, UITextViewDelegate {
    
    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var dropDownBtn: UIButton!
    
    @IBOutlet weak var dropDownBtnWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        textView.delegate = self
        self.textView.textAlignment = self.textAlignment!
        self.textView.becomeFirstResponder()
        if existedMessage != nil && !existedMessage!.isEmpty
        {
            self.textView.text = existedMessage
        }
        else
        {
            self.textView.text =  self.placeHolder
            textView.textColor = Colors.chatMsgTextColor
        }
        if isDropDownRequired
        {
            dropDownBtn.isHidden = false
            dropDownBtnWidth.constant = 35
        }
        else
        {
           dropDownBtn.isHidden = true
            dropDownBtnWidth.constant = 0
        }
    }
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var threshold : Int?
        if textView == self.textView{
            threshold = 500
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
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == nil || textView.text.isEmpty == true || textView.text == self.placeHolder{
            
            textView.text = ""
            textView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if(textView.text.isEmpty == true){
            textView.textColor = UIColor.lightGray
            textView.text = self.placeHolder
            textView.endEditing(true)
            resignFirstResponder()
        }else{
            textView.textColor = UIColor.black
        }
    }
    @IBAction func positiveBtnTapped(_ sender: Any) {
        if textView.text == self.placeHolder
        {
            textView!.text = ""
        }
        completionHandler?(textView!.text, positiveActnBtn.titleLabel!.text!)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        if textView.text == self.placeHolder
        {
            textView!.text = ""
        }
        completionHandler?(textView!.text, negativeActnBtn.titleLabel!.text!)
        self.view?.removeFromSuperview()
        self.removeFromParent()
    }
    @IBAction func reasonButtonTapped(_ sender: Any) {
        displayReasonsForRejection()
    }
    func displayReasonsForRejection(){
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for reason in self.dropDownReasonList!
        {
            let action = UIAlertAction(title: reason, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.textView.text = reason
            })
            optionMenu.addAction(action)
        }
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(removeUIAlertAction)
        let height : NSLayoutConstraint = NSLayoutConstraint(item: optionMenu.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: self.viewController!.view.frame.height * 0.50)
        optionMenu.view.addConstraint(height)
        optionMenu.view.tintColor = Colors.alertViewTintColor
        self.present(optionMenu, animated: false, completion: {
            optionMenu.view.tintColor = Colors.alertViewTintColor
        })
    }
}
