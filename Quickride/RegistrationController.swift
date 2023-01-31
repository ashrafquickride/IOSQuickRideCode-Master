//
//  RegistrationController.swift
//  Quickride
//
//  Created by KNM Rao on 18/09/15.
//  Copyright © 2015 iDisha Info Labs Pvt Ltd. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import ObjectMapper
import GoogleMaps
import TrueSDK

class RegistrationController: RegistrationBaseViewController {
    
    
    @IBOutlet var termsButton: UIButton!
    @IBOutlet var termsLabel: UILabel!
    @IBOutlet weak var SignUpAgreeText: UILabel!

    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        #if GRIDE
            termsLabel.isHidden = true
            termsButton.isHidden = true
        #elseif MYRIDE
            termsLabel.isHidden = false
            termsButton.isHidden = false
            termsButton.setTitle("MyRide Terms", for: .normal)
        #else
            termsLabel.isHidden = false
            termsButton.isHidden = false
        #endif
        
        promoCodeButton.setTitleColor(Colors.defaultTextColor, for: UIControl.State.normal)
        
        changePromoCodeButton.setTitleColor(Colors.defaultTextColor, for: UIControl.State.normal)
        maleButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RegistrationController.maleGenderSelected(_:))))
        femaleButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RegistrationController.femaleGenderSelected(_:))))
        notToSayButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RegistrationController.noGenderSelected(_:))))
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    @objc func maleGenderSelected(_ sender: UITapGestureRecognizer){
        self.emptyFieldAlertLabel.isHidden = true
        self.emptyFieldAlertHeightConstraint.constant = 0
        maleButton.backgroundColor = Colors.darkGrey
        femaleButton.backgroundColor = UIColor.white
        notToSayButton.backgroundColor = UIColor.white
        maleButton.setTitleColor(UIColor.white, for: .normal)
        femaleButton.setTitleColor(Colors.darkGrey, for: .normal)
        notToSayButton.setTitleColor(Colors.darkGrey, for: .normal)
        self.gender = User.USER_GENDER_MALE
        ViewCustomizationUtils.addBorderToView(view: maleButton, borderWidth: 1.0, color: Colors.darkGrey)
        ViewCustomizationUtils.addBorderToView(view: femaleButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        ViewCustomizationUtils.addBorderToView(view: notToSayButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
    }
    @objc func femaleGenderSelected(_ sender: UITapGestureRecognizer){
        self.emptyFieldAlertLabel.isHidden = true
        self.emptyFieldAlertHeightConstraint.constant = 0
        maleButton.backgroundColor = UIColor.white
        femaleButton.backgroundColor = UIColor(netHex:0x636363)
        notToSayButton.backgroundColor = UIColor.white
        maleButton.setTitleColor(Colors.darkGrey, for: .normal)
        femaleButton.setTitleColor(UIColor.white, for: .normal)
        notToSayButton.setTitleColor(Colors.darkGrey, for: .normal)
        self.gender = User.USER_GENDER_FEMALE
        ViewCustomizationUtils.addBorderToView(view: femaleButton, borderWidth: 1.0, color: Colors.darkGrey)
        ViewCustomizationUtils.addBorderToView(view: maleButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        ViewCustomizationUtils.addBorderToView(view: notToSayButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
    }
    @objc func noGenderSelected(_ sender: UITapGestureRecognizer){
        self.emptyFieldAlertLabel.isHidden = true
        self.emptyFieldAlertHeightConstraint.constant = 0
        maleButton.backgroundColor = UIColor.white
        femaleButton.backgroundColor = UIColor.white
        notToSayButton.backgroundColor = Colors.darkGrey
        maleButton.setTitleColor(Colors.darkGrey, for: .normal)
        femaleButton.setTitleColor(Colors.darkGrey, for: .normal)
        notToSayButton.setTitleColor(UIColor.white, for: .normal)
        self.gender = User.USER_GENDER_UNKNOWN
        ViewCustomizationUtils.addBorderToView(view: femaleButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        ViewCustomizationUtils.addBorderToView(view: notToSayButton, borderWidth: 1.0, color: Colors.darkGrey)
         ViewCustomizationUtils.addBorderToView(view: maleButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
    }
    override func fillDetailsFromTrueCaller(profile: TCTrueProfile)
    {
        super.fillDetailsFromTrueCaller(profile: profile)
        if profile.gender.rawValue != 0
        {
            if profile.gender.rawValue == 1
            {
                self.gender = User.USER_GENDER_MALE
                maleButton.backgroundColor = Colors.darkGrey
                ViewCustomizationUtils.addBorderToView(view: maleButton, borderWidth: 1.0, color: Colors.darkGrey)
            }
            else if profile.gender.rawValue == 2
            {
                self.gender = User.USER_GENDER_FEMALE
                femaleButton.backgroundColor = Colors.darkGrey
                ViewCustomizationUtils.addBorderToView(view: femaleButton, borderWidth: 1.0, color: Colors.darkGrey)
            }
        }
    }
    override func createUser(user : User){
        var params = user.getParams()
        params["emailforcommunication"] = self.emailIDTextField.text
        params[User.TIME_ZONE_OFF_SET] = StringUtils.getStringFromDouble(decimalNumber: DateUtils.getTimeZoneOffSet())
        
      let userRefInfo = SharedPreferenceHelper.getUserRefererInfo()
        if userRefInfo != nil && userRefInfo!.isValid(){
            for item in userRefInfo!.getParams(){
               params[item.0] = item.1
            }
        }
        UserRestClient.createUser(userPostDictionary : params, targetViewController: self){
            responseObject, error in
            self.handleResponse(newUser: user,responseObject:responseObject,error:error)
        }
    }
    
    override func validateFieldsAndReturnErrorMsgIfAny() -> String? {
        return super.validateFieldsAndReturnErrorMsgIfAny()
    }
    
    override func applyPromoCode(){
        super.applyPromoCode()
    }
    
    @IBAction func showTermsAndConditions(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("termsAndCondPage()")
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  HelpViewController.TERMSURL)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.terms, url: urlcomps!.url!)
            self.navigationController?.pushViewController(webViewController, animated: false)
        }else{
            UIApplication.shared.keyWindow?.makeToast(message: Strings.cant_open_this_web_page)
        }
    }
    
    override func applyPromoCodeAndEnableChangePromoCodeButton(promoCodeString: String){
        super.applyPromoCodeAndEnableChangePromoCodeButton(promoCodeString: promoCodeString)
    }
    
    
    override func navigateToVerificationViewController(newUser user :User ,isExistingUser : Bool){
        let verificationViewController : VerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerificationViewController") as! VerificationViewController
        
        verificationViewController.initializeDataBeforePresenting(userId: phoneNumberField.text!, countryCode: AppConfiguration.DEFAULT_COUNTRY_CODE_IND, password: passwordField.text!, email: emailIDTextField.text, companyName: nil, userObj: nil, userProfile: nil, isSuspendedUser: false, resendCodeRequired: false)
        
        self.navigationController?.view.layer.add(CustomExtensionUtility.transitionEffectWhilePushingView(), forKey: kCATransition)
        self.navigationController?.pushViewController(verificationViewController, animated: false)
    }
    override func handleExistingUserFailure(responseError : ResponseError){
        AppDelegate.getAppDelegate().log.debug("\(responseError)")
        DispatchQueue.main.async(execute: { () -> Void in
            QuickRideProgressSpinner.stopSpinner()
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: responseError.userMessage, message2: nil, positiveActnTitle: Strings.login_caps,negativeActionTitle : Strings.skip_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if result == Strings.login_caps{
                    let loginViewController : LoginController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "LoginController") as! LoginController
                    loginViewController.initializeDataBeforePresentingView(phone: String(self.phoneNumberField.text!), password: String(self.passwordField.text!))
                   
                   self.navigationController?.view.layer.add(CustomExtensionUtility.transitionEffectWhilePushingView(), forKey: kCATransition)
                    self.navigationController?.pushViewController(loginViewController, animated: false)
                }
                else
                {
                    self.phoneNumberField.becomeFirstResponder()
                }
            })
        })
    }
}
