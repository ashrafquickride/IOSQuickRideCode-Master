//
//  TextFieldCustomAlertController.swift
//  Quickride
//
//  Created by QuickRideMac on 5/27/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import BottomPopup

class TextFieldCustomAlertController: BottomPopupViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var positiveActnBtn: QRCustomButton!
    @IBOutlet weak var negativeActnBtn: QRCustomButton!
    @IBOutlet weak var textFieldBtn: UIButton!
    
    var keyboardHeight : CGFloat = 0.0
    var isKeyBoardVisible = false
    var textAlignment : NSTextAlignment?
    var placeHolder : String?
    var completionHandler : alertControllerTextFieldActionHandler?
   
    func initializeDataBeforePresentingView(textAlignment : NSTextAlignment, placeHolder: String?, handler : @escaping alertControllerTextFieldActionHandler)
    {
        self.textAlignment = textAlignment
        self.completionHandler = handler
        self.placeHolder = placeHolder
    }
    

    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        textField.delegate = self
        self.textField.textAlignment = self.textAlignment!
        self.textField.placeholder = self.placeHolder
        updatePopupHeight(to: 230)
        NotificationCenter.default.addObserver(self, selector: #selector(TextFieldCustomAlertController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TextFieldCustomAlertController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
          AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
          if isKeyBoardVisible == true{
              AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
              return
          }
          if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
              isKeyBoardVisible = true
              let keyboardHeight = keyBoardSize.height
              self.keyboardHeight = 400 + keyboardHeight
          }
      }
    
    
      @objc func keyBoardWillHide(notification: NSNotification){
          AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
          if isKeyBoardVisible == false{
              AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
              return
             
          }
          isKeyBoardVisible = false
          updatePopupHeight(to: 230)
          textFieldBtn.isHidden = false
      }
    
    
    
    @IBAction func tappedOnTextFieldBtn(_ sender: Any) {
        if UIDevice.current.hasNotch {
            updatePopupHeight(to: 610)
        }else {
            updatePopupHeight(to: 530)
        }
        
        textField.becomeFirstResponder()
        textFieldBtn.isHidden = true
    }
    
    @IBAction func positiveBtnTapped(_ sender: Any) {
        completionHandler?(textField!.text, positiveActnBtn.titleLabel!.text!)
        
        self.view.removeFromSuperview()
        self.removeFromParent()
        dismiss(animated: false)
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        completionHandler?(textField!.text, negativeActnBtn.titleLabel!.text!)
        self.view?.removeFromSuperview()
        self.removeFromParent()
        dismiss(animated: false)
    }
}
