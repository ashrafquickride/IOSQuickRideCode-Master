//
//  AddAlternateNumberViewController.swift
//  Quickride
//
//  Created by Admin on 23/09/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import BottomPopup

class AddOrUpdateAlternateNumberViewController: BottomPopupViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var alternateNumTextField: UITextField!
    @IBOutlet weak var addNowBtn: UIButton!
    @IBOutlet weak var alertViewTitleLabel: UILabel!
    @IBOutlet weak var textFieldActionButton: UIButton!
    
    var isKeyBoardVisible = false
    var accountUpdateDelegate : AccountUpdateDelegate?
    var keyboardHeight : CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alternateNumTextField.delegate = self
        addGestures()
      
        updatePopupHeight(to: 235)
        setDataToViewAndHandleVisibilityOfDeleteBtn()
        
    }
    
    private func addGestures(){
        alternateNumTextField.addTarget(self, action: #selector(self.textFieldDidChangeActivationCode(textField:)), for: UIControl.Event.editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(AddOrUpdateAlternateNumberViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddOrUpdateAlternateNumberViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
           let keyboardHeight = keyBoardSize.height
            self.keyboardHeight = 400 + keyboardHeight

            isKeyBoardVisible = true
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        updatePopupHeight(to: 235)
        textFieldActionButton.isHidden = false
    }

    private func setDataToViewAndHandleVisibilityOfDeleteBtn(){
        if let currentUser = UserDataCache.getInstance()?.currentUser,currentUser.alternateContactNo != nil,currentUser.alternateContactNo != 0{
            alertViewTitleLabel.text = Strings.update_alternate_num
            addNowBtn.setTitle(Strings.update_caps, for: .normal)
            alternateNumTextField.text = StringUtils.getStringFromDouble(decimalNumber: currentUser.alternateContactNo)
        }else{
            alertViewTitleLabel.text = Strings.add_alternate_num
            addNowBtn.setTitle(Strings.add_caps, for: .normal)
        }
        continueActnColorChange()
    }
    
    
    @IBAction func addNowBtnClicked(_ sender: Any) {
        if alternateNumTextField.text == nil || alternateNumTextField.text!.isEmpty{
            
            UIApplication.shared.keyWindow?.makeToast( Strings.enter_alternate_num)
            self.view.removeFromSuperview()
            self.removeFromParent()
            dismiss(animated: false)
            return
        }
        if !AppUtil.isValidPhoneNo(phoneNo: alternateNumTextField.text!, countryCode: AppConfiguration.DEFAULT_COUNTRY_CODE_IND){
            UIApplication.shared.keyWindow?.makeToast( Strings.enter_valid_phone_no)
            self.view.removeFromSuperview()
            self.removeFromParent()
            dismiss(animated: false)
            return
        }
     
        updateAlternateContactNo(number: alternateNumTextField.text)
    }
    
    private func removeView(){
        self.view.removeFromSuperview()
        self.removeFromParent()
        dismiss(animated: false)
        self.accountUpdateDelegate?.accountUpdated()
    }
    
    @objc private func backgroundViewClicked(_ sender : UITapGestureRecognizer){
        removeView()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        addDoneButton()
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.endEditing(false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(false)
        return true
    }
    
    private func addDoneButton(){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        alternateNumTextField.inputAccessoryView = keyToolBar
    }
    
    private func continueActnColorChange(){
        if alternateNumTextField.text != nil && !alternateNumTextField.text!.isEmpty{
            CustomExtensionUtility.changeBtnColor(sender: addNowBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            addNowBtn.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: addNowBtn, color1: UIColor.lightGray, color2: UIColor.lightGray)
            addNowBtn.isUserInteractionEnabled = false
        }
    }
    
    @objc private func textFieldDidChangeActivationCode(textField : UITextField){
        updatePopupHeight(to: 560)
        continueActnColorChange()
    }
    
    @IBAction func deleteBtnClicked(_ sender: Any) {
        updateAlternateContactNo(number: nil)
    }
    
    @IBAction func tappedOnTextFielbButton(_ sender: Any) {
        if UIDevice.current.hasNotch {
            updatePopupHeight(to: 560)
        }else {
            updatePopupHeight(to: 490)
        }
        alternateNumTextField.becomeFirstResponder()
        textFieldActionButton.isHidden = true
    }
    private func updateAlternateContactNo(number : String?){
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.addAlternateContactNo(userId: (QRSessionManager.getInstance()?.getUserId())!, alternateContactNo: number, viewController: self) { [unowned self] (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.checkAndUpdateNumberInCache(number: number)
                self.removeView()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    private func checkAndUpdateNumberInCache(number : String?){
        if let currentUser = UserDataCache.getInstance()?.currentUser{
            
            if number != nil{
                currentUser.alternateContactNo = Double(number!)
            }else{
                currentUser.alternateContactNo = nil
            }
            
           UserDataCache.getInstance()?.updateUserObject(user: currentUser)
        }
    }
   
}
