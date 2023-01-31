//
//  ChangeCommunicationMailViewController.swift
//  Quickride
//
//  Created by KNM Rao on 08/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import BottomPopup
class ChangeCommunicationMailViewController: BottomPopupViewController, UITextFieldDelegate {
 
  
  @IBOutlet weak var changeEmailBtn: UIButton!
  @IBOutlet weak var newEmailText: UITextField!
  @IBOutlet weak var textFieldForBtn: UIButton!
    
  var email : String?
  var userProfile : UserProfile?
  var isKeyBoardVisible = false
  var accountUpdateDelegate : AccountUpdateDelegate?
 
  
  override func viewDidLoad() {
    AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
    super.viewDidLoad()
    newEmailText.delegate = self
  
    userProfile = UserDataCache.getInstance()?.userProfile?.copy() as? UserProfile
    newEmailText.text = userProfile!.emailForCommunication
    email = userProfile!.emailForCommunication
      updatePopupHeight(to: 235)
    NotificationCenter.default.addObserver(self, selector: #selector(ChangeCommunicationMailViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(ChangeCommunicationMailViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
  }
    
    
    @IBAction func tappedOnTextFieldBtn(_ sender: Any) {
        if UIDevice.current.hasNotch {
            updatePopupHeight(to: 540)
        }else {
            updatePopupHeight(to: 490)
        }
        newEmailText.becomeFirstResponder()
        textFieldForBtn.isHidden = true
    }
    
    
  @IBAction func changeEmailTapped(_ sender: Any) {
    
    let input = newEmailText.text
    
    if (userProfile!.emailForCommunication == nil && input?.isEmpty == false) || (userProfile!.emailForCommunication != nil && input!.isEmpty == true) || (userProfile!.emailForCommunication != nil && userProfile!.emailForCommunication != input){
      continueEmailUpdate()
    }else{
      dismiss(animated: false)
      accountUpdateDelegate?.accountUpdated()
    }
    
  }
  func continueEmailUpdate(){
    AppDelegate.getAppDelegate().log.debug("")
    newEmailText.endEditing(true)
    newEmailText.text = newEmailText.text!.replacingOccurrences(of: " ", with: "")
    if !isEmailIdValid(emailId: newEmailText.text) {
    
      UIApplication.shared.keyWindow?.makeToast( Strings.enter_valid_email_id)
      return
    }

    if self.newEmailText.text!.isEmpty == false{
      userProfile?.emailForCommunication = self.newEmailText.text!
    }else{
      userProfile?.emailForCommunication = nil
    }
    QuickRideProgressSpinner.startSpinner()

    ProfileRestClient.putProfileWithBody(targetViewController: self, body: userProfile!.getParamsMap()) { (responseObject, error) -> Void in
        QuickRideProgressSpinner.stopSpinner()
      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
        self.userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"])
        UserDataCache.getInstance()?.storeUserProfile(userProfile: self.userProfile!)
          self.view.removeFromSuperview()
          self.removeFromParent()
          self.dismiss(animated: false)
        self.accountUpdateDelegate?.accountUpdated()
        
      }else {
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
      }
    }
  }
    
    
  
  private func isEmailIdValid(emailId : String?) -> Bool {
    AppDelegate.getAppDelegate().log.debug("isEmailIdValid()")
    if emailId == nil || emailId!.isEmpty {
        return false
    }
    return AppUtil.isValidEmailId(emailId: emailId!)
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
        textFieldForBtn.isHidden = false
    }
}

   
    
    

