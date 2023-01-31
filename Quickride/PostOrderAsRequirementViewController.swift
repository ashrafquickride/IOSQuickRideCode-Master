//
//  PostOrderAsRequirementViewController.swift
//  Quickride
//
//  Created by HK on 05/05/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
typealias postRequirementComplitionHandler = (_ result: Bool, _ title: String?, _ description: String?) -> Void

class PostOrderAsRequirementViewController: UIViewController {
    
    @IBOutlet weak var titleView: QuickRideCardView!
    @IBOutlet weak var descriptionView: QuickRideCardView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var backgroundView: UIView!
    
    private var handler: postRequirementComplitionHandler?
    func initialiseRequirementScreen(handler: @escaping postRequirementComplitionHandler){
        self.handler = handler
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        animateView()
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
    }
    
    private func animateView(){
        titleTextField.delegate = self
        descriptionTextView.delegate = self
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {return}
                        self.contentView.center.y -= self.contentView.bounds.height
            }, completion: nil)
    }
    
    @IBAction func yesPostItTapped(_ sender: Any) {
        if titleTextField.text?.isEmpty ?? true{
            ViewCustomizationUtils.addBorderToView(view: titleView, borderWidth: 1.0, color: UIColor(netHex: 0xE20000))
            return
        }else if descriptionTextView.text.isEmpty{
            ViewCustomizationUtils.addBorderToView(view: descriptionView, borderWidth: 1.0, color: UIColor(netHex: 0xE20000))
            return
        }
        handler?(true,titleTextField.text,descriptionTextView.text)
        closeView()
    }
    
    @IBAction func skipButtonTapped(_ sender: Any) {
        handler?(false,nil,nil)
        closeView()
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: {[weak self] in
            guard let self = `self` else {return}
            self.contentView.center.y += self.contentView.bounds.height
            self.contentView.layoutIfNeeded()
        }) { (value) in
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
}
//MARK:UITextFieldDelegate
extension PostOrderAsRequirementViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        titleView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: titleView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,text.isEmpty,string == " "{
            return false
        }
        var threshold : Int?
        if textField == titleTextField{
            threshold = 100
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
extension PostOrderAsRequirementViewController:UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        AppDelegate.getAppDelegate().log.debug("")
        if descriptionTextView.text.isEmpty{
            resignFirstResponder()
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        ViewCustomizationUtils.addBorderToView(view: descriptionView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
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
