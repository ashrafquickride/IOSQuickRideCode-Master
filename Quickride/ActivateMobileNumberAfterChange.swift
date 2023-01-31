//
//  ActivateMobileNumberAfterChange.swift
//  Quickride
//
//  Created by QuickRideMac on 12/23/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ActivateMobileNumberAfterChange: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var dismissView: UIView!
    
    @IBOutlet weak var activateView: UIView!
    
    @IBOutlet weak var activationCodeText: UITextField!
    
    @IBOutlet weak var activateViewCenterYConstraint: NSLayoutConstraint!
    @IBOutlet weak var activateBtn: UIButton!
    
    var phoneNumber : String?
    var countryCode : String?
    var isKeyBoardVisible = false
    var accountUpdateDelegate : AccountUpdateDelegate?
    
    private static let RESEND_ACTIVATION_CODE = 02
    
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        handleBrandingChangesBasedOnTarget()
        activationCodeText.delegate = self
        ViewCustomizationUtils.addCornerRadiusToView(view: activateView, cornerRadius: 5.0)
        activateBtn.backgroundColor = Colors.mainButtonColor
      
        dismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ActivateMobileNumberAfterChange.dismissView(_:))))
        NotificationCenter.default.addObserver(self, selector: #selector(ActivateMobileNumberAfterChange.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ActivateMobileNumberAfterChange.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func handleBrandingChangesBasedOnTarget()
    {
        ViewCustomizationUtils.addCornerRadiusToView(view: activateBtn, cornerRadius: 3.0)
    }

  func initializeDataBeforePresenting(phoneNumber : String,countryCode : String?,accountUpdateDelegate : AccountUpdateDelegate?){
        self.phoneNumber = phoneNumber
        self.countryCode = countryCode
        self.accountUpdateDelegate = accountUpdateDelegate
    
    }

    @IBAction func activateBtnTapped(_ sender: Any) {
        if activationCodeText.text?.count == 0
        {
            MessageDisplay.displayAlert(messageString: Strings.activation_code_empty,viewController: self,handler: nil)
        }
        else{
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.updateMobileNumber(userId: (QRSessionManager.getInstance()?.getUserId())!,newMobileNo: phoneNumber!,countryCode: countryCode,activationCode: activationCodeText.text!, activationStatus:
                nil, appName : AppConfiguration.APP_NAME, viewController: self)
            {
                responseObject, error in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    self.dismiss(animated: false)
                    UIApplication.shared.keyWindow?.makeToast( Strings.mobile_number_successfully)
                    UserDataCache.getInstance()!.storeLoggedInUserContactNo(contactNo: self.phoneNumber!)
                    UserDataCache.getInstance()!.storeLoggedInUserCountryCode(countryCode: self.countryCode!)
                    QRSessionManager.getInstance()!.updateUserContactNo(phoneNo: self.phoneNumber!)
                    QRSessionManager.getInstance()!.updateUserCountryCode(countryCode: self.countryCode)
                    self.accountUpdateDelegate?.accountUpdated()
                    
                }
                else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            }
        }
    }
    
    @objc func dismissView(_ sender: UITapGestureRecognizer)
    {
        self.view.removeFromSuperview()
        self.removeFromParent()
        dismiss(animated: false)
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
        activateViewCenterYConstraint.constant = -keyBoardSize.height/2
      }
      
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        activateViewCenterYConstraint.constant = 0
    }

    @IBAction func resendCodeBtnClicked(_ sender: Any) {
        self.resendActivationCode()
    }
    
    func resendActivationCode() {
        AppDelegate.getAppDelegate().log.debug("")
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
          QuickRideProgressSpinner.startSpinner()
        let user = UserDataCache.getInstance()?.currentUser!.copy() as? User
       
        var putBodyDictionary = ["phone" : StringUtils.getStringFromDouble(decimalNumber: user!.contactNo)]
        putBodyDictionary[User.FLD_APP_NAME] = AppConfiguration.APP_NAME
        putBodyDictionary[User.FLD_COUNTRY_CODE] = countryCode
        UserRestClient.resendVerficiationCode(putBodyDictionary: putBodyDictionary, uiViewController: self, completionHandler: {
            
            responseObject, error in
            
            QuickRideProgressSpinner.stopSpinner()
            
            AppDelegate.getAppDelegate().log.debug("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UIApplication.shared.keyWindow?.makeToast( Strings.activation_code_resent)
                
            }
            else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }

}
