//
//  addDiscriptionTableViewCell.swift
//  Quickride
//
//  Created by Halesh on 29/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class addDiscriptionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var descriptionView: QuickRideCardView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    func initialiseView(description: String?){
        descriptionTextView.delegate = self
        if description != nil{
            descriptionTextView.text = description
        }else{
            descriptionTextView.text = Strings.type_your_message
            descriptionTextView.textColor = UIColor.black.withAlphaComponent(0.4)
        }
    }
}
//MARK:UITextViewDelegate
extension addDiscriptionTableViewCell:UITextViewDelegate{
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        if descriptionTextView.text == nil || descriptionTextView.text.isEmpty || descriptionTextView.text ==  Strings.type_your_message{
            descriptionTextView.text = ""
            descriptionTextView.textColor = UIColor.black
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count > 300 {
            return false
        }
        return true
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
        if descriptionTextView.text.isEmpty == true {
            descriptionTextView.text =  Strings.type_your_message
            descriptionTextView.textColor = UIColor.black.withAlphaComponent(0.4)
        }else{
            var userInfo = [String: Any]()
            userInfo["description"] = descriptionTextView.text
            NotificationCenter.default.post(name: .descriptionAdded, object: nil, userInfo: userInfo)
        }
    }
}
