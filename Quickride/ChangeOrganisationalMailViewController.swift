//
//  ChangeOrganisationalMailViewController.swift
//  Quickride
//
//  Created by KNM Rao on 08/03/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import BottomPopup
import UIKit
class ChangeOrganisationalMailViewController: BottomPopupViewController,UITextFieldDelegate {
    
    @IBOutlet weak var changeEmailBtn: UIButton!
    @IBOutlet weak var newEmailText: UITextField!
    @IBOutlet weak var textFieldTappedBtn: UIButton!
    
    var email : String?
    var userProfile : UserProfile?
    var isKeyBoardVisible = false
    var accountUpdateDelegate : AccountUpdateDelegate?
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        newEmailText.delegate = self
        userProfile = UserDataCache.getInstance()?.userProfile?.copy() as? UserProfile
        email = userProfile!.email
        newEmailText.text = userProfile!.email
      
        updatePopupHeight(to: 230)
        NotificationCenter.default.addObserver(self, selector: #selector(ChangeOrganisationalMailViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChangeOrganisationalMailViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBAction func changeEmailTapped(_ sender: Any) {
        
        let input = newEmailText.text
        if (userProfile!.email == nil && input?.isEmpty == false) || (userProfile!.email != nil && input!.isEmpty == true) || (userProfile!.email != nil && userProfile!.email != input){
            continueEmailUpdate()
        }else{
            self.view.removeFromSuperview()
            self.removeFromParent()
            dismiss(animated: false)
            accountUpdateDelegate?.accountUpdated()
        }
        
    }
    
    
    @IBAction func tappedTextFieldButton(_ sender: Any) {
        if UIDevice.current.hasNotch {
            updatePopupHeight(to: 550)
        }else {
            updatePopupHeight(to: 490)
        }
        newEmailText.becomeFirstResponder()
        textFieldTappedBtn.isHidden = true
        self.view.layer.backgroundColor = UIColor.white.cgColor.converted(to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
    }
    
    func continueEmailUpdate(){
        newEmailText.endEditing(true)
        newEmailText.text = newEmailText.text!.replacingOccurrences(of: " ", with: "")
        if !isEmailIdValid(emailId: newEmailText.text) {
            UIApplication.shared.keyWindow?.makeToast( Strings.enter_valid_email_id)
            return
        }
        if !UserProfileValidationUtils.isOrganisationEmailIdIsValid(orgEmail: newEmailText.text!) {
            MessageDisplay.displayAlert( messageString: Strings.invalid_org_email_msg, viewController: self,handler: nil)
            return
        }
        if self.newEmailText.text!.isEmpty == false{
            userProfile?.email = self.newEmailText.text!
        }else{
            userProfile?.email = nil
        }
        
        AppDelegate.getAppDelegate().log.debug("saveUserProfile()")
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
        if (emailId?.isEmpty == false) {
            return AppUtil.isValidEmailId(emailId: emailId!)
        }
        return true
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
        updatePopupHeight(to: 230)
        textFieldTappedBtn.isHidden = false
    }

}
extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

