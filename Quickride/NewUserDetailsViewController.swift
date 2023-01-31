//
//  NewUserDetailsViewController.swift
//  Quickride
//
//  Created by Admin on 06/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import TransitionButton
import FBSDKLoginKit
import GoogleSignIn
import AuthenticationServices
import CoreLocation

class NewUserDetailsViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userNameTextView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailTextView: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var maleGenderButton: UIButton!
    @IBOutlet weak var femaleGenderButton: UIButton!
    @IBOutlet weak var unknownGenderButton: UIButton!
    @IBOutlet weak var promoCodeButton: UIButton!
    @IBOutlet weak var promoCodeImgButton: UIButton!
    @IBOutlet weak var changePromoCodeView: UIView!
    @IBOutlet weak var appliedPromoCodeLabel: UILabel!
    @IBOutlet weak var changePromoCodeButton: UIButton!
    @IBOutlet weak var errorMessageLbl: UILabel!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var googleLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var socialLoginView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var maleLabel: UILabel!
    @IBOutlet weak var nottosayLabel: UILabel!
    @IBOutlet weak var femaleLabel: UILabel!
    
    @IBOutlet weak var notToSayImage: UIImageView!
    @IBOutlet weak var femaleimage: UIImageView!
    @IBOutlet weak var maleimage: UIImageView!
    //MARK: Properties
    private var applyPromoCodeView : ApplyPromoCodeDialogueView?
    private var newUserDetailsViewModel : NewUserDetailsViewModel?
    private let locationManager = CLLocationManager()
    var viewFrame = UIView()

   
    

    //MARK: ViewModelInitializer
    func initializeDataBeforePresenting(contactNo : String?,otp : String?,enableWhatsAppPreferences: Bool?){
        newUserDetailsViewModel = NewUserDetailsViewModel(contactNo: contactNo, otp: otp, enableWhatsAppPreferences: enableWhatsAppPreferences)
    }
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        handleViewCustomization()
        changePromoCodeView.isHidden = true
        checkAndFillUserDetails()
