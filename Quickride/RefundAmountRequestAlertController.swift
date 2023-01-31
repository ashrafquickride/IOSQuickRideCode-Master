//
//  RefundAmountRequestAlertController.swift
//  Quickride
//
//  Created by KNM Rao on 04/09/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RefundAmountRequestAlertController: ModelViewController,UITextFieldDelegate {
  
  @IBOutlet var textField: UITextField!
  
  @IBOutlet var alterDialogueCenterAllignement: NSLayoutConstraint!
  
  @IBOutlet var negativeButton: UIButton!
  @IBOutlet var positiveButton: UIButton!
  var isKeyBoardVisible = false
  var handler: alertControllerTextFieldActionHandler?
  var points : Double?

  
  func initializeDataBeforePresentingView(points : Double , handler:  @escaping  alertControllerTextFieldActionHandler) {
    self.handler = handler
    self.points = points
  }
  
  override func viewDidLoad(){
    super.viewDidLoad()
   
    ViewCustomizationUtils.addCornerRadiusToView(view: positiveButton, cornerRadius: 3.0)
    ViewCustomizationUtils.addCornerRadiusToView(view: negativeButton, cornerRadius: 3.0)
    textField.delegate = self
    textField.text = StringUtils.getStringFromDouble(decimalNumber: points!)
    NotificationCenter.default.addObserver(self, selector: #selector(RefundAmountRequestAlertController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(RefundAmountRequestAlertController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
  
  @IBAction func negativeAction(_ sender: Any) {
      self.dismiss(animated: true)
      self.view.removeFromSuperview()
      self.removeFromParent()
  }
  
  @IBAction func positiveAction(_ sender: Any) {
    
    textField.endEditing(false)
   
    if NumberUtils.validateTextFieldForSpecialCharacters(textField: textField, viewController: self){
        return
    }
    
    if textField.text == nil || textField.text!.isEmpty || Int(textField.text!)! == 0{
       textField.endEditing(false)
      UIApplication.shared.keyWindow?.makeToast( Strings.enter_valid_amount)
      return
    }
    
    if Int(points!) < Int(textField.text!)!{
      
        UIApplication.shared.keyWindow?.makeToast( String(format: Strings.refund_amount_can_not_be_more_than_X, StringUtils.getStringFromDouble(decimalNumber: points)))
        return
    }
    
    handler?(textField!.text, Strings.done_caps)
      self.dismiss(animated: true)
      self.view.removeFromSuperview()
      self.removeFromParent()
  }
}
