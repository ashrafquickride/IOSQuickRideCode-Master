//
//  ChangeEmailViewController.swift
//  Quickride
//
//  Created by QR Mac 1 on 19/05/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//
import Foundation
import UIKit
import ObjectMapper

typealias completionHandler = (String) -> Void

class ChangeEmailViewController: UIViewController {
    
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var changeEmailTextField: UITextField!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var viewConstantHeight: NSLayoutConstraint!
    
    var completion : completionHandler?
    var email : String?
    var userProfile : UserProfile?
    var isKeyBoardVisible = false
    var accountUpdateDelegate : AccountUpdateDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ScheduleRideViewController.dismissViewTapped(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        userProfile = UserDataCache.getInstance()?.userProfile?.copy() as? UserProfile
        changeEmailTextField.text = userProfile!.emailForCommunication
        email = userProfile!.emailForCommunication
        
    }
    
    
    @objc func keyBoardWillShow(notification : NSNotification) {
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
            return
        }
        
        isKeyBoardVisible = true
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            isKeyBoardVisible = true
            viewConstantHeight.constant = -keyBoardSize.height/4
        }
    }
    
    @objc func keyBoardWillHide(notification: NSNotification) {
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            return
        }
        isKeyBoardVisible = false
        viewConstantHeight.constant = 0
        
    }
    
    
    
    @IBAction func changeEmailButtnTapped(_ sender: Any) {
        
        let input = changeEmailTextField.text
        
        if (userProfile!.emailForCommunication == nil && input?.isEmpty == false) || (userProfile!.emailForCommunication != nil && input!.isEmpty == true) || (userProfile!.emailForCommunication != nil && userProfile!.emailForCommunication != input){
            continueEmailUpdate(){ (responseError, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseError != nil || error != nil{
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                }
            }
        }else{
            self.view.removeFromSuperview()
            self.removeFromParent()
            accountUpdateDelegate?.accountUpdated()
        }
    }
    
    func continueEmailUpdate(handler : @escaping(_ responseError: ResponseError?,_ error: NSError?) -> ()){
        AppDelegate.getAppDelegate().log.debug("")
        changeEmailTextField.endEditing(true)
        changeEmailTextField.text = changeEmailTextField.text!.replacingOccurrences(of: " ", with: "")
        if !isEmailIdValid(emailId: changeEmailTextField.text) {
            
            UIApplication.shared.keyWindow?.makeToast( Strings.enter_valid_email_id)
            return
        }
        
        if self.changeEmailTextField.text!.isEmpty == false{
            userProfile?.emailForCommunication = self.changeEmailTextField.text!
        }else{
            userProfile?.emailForCommunication = nil
        }
        QuickRideProgressSpinner.startSpinner()
        ProfileRestClient.putProfileWithBody(targetViewController: self, body: userProfile!.getParamsMap()) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            let result = RestResponseParser<UserProfile>().parse(responseObject: responseObject, error: error)
            if let userProfile = result.0 {
                self.userProfile = userProfile
                UserDataCache.getInstance()?.storeUserProfile(userProfile: self.userProfile!)
                self.view.removeFromSuperview()
                self.removeFromParent()
                self.accountUpdateDelegate?.accountUpdated()
            }
            handler(result.1,result.2)
        }
    }
    
    private func isEmailIdValid(emailId : String?) -> Bool {
        AppDelegate.getAppDelegate().log.debug("isEmailIdValid()")
        if emailId == nil || emailId!.isEmpty {
            return false
        }
        return AppUtil.isValidEmailId(emailId: emailId!)
    }
    
    @objc func dismissViewTapped(_ gesture : UITapGestureRecognizer){
        self.view.removeFromSuperview()
        self.removeFromParent()
        accountUpdateDelegate?.accountUpdated()
    }
}

