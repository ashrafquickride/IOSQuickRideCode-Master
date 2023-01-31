//
//  ChangeContactNumberViewController.swift
//  Quickride
//
//  Created by iDisha on 06/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ChangeContactNumberViewController: ModelViewController, UITextFieldDelegate {
    
    @IBOutlet var phoneNumberTextField: UITextField!
    
    @IBOutlet var actionButton: UIButton!
    
    @IBOutlet var alterDialogueCenterAllignement: NSLayoutConstraint!
    
    @IBOutlet var dismissView : UIView!
    
    
    var isKeyBoardVisible = false
    var handler: alertControllerTextFieldActionHandler?
    var phoneNumber : String?
    
    func initializeDataBeforePresentingView(phoneNumber : String?, handler:  @escaping  alertControllerTextFieldActionHandler) {
        self.handler = handler
        self.phoneNumber = phoneNumber
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        phoneNumberTextField.delegate = self
        phoneNumberTextField.text = phoneNumber
        NotificationCenter.default.addObserver(self, selector: #selector(RefundAmountRequestAlertController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RefundAmountRequestAlertController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChangeContactNumberViewController.backGroundViewTapped(_:))))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CustomExtensionUtility.changeBtnColor(sender: self.actionButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton(textField: textField)
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
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            isKeyBoardVisible = true
            alterDialogueCenterAllignement.constant = -keyBoardSize.height/2
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        alterDialogueCenterAllignement.constant = 0
    }
    
    @IBAction func confirmBtnTapped(_ sender: Any) {
        
        self.view.endEditing(false)
        
        if NumberUtils.validateTextFieldForSpecialCharacters(textField: phoneNumberTextField, viewController: self){
            return
        }
        
        if phoneNumberTextField.text == nil || phoneNumberTextField.text!.isEmpty {
            UIApplication.shared.keyWindow?.makeToast( Strings.enter_valid_phone_no)
            return
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
        
        handler?(phoneNumberTextField!.text, Strings.done_caps)
    }
    
    @objc func backGroundViewTapped(_ sender: UITapGestureRecognizer) {
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
}
