//
//  EnterHandoverOtpViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 11/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie
typealias otpEnteredComplitionHandler = (_ otp: String)-> Void

class EnterHandoverOtpViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backGroundView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var subTextLabel: UILabel!
    @IBOutlet weak var textField1: UITextField!
    @IBOutlet weak var textField2: UITextField!
    @IBOutlet weak var textField3: UITextField!
    @IBOutlet weak var textField4: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var buttonBottomSpace: NSLayoutConstraint!
    
    private var viewModel = EnterHandoverOtpViewModel()
    private var isKeyBoardVisible = false
    
    func initialiseOtpView(type: String,productOrder: ProductOrder,handler: @escaping otpEnteredComplitionHandler){
        viewModel = EnterHandoverOtpViewModel(type: type, productOrder: productOrder,handler: handler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backGroundViewTapped(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        addTargetToTextFields()
        confirmNotification()
        if viewModel.type == EnterHandoverOtpViewModel.HANDOVER_PRODUCT{
            subTextLabel.text = Strings.handoverOtp_taker
        }else{
            subTextLabel.text = Strings.handoverOtp_seller
        }
    }
    //MARK: Notifications
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(pickUpCompleted), name: .pickUpCompleted ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(returnProductCompleted), name: .returnProductCompleted ,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showOTPInvalidError), name: .showOTPInvalidError ,object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        textField1.becomeFirstResponder()
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        closeView()
    }
    private func addTargetToTextFields(){
        textField1.delegate = self
        textField2.delegate = self
        textField3.delegate = self
        textField4.delegate = self
        textField1.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textField2.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textField3.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        textField4.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    private func closeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func verifyOTP() {
        if textField1.text == nil || textField1.text!.isEmpty || textField2 == nil || textField2.text!.isEmpty || textField3 == nil || textField3.text!.isEmpty || textField4 == nil || textField4.text!.isEmpty{
            errorLabel.isHidden = false
            return
        }
        let otp = textField1.text! + textField2.text! + textField3.text! + textField4.text!
        startSpinning()
        if viewModel.type == EnterHandoverOtpViewModel.HANDOVER_PRODUCT{
            viewModel.completePickupAndHandoverProduct(otp: otp)
        }else{
            viewModel.confirmReturnProductToSeller(otp: otp)
        }
    }
    private func startSpinning() {
        otpView.isHidden = true
        animationView.isHidden = false
        animationView.animation = Animation.named("loading_otp")
        animationView.play()
        animationView.loopMode = .loop
    }
    
    private func stopSpinning() {
        animationView.isHidden = true
        otpView.isHidden = false
        animationView.stop()
    }
    
    //MARK: NsNotification
    @objc func pickUpCompleted(_ notification: Notification){
        stopSpinning()
        closeView()
        viewModel.handler?("")
    }
    
    @objc func returnProductCompleted(_ notification: Notification){
        stopSpinning()
        closeView()
        viewModel.handler?("")
    }
    
    @objc func showOTPInvalidError(_ notification: Notification){
        stopSpinning()
        let errorMessage = notification.userInfo?["error"] as? String
        errorLabel.isHidden = false
        errorLabel.text = errorMessage
    }
}

//MARK: UITextFieldDelegate
extension EnterHandoverOtpViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        errorLabel.isHidden = true
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        let text = textField.text
        if text?.utf16.count == 1{
            switch textField {
            case textField1:
                textField2.becomeFirstResponder()
            case textField2:
                textField3.becomeFirstResponder()
            case textField3:
                textField4.becomeFirstResponder()
            case textField4:
                textField4.becomeFirstResponder()
                verifyOTP()
            default:
                break
            }
        }else if text?.utf16.count == 0{
           switch textField {
            case textField1:
                textField1.becomeFirstResponder()
            case textField2:
                textField1.becomeFirstResponder()
            case textField3:
                textField2.becomeFirstResponder()
            case textField4:
                textField3.becomeFirstResponder()
            default:
                break
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,text.isEmpty,string == " "{
            return false
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= 1
    }
    
    @objc private func keyBoardWillShow(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        isKeyBoardVisible = true 
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            buttonBottomSpace.constant = keyBoardSize.height + 30
            
        }
    }
    
    @objc private func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        buttonBottomSpace.constant = 30
    }
}