//        newUserDetailsViewModel?.delegate = self
        setupSOAppleSignIn()
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
        handleSignUpBtnColorChange()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        newUserDetailsViewModel?.fbSocialUserProfile = nil
        newUserDetailsViewModel?.googleSocialUserProfile = nil
        newUserDetailsViewModel?.socialNetworkType = nil
    }
    
    func setupSOAppleSignIn() {
        if #available(iOS 13.0, *) {
            let btnAuthorization = ASAuthorizationAppleIDButton()
            btnAuthorization.isHidden = true
            appleButton.isHidden = false
        }
    }
    
    //MARK: Methods
    private func handleViewCustomization(){
        ViewCustomizationUtils.addCornerRadiusToView(view: maleGenderButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: maleGenderButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        ViewCustomizationUtils.addCornerRadiusToView(view: femaleGenderButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: femaleGenderButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        ViewCustomizationUtils.addCornerRadiusToView(view: unknownGenderButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: unknownGenderButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        ViewCustomizationUtils.addCornerRadiusToView(view: userNameTextView, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: emailTextView, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: headerView, cornerRadius: 3.0)
        userNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        userNameTextField.becomeFirstResponder()
        emailTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        googleLoginButton.addShadow()
        facebookLoginButton.addShadow()
        appleButton.addShadow()
    }
    
    private func handleGenderButtonViewCustomization(maleButtonBackgroundColor : UIColor,femaleButtonBackgroundColor : UIColor,unknownButtonBackgroundColor : UIColor,maleButtonTitleColor : UIColor,femaleButtonTitleColor : UIColor,unknownButtonTitleColor : UIColor,gender : String,maleButtonBorderColor : UIColor,femaleButtonBorderColor : UIColor,unknownButtonBorderColor : UIColor){
        maleGenderButton.backgroundColor = maleButtonBackgroundColor
        femaleGenderButton.backgroundColor = femaleButtonBackgroundColor
        unknownGenderButton.backgroundColor = unknownButtonBackgroundColor
        maleGenderButton.setTitleColor(maleButtonTitleColor, for: .normal)
       femaleGenderButton.setTitleColor(femaleButtonTitleColor, for: .normal)
        unknownGenderButton.setTitleColor(unknownButtonTitleColor, for: .normal)
        newUserDetailsViewModel?.gender = gender
        ViewCustomizationUtils.addBorderToView(view: maleGenderButton, borderWidth: 1.0, color: maleButtonBorderColor)
        ViewCustomizationUtils.addBorderToView(view: femaleGenderButton, borderWidth: 1.0, color: femaleButtonBorderColor)
        ViewCustomizationUtils.addBorderToView(view: unknownGenderButton, borderWidth: 1.0, color: unknownButtonBorderColor)
    }
    
    private func applyPromoCode(){
        applyPromoCodeView = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard,bundle: nil).instantiateViewController(withIdentifier: "ApplyPromoCodeDialogueView") as? ApplyPromoCodeDialogueView
        
        applyPromoCodeView!.initializeDataBeforePresentingView(title: Strings.apply_promo_code, positiveBtnTitle: Strings.apply_caps, negativeBtnTitle: Strings.cancel_caps, promoCode: newUserDetailsViewModel?.promocode, isCapitalTextRequired: true, viewController: self, placeHolderText: Strings.apply_promo_code, promoCodeAppliedMsg: String(format: Strings.referral_code_applied, arguments: [newUserDetailsViewModel?.promocode ?? ""]), handler: { [weak self](text, result) in
            if Strings.apply_caps == result{
                if text != nil {
                    self?.verifyReferral(promoCode : text!)
                }
            }
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: applyPromoCodeView!)
        applyPromoCodeView!.view.layoutIfNeeded()
    }
    
    private func verifyReferral(promoCode : String){
        QuickRideProgressSpinner.startSpinner()
        newUserDetailsViewModel?.verifyReferralCode(promoCode: promoCode, viewController: self) { [weak self] (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            guard let self = `self` else{
                return
            }
            if responseObject != nil {
                if responseObject!["result"] as! String == "SUCCESS" {
                    self.applyPromoCodeView?.showPromoAppliedMessage(message: String(format: Strings.referral_code_applied, arguments: [promoCode]))
                    self.applyPromoCodeAndEnableChangePromoCodeButton(promoCodeString: promoCode)
                }else if responseObject!["result"] as! String == "FAILURE" {
                    if  let responseError = self.newUserDetailsViewModel?.getResponseError(responseObject: responseObject){
                        self.applyPromoCodeView?.handleResponseError(responseError: responseError,responseObject: responseObject,error: error)
                    }
                }
            }else{
                self.applyPromoCodeView?.handleResponseError(responseError: nil,responseObject: responseObject,error: error)
            }
        }
    }
    
    private func applyPromoCodeAndEnableChangePromoCodeButton(promoCodeString: String){
        promoCodeButton.isHidden = true
        promoCodeImgButton.isHidden = true
        changePromoCodeView.isHidden = false
        appliedPromoCodeLabel.text = promoCodeString + " referral code applied successfully!"
        newUserDetailsViewModel?.promocode = promoCodeString
        changePromoCodeButton.isHidden = false
    }
    
    private func handleRegistrationBasedOnSocialNetworkType(){
        if let gender = newUserDetailsViewModel?.gender,let name = userNameTextField.text,let email = emailTextField.text{
            if newUserDetailsViewModel?.socialNetworkType != nil{
                newUserDetailsViewModel?.registerNewSocialUser(otp: newUserDetailsViewModel!.otp!, gender: gender, name: name, promocode: newUserDetailsViewModel?.promocode, email: email, viewController: self) { completed in
                    if completed {
                        self.removeAnimationView()
                    }
                }
            }else{
                newUserDetailsViewModel?.registerNewUser(otp: newUserDetailsViewModel!.otp!, gender: gender, name: name, promocode: newUserDetailsViewModel?.promocode, email: email, viewController: self) { completed in
                    if completed {
                        self.removeAnimationView()
                    }
                }
            }
        }
    }
    
    private func validateTextFieldAndShowErrorIfAny() -> String?{
        
        if userNameTextField.text?.isEmpty == true && emailTextField.text?.isEmpty == true && newUserDetailsViewModel?.gender == nil{
            userNameTextView.backgroundColor = .white
            ViewCustomizationUtils.addBorderToView(view: userNameTextView, borderWidth: 1.0, color: .systemRed)
            emailTextView.backgroundColor = .white
            ViewCustomizationUtils.addBorderToView(view: emailTextView, borderWidth: 1.0, color: .systemRed)
            userNameTextView.shake()
            emailTextView.shake()
            return Strings.fill_all_required_fields
        }
        
        if userNameTextField.text == nil || userNameTextField.text!.isEmpty{
            userNameTextView.backgroundColor = .white
            userNameTextView.shake()
            ViewCustomizationUtils.addBorderToView(view: userNameTextView, borderWidth: 1.0, color: .systemRed)
            return Strings.enter_name
        }
        if UserProfileValidationUtils.validateStringForAlphabatic(string: userNameTextField.text!) == false{
            userNameTextView.backgroundColor = .white
            userNameTextView.shake()
            ViewCustomizationUtils.addBorderToView(view: userNameTextView, borderWidth: 1.0, color: .systemRed)
            return Strings.enter_valid_name
        }
        if emailTextField.text == nil || emailTextField.text!.isEmpty{
            emailTextView.backgroundColor = .white
            emailTextView.shake()
            ViewCustomizationUtils.addBorderToView(view: emailTextView, borderWidth: 1.0, color: .systemRed)
            return Strings.enter_email_id
        }
        if AppUtil.isValidEmailId(emailId: emailTextField.text!) == false {
            emailTextView.backgroundColor = .white
            emailTextView.shake()
            ViewCustomizationUtils.addBorderToView(view: emailTextView, borderWidth: 1.0, color: .systemRed)
            return Strings.enter_valid_communication_email_id
        }
        if newUserDetailsViewModel?.gender == nil{
            return "Please select gender"
        }
        return nil
    }
    
    private func checkAndFillUserDetails(){
        if let socialNetworkType = newUserDetailsViewModel?.socialNetworkType{
            if socialNetworkType == FBSocialUserProfile.socialNetworkTypeFB,let fbSocialUserProfile = newUserDetailsViewModel?.fbSocialUserProfile{
                userNameTextField.text = fbSocialUserProfile.firstName! + fbSocialUserProfile.lastName!
                emailTextField.text = fbSocialUserProfile.email
            }else if socialNetworkType == FBSocialUserProfile.socialNetworkTypeGoogle,let googleSocialUserProfile = newUserDetailsViewModel?.googleSocialUserProfile{
                userNameTextField.text = googleSocialUserProfile.fullName
                emailTextField.text = googleSocialUserProfile.email
            }else if socialNetworkType == AppleSocialUserProfile.socialNetworkTypeApple,let appleSocialUserProfile = newUserDetailsViewModel?.appleSocialUserProfile{
                if let firstName = appleSocialUserProfile.firstName, !firstName.isEmpty, let email = appleSocialUserProfile.email, !email.isEmpty{
                    userNameTextField.text = (appleSocialUserProfile.firstName ?? "") + " " + (appleSocialUserProfile.lastName ?? "")
                    emailTextField.text = email
                }else{
                    UIApplication.shared.keyWindow?.makeToast( Strings.appleId_error_msg, duration: 4.0)
                }
            }
        }
    }
    
    private func handleSignUpBtnColorChange() {
        if userNameTextField.text != nil,!userNameTextField.text!.isEmpty,emailTextField.text != nil,!emailTextField.text!.isEmpty,newUserDetailsViewModel?.gender != nil  {
            CustomExtensionUtility.changeBtnColor(sender: signUpButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            signUpButton.isUserInteractionEnabled = true
        } else {
            CustomExtensionUtility.changeBtnColor(sender: signUpButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
            signUpButton.isUserInteractionEnabled = false
        }
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        handleSignUpBtnColorChange()
    }
    
    private func handleSocialLogin(socialNetworkId : String,socialNetworkType : String){
        QuickRideProgressSpinner.startSpinner()
        newUserDetailsViewModel?.getSocialLoginUserStatus(userSocialNetworkId: socialNetworkId, userSocialNetworkType: socialNetworkType, viewController: self, handler: { [weak self] (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                if let socialUserStatus = self?.newUserDetailsViewModel?.getSocialUserStatusObject(responseObject: responseObject as NSDictionary?){
                    if let status = socialUserStatus.status,let userId = socialUserStatus.phone, let contactNo = socialUserStatus.contactNo{
                        self?.handleNavigationBasedOnSocialUserStatus(status: status, userId: StringUtils.getStringFromDouble(decimalNumber: userId), socialNetworkType: socialNetworkType, contactNo: contactNo)
                    }
                }
                
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
    
    private func handleNavigationBasedOnSocialUserStatus(status : String,userId : String,socialNetworkType : String?,contactNo: Double){
        if status == SocialUserStatus.status_new{
            checkAndFillUserDetails()
        }else{
            var errorMessage = ""
            let contactNumber = StringUtils.getStringFromDouble(decimalNumber: contactNo)
            if socialNetworkType == FBSocialUserProfile.socialNetworkTypeFB{
                errorMessage = String(format: Strings.facebook_registered_msg, arguments: ["xxxxxx" + contactNumber.suffix(4)])
            }else if socialNetworkType == FBSocialUserProfile.socialNetworkTypeGoogle{
                errorMessage = String(format: Strings.google_registered_msg, arguments: ["xxxxxx" + contactNumber.suffix(4)])
            }else if socialNetworkType == AppleSocialUserProfile.socialNetworkTypeApple{
                errorMessage = String(format: Strings.appleId_registered_msg, arguments: ["xxxxxx" + contactNumber.suffix(4)])
            }
            MessageDisplay.displayInfoViewAlert(title: Strings.mobile_no_already_registered, titleColor: nil, message: errorMessage, infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.login_caps) { [weak self] in
                let signUpSecondPhaseVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SignUpSecondPhaseViewController") as! SignUpSecondPhaseViewController
                signUpSecondPhaseVC.initializeView(mobileNo: contactNumber)
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: signUpSecondPhaseVC, animated: false)
            }
        }
    }
    
    
    
    private func addAnimationViewAsSubView() {
        viewFrame = UIView(frame: CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.size.width, height: view.frame.size.height))
        guard let displayVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AnimatedprofileViewController") as? AnimatedprofileViewController else {
            return
        }
        viewFrame.addSubview(displayVC.view)
        self.view.addSubview(viewFrame)
    }
        
    private func removeAnimationView(){
        viewFrame.removeFromSuperview()
    }
    
    
    
    
    //MARK: Actions
    @IBAction func signUpButtonClicked(_ sender: Any) {
      view.endEditing(true)
        if let errorMsg = validateTextFieldAndShowErrorIfAny(){
            errorMessageLbl.text = errorMsg
            return
        }
        addAnimationViewAsSubView()
        handleRegistrationBasedOnSocialNetworkType()
        
    }
    
    @IBAction func genderButtonClicked(_ sender: UIButton) {
        view.endEditing(false)
        switch sender.tag {
        case 1:
           
            handleGenderButtonViewCustomization(maleButtonBackgroundColor: .darkGray, femaleButtonBackgroundColor: .white, unknownButtonBackgroundColor: .white, maleButtonTitleColor: .white, femaleButtonTitleColor: .darkGray, unknownButtonTitleColor: .darkGray, gender: User.USER_GENDER_MALE, maleButtonBorderColor: .darkGray, femaleButtonBorderColor: UIColor(netHex:0xbbbbbb), unknownButtonBorderColor: UIColor(netHex:0xbbbbbb))
            maleLabel.textColor = UIColor.white
            nottosayLabel.textColor = UIColor.black
            femaleLabel.textColor = UIColor.black
            notToSayImage.image = UIImage(named: "notTosay")
            femaleimage.image = UIImage(named: "femaleSymbol")
            maleimage.image = UIImage(named: "male_whiteimg")
            
        case 2:
    
            handleGenderButtonViewCustomization(maleButtonBackgroundColor: .white, femaleButtonBackgroundColor: .darkGray, unknownButtonBackgroundColor: .white, maleButtonTitleColor: .darkGray, femaleButtonTitleColor: .white, unknownButtonTitleColor: .darkGray, gender: User.USER_GENDER_FEMALE, maleButtonBorderColor: UIColor(netHex:0xbbbbbb), femaleButtonBorderColor: .darkGray, unknownButtonBorderColor: UIColor(netHex:0xbbbbbb))
            femaleLabel.textColor = UIColor.white
            maleLabel.textColor = UIColor.black
            nottosayLabel.textColor = UIColor.black
            notToSayImage.image = UIImage(named: "notTosay")
            femaleimage.image = UIImage(named: "female_whiteimg")
            maleimage.image = UIImage(named: "male_symbol")
            
        case 3:
            nottosayLabel.textColor = UIColor.white
            handleGenderButtonViewCustomization(maleButtonBackgroundColor: .white, femaleButtonBackgroundColor: .white, unknownButtonBackgroundColor: .darkGray, maleButtonTitleColor: .darkGray, femaleButtonTitleColor: .darkGray, unknownButtonTitleColor: .white, gender: User.USER_GENDER_MALE, maleButtonBorderColor: UIColor(netHex:0xbbbbbb), femaleButtonBorderColor: UIColor(netHex:0xbbbbbb), unknownButtonBorderColor: .darkGray)
            nottosayLabel.textColor = UIColor.white
            maleLabel.textColor = UIColor.black
            femaleLabel.textColor = UIColor.black
            notToSayImage.image = UIImage(named: "notTosay_white")
            femaleimage.image = UIImage(named: "femaleSymbol")
            maleimage.image = UIImage(named: "male_symbol")
            
        default:
            break
        }
        handleSignUpBtnColorChange()
    }
    
    @IBAction func addPromoCodeButtonClicked(_ sender: Any){
        view.endEditing(false)
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.APPLY_PROMO_CLICKED, params: ["DeviceId" : DeviceUniqueIDProxy().getDeviceUniqueId() ?? 0], uniqueField: AnalyticsUtils.deviceId)
        applyPromoCode()
    }
    
    @IBAction func changePromoCodeButtonClicked(_ sender: Any) {
        promoCodeButton.isHidden = false
        promoCodeImgButton.isHidden = false
        changePromoCodeView.isHidden = true
        changePromoCodeButton.isHidden = true
        newUserDetailsViewModel?.promocode = nil
    }
    
    @IBAction func infoIconClicked(_ sender: Any) {
        MessageDisplay.displayInfoViewAlert(title: Strings.gender_info_title, titleColor: nil, message: Strings.gender_info_msg, infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {
        }
    }
    
    @IBAction func organisationEmailInfoClicked(_ sender: Any) {
        let orgnisationEmailViewController = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OrgnisationEmailViewController") as! OrgnisationEmailViewController
        ViewControllerUtils.addSubView(viewControllerToDisplay: orgnisationEmailViewController)
    }
    
    @IBAction func googleButtonTapped(_ sender: UIButton) {
        errorMessageLbl.text = ""
        GIDSignIn.sharedInstance.signIn(with: AppDelegate.getAppDelegate().googleSignInConfig!, presenting: self) { user, error in
            guard error == nil else { return }
            
            if let error = error {
                AppDelegate.getAppDelegate().log.debug("Google Login Error :- \(error.localizedDescription)")
                return
            }
            if let userData = user,let profile = userData.profile {
                let googleUser = GoogleSocialUserProfile(userId: userData.userID, givenName: userData.authentication.idToken, familyName: profile.familyName, fullName: profile.name, providerId: GoogleSocialUserProfile.socialNetworkTypeGoogle, email: profile.email, imageUrl: profile.hasImage ? profile.imageURL(withDimension: 600)?.absoluteString : nil)
                
                self.newUserDetailsViewModel?.googleSocialUserProfile = googleUser
                self.newUserDetailsViewModel?.socialNetworkType = FBSocialUserProfile.socialNetworkTypeGoogle
                self.handleSocialLogin(socialNetworkId: googleUser.userId ?? "", socialNetworkType: googleUser.providerId ?? "")
                
            }
            
            
        }
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.FIRST_PAGE_CTA_CLICK, params: ["DeviceId" : DeviceUniqueIDProxy().getDeviceUniqueId() ?? 0 ,"Type" : "Google"], uniqueField: AnalyticsUtils.deviceId)
    }
    
    @IBAction func facebookButtonTapped(_ sender: UIButton) {
        errorMessageLbl.text = ""
        newUserDetailsViewModel?.fetchUserProfileFromFB { [weak self] (result, error) in
            if error == nil {
                guard var socialUserProfile = self?.newUserDetailsViewModel?.getSocialUserProfile(responseObject: result as NSDictionary?) else{
                    return
                }
                self?.newUserDetailsViewModel?.fbSocialUserProfile = socialUserProfile
                self?.newUserDetailsViewModel?.socialNetworkType = FBSocialUserProfile.socialNetworkTypeFB
                socialUserProfile.providerId = FBSocialUserProfile.socialNetworkTypeFB
                self?.handleSocialLogin(socialNetworkId: socialUserProfile.id ?? "", socialNetworkType: socialUserProfile.providerId ?? "")
            }else{
                MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: error?.localizedDescription, message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: self, handler: nil)
            }
            
        }
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.FIRST_PAGE_CTA_CLICK, params: ["DeviceId" : DeviceUniqueIDProxy().getDeviceUniqueId() ?? 0 ,"Type" : "Facebook"], uniqueField: AnalyticsUtils.deviceId)
    }
    @IBAction func appleButtonTapped(_ sender: UIButton) {
        errorMessageLbl.text = ""
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
            QuickRideProgressSpinner.startSpinner()
        }
    }
}


//MARK: UITextFieldDelegate
extension NewUserDetailsViewController : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        userNameTextView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: userNameTextView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
        emailTextView.backgroundColor = UIColor(netHex: 0xE7E7E7)
        ViewCustomizationUtils.addBorderToView(view: emailTextView, borderWidth: 1.0, color: UIColor(netHex: 0xffffff))
        errorMessageLbl.text = ""
        handleSignUpBtnColorChange()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        handleSignUpBtnColorChange()
    }
}

