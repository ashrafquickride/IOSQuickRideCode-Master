//
//  EnterDamageChargesViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 19/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

typealias domageChargeEnteredComplitionHandler = (_ otp: String)-> Void
class EnterDamageChargesViewController: UIViewController {
    
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var damageChargeTextField: UITextField!
    @IBOutlet weak var damageView: QuickRideCardView!
    @IBOutlet weak var submitButton: QRCustomButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var buttonBottomSpace: NSLayoutConstraint!
    
    private var isKeyBoardVisible = false
    private var handler: domageChargeEnteredComplitionHandler?
    func initialiseDamageCharge(handler: @escaping domageChargeEnteredComplitionHandler){
        self.handler = handler
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        damageChargeTextField.delegate = self
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        damageChargeTextField.becomeFirstResponder()
    }
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    private func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    @IBAction func submitButtonTapped(_ sender: Any) {
        if let damageCharge = damageChargeTextField.text,!damageCharge.isEmpty{
            handler?(damageCharge)
            closeView()
        }else{
            errorLabel.isHidden = false
            ViewCustomizationUtils.addBorderToView(view: damageView, borderWidth: 1.0, color: UIColor(netHex: 0xE20000))
        }
    }
}

//MARK:UITextFieldDelegate
extension EnterDamageChargesViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.isHidden = true
        damageView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: damageView, borderWidth: 1.0, color: UIColor(netHex: 0xEFEFEF))
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == damageChargeTextField{
            threshold = 10
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
    
    @objc private func keyBoardWillShow(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            buttonBottomSpace.constant = keyBoardSize.height + 20
            
        }
    }
    
    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        buttonBottomSpace.constant = 40
    }
}