//MARK: NewUserDetailsModelDelegate
//extension NewUserDetailsViewController : NewUserDetailsViewModelDelegate{
//    func startAnimation() {
//        displayVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AnimatedprofileViewController") as? AnimatedprofileViewController
//        self.view.addSubview(displayVC!.view)
//    }
//
//    func stopAnimation() {
//        displayVC!.view.removeFromSuperview()
//        displayVC = nil
//    }
//}

//MARK: ASAuthorizationControllerDelegate
extension NewUserDetailsViewController: ASAuthorizationControllerDelegate {
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        QuickRideProgressSpinner.stopSpinner()
        if let appleIDCredential = authorization.credential as?  ASAuthorizationAppleIDCredential {
            let fullName = appleIDCredential.fullName
            self.newUserDetailsViewModel?.socialNetworkType = AppleSocialUserProfile.socialNetworkTypeApple
            newUserDetailsViewModel?.appleSocialUserProfile = AppleSocialUserProfile(firstName: appleIDCredential.fullName?.givenName ?? "", lastName: appleIDCredential.fullName?.familyName ?? "", fullName: String(describing: fullName), email: appleIDCredential.email ?? "", providerId: AppleSocialUserProfile.socialNetworkTypeApple, id: appleIDCredential.user)
            handleSocialLogin(socialNetworkId: newUserDetailsViewModel?.appleSocialUserProfile?.id ?? "",socialNetworkType : newUserDetailsViewModel?.appleSocialUserProfile?.providerId ?? "")
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        QuickRideProgressSpinner.stopSpinner()
        print(error.localizedDescription)
        errorMessageLbl.text = error.localizedDescription
    }
}

extension NewUserDetailsViewController: ASAuthorizationControllerPresentationContextProviding {
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
