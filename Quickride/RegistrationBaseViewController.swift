//
//  RegistrationBaseViewController.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 10/05/17.
//  Copyright © 2017 iDisha. All rights reserved.
//

import Foundation
import GoogleMaps
import ObjectMapper
import TrueSDK
import NetCorePush

class RegistrationBaseViewController: UIViewController,UITextFieldDelegate,TCTrueSDKDelegate {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var phoneNumberField: UITextField!
    @IBOutlet weak var bottomSpaceToSuperview: NSLayoutConstraint!
    
    @IBOutlet weak var emailIDTextField: UITextField!
    
    @IBOutlet weak var appliedPromoCodeLabel: UILabel!
    
    @IBOutlet weak var changePromoCodeButton: UIButton!
    
    @IBOutlet weak var changePromoCodeView: UIView!
    
    @IBOutlet weak var promoCodeButton: UIButton!
    
    @IBOutlet weak var promoCodeImgBtn: UIButton!
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var trueCallerView: UIView!
    
    @IBOutlet weak var maleButton: UIButton!
    
    @IBOutlet weak var femaleButton: UIButton!
    
    @IBOutlet weak var notToSayButton: UIButton!
    
    @IBOutlet weak var seperationView: UIView!
    
    @IBOutlet weak var emptyFieldAlertLabel: UILabel!
    
    @IBOutlet weak var emptyFieldAlertHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var phoneNoSeperationView: UIView!
    
    @IBOutlet weak var passwordSeperationView: UIView!
    
    @IBOutlet weak var nameSeperationView: UIView!
    
    @IBOutlet weak var emailSeperationView: UIView!
    
    @IBOutlet weak var phoneTextFieldTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var registrationBonusPointsLbl: UILabel!
    
    
    @IBOutlet weak var registrationBonusPointsTxtLblHeightConstraint: NSLayoutConstraint!
    var phoneNumber : String?
    var password : String?
    var gender : String?
    var isKeyBoardVisible = false
    var phoneCode: String?
    var trueCallerProfile : TCTrueProfile?
    var promocode : String?
    var applyPromoCodeView : ApplyPromoCodeDialogueView?
    
    func initializeDataBeforePresentingView(phone: String?, password: String?, phoneCode : String?, email : String?) {
        self.phoneCode = phoneCode
        self.phoneNumber = phone
        self.password = password
        
    }
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        ViewCustomizationUtils.addCornerRadiusToView(view: maleButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: maleButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        ViewCustomizationUtils.addCornerRadiusToView(view: femaleButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: femaleButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        ViewCustomizationUtils.addCornerRadiusToView(view: notToSayButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: notToSayButton, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        ViewCustomizationUtils.addCornerRadiusToView(view: signUpButton, cornerRadius: 10.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: seperationView, cornerRadius: 3.0)
        self.hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view, typically from a nib.
        self.phoneNumberField.delegate = self
        self.passwordField.delegate = self
        self.nameField.delegate = self
        self.emailIDTextField.delegate = self
        // Scrollview Settings
        self.scrollView.contentSize = CGSize(width: 320,height: 800)
        self.automaticallyAdjustsScrollViewInsets = false
        self.nameField.autocapitalizationType = UITextAutocapitalizationType.words
        if (self.phoneNumber != nil) {
            self.phoneNumberField.text = self.phoneNumber!
        }
        if (self.password != nil) {
            self.passwordField.text = self.password!
        }
       
        if let coupon = SignUpStepsViewController.checkAndReturnSystemCouponIfPresent(usageContext: SystemCouponCode.COUPON_USUAGE_CONTEXT_REGISTER){
            self.registrationBonusPointsLbl.isHidden = false
            self.registrationBonusPointsTxtLblHeightConstraint.constant = 60
            self.registrationBonusPointsLbl.text =  String(format: Strings.registration_bonus_text, arguments: ["\u{20B9}",StringUtils.getStringFromDouble(decimalNumber: coupon.cashDeposit)])
            let attributedString = NSMutableAttributedString(string: self.registrationBonusPointsLbl.text!)
            let range = NSRange(location: 20, length: StringUtils.getStringFromDouble(decimalNumber: coupon.cashDeposit).count + 1)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(netHex: 0x00B557), range: range)
            self.registrationBonusPointsLbl.attributedText = attributedString
        }else{
           self.registrationBonusPointsLbl.isHidden = true
            self.registrationBonusPointsTxtLblHeightConstraint.constant = 10
        }


        self.changePromoCodeView.isHidden = true
        self.changePromoCodeButton.isHidden = true

        if phoneCode == nil{
            phoneCode = AppConfiguration.DEFAULT_PHONE_CODE
        }
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationBaseViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(RegistrationBaseViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        if #available(iOS 10.0, *){
            self.phoneTextFieldTrailingConstraint.constant = -100
            self.trueCallerView.isHidden = true
        }
        else{
            TCTrueSDK.sharedManager().delegate = self
            if TCTrueSDK.sharedManager().isSupported(){
                self.trueCallerView.isHidden = false
                self.phoneTextFieldTrailingConstraint.constant = 0
                self.trueCallerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(RegistrationBaseViewController.trueCallerViewTapped(_:))))
            }
            else{
                self.phoneTextFieldTrailingConstraint.constant = -100
                self.trueCallerView.isHidden = true
            }
        }
        phoneNumberField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        passwordField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        nameField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        emailIDTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        if SharedPreferenceHelper.getCurrentUserReferralCode() != nil{
            self.applyPromoCodeAndEnableChangePromoCodeButton(promoCodeString: SharedPreferenceHelper.getCurrentUserReferralCode()!)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewWillAppear(animated)
        self.emptyFieldAlertLabel.isHidden = true
        self.emptyFieldAlertHeightConstraint.constant = 0
        self.navigationController?.isNavigationBarHidden = true
        self.nameField.autocapitalizationType = UITextAutocapitalizationType.words
    }
    override func viewDidAppear(_ animated: Bool) {
        signupActionColorChange()
        self.seperationView.applyGradient(colours: [UIColor(netHex:0x74fb8f), UIColor(netHex:0x47c760)])
    }
    @objc func trueCallerViewTapped(_ gesture : UITapGestureRecognizer){
        TCTrueSDK.sharedManager().requestTrueProfile()
    }
    func fillDetailsFromTrueCaller(profile: TCTrueProfile)
    {
        if profile.countryCode != nil && (profile.phoneNumber!.range(of: phoneCode!) != nil)
        {
            let number = profile.phoneNumber!.dropFirst(phoneCode!.count)
            self.phoneNumberField.text = String(number)
        }
        else
        {
            self.phoneNumberField.text = profile.phoneNumber
        }
        self.nameField.text = profile.firstName
        self.emailIDTextField.text = profile.email
    }

    @IBAction func signUp(_ sender: UIButton) {
        self.view.endEditing(false)
        doSignup()
    }
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.view.layer.add(CustomExtensionUtility.transitionEffectWhilePopingView(), forKey:kCATransition)
        self.navigationController?.popViewController(animated: false)
    }
    
    private func doSignup() {
        AppDelegate.getAppDelegate().log.debug("")
        emailIDTextField.text = emailIDTextField.text!.replacingOccurrences(of: " ", with: "")
        let validationErrorMsg = validateFieldsAndReturnErrorMsgIfAny()
        if (validationErrorMsg != nil) {
            self.emptyFieldAlertLabel.isHidden = false
            self.emptyFieldAlertHeightConstraint.constant = 20
            self.emptyFieldAlertLabel.text = "* " + validationErrorMsg!
            return
        }

        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }

        if NumberUtils.validateTextFieldForSpecialCharacters(textField: phoneNumberField, viewController: self){
            return
        }
        if self.trueCallerProfile !=  nil && (self.trueCallerProfile!.phoneNumber == phoneCode! + self.phoneNumberField.text!)
        {
            self.continueRegistration(status : Strings.status_activated)
        }
        else
        {
            self.continueRegistration(status : "")

        }
    }
    
    func handleResponse(newUser : User,responseObject :NSDictionary?,error :NSError?){
        AppDelegate.getAppDelegate().log.debug("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
        QuickRideProgressSpinner.stopSpinner()
        if responseObject != nil {
            if responseObject!["result"] as! String == "SUCCESS"
            {
                SharedPreferenceHelper.storeCurrentUserReferralCode(referralCode: nil)
                 let user = Mapper<User>().map(JSONObject: responseObject!["resultData"])
                user!.password = self.passwordField.text!
                 AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_SIGNED_UP, params: [
                    "source" : "email",
                    "email" : emailIDTextField.text!,
                    "userId" : user!.phoneNumber
                    ])

                
                var profilePushDictionary : [AnyHashable : Any]?
                
                if let userRefererInfo = SharedPreferenceHelper.getUserRefererInfo(){
                    profilePushDictionary = ["NAME": user?.userName as Any,"MOBILE": StringUtils.getStringFromDouble(decimalNumber: user?.contactNo),"MEDIUM_SOURCE" : userRefererInfo.medium as Any,"CAMPAIGN" : userRefererInfo.campaign as Any]
                }else{
                    profilePushDictionary = ["NAME": user?.userName as Any,"MOBILE": StringUtils.getStringFromDouble(decimalNumber: user?.contactNo)]
                 }
                NetCoreInstallation.sharedInstance().netCorePushLogin(StringUtils.getStringFromDouble(decimalNumber: user?.phoneNumber), block: nil)
                NetCoreInstallation.sharedInstance().netCoreProfilePush(StringUtils.getStringFromDouble(decimalNumber: user!.phoneNumber), payload:profilePushDictionary!, block:nil)
                
                 
                let userProfile = UserProfile(user : user!, emailForCommunication: emailIDTextField.text)
                if let user = UserDataCache.getInstance()?.currentUser{
                   CleverTapAnalyticsUtils.getInstance().trackProfileEvent(userProfile: userProfile, user: user)
                }
                
                NewUserDataInitialiser(phoneNo : self.phoneNumberField.text!,countryCode : phoneCode,password : self.passwordField.text!, newUser: user, userProfile: userProfile, isSuspendedUser : false,viewController : self).getUserAndInitializeSession()
            }
            else if responseObject!["result"] as! String == "FAILURE" {
                let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                if responseError!.errorCode == UserMangementException.USER_NOT_ACTIVATED{
                    MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self, handler: { (result) in
                        NewUserDataInitialiser(phoneNo : self.phoneNumberField.text!,countryCode : self.phoneCode,password : self.passwordField.text!, newUser: nil, userProfile: nil, isSuspendedUser : false,viewController : self).getUserAndInitializeSession()
                    })
                }
                if responseError!.errorCode == UserMangementException.USER_ALREADY_EXIST
                {
                    handleExistingUserFailure(responseError: responseError!)
                } else {
                    DispatchQueue.main.async(execute: { () -> Void in
                        MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self,handler: nil)
                    })
                }
            }
        }
        else {
            ErrorProcessUtils.handleError(error: error, viewController: self, handler: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       textField.endEditing(false)
        return false
    }
    @objc func textFieldDidChange(textField : UITextField){
        signupActionColorChange()
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        CustomExtensionUtility.changeBtnColor(sender: self.signUpButton, color1: Colors.lightGrey, color2: Colors.lightGrey)
        signUpButton.isUserInteractionEnabled = false
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.emptyFieldAlertLabel.isHidden = true
        self.emptyFieldAlertHeightConstraint.constant = 0
        self.phoneNoSeperationView.backgroundColor = Colors.lightGrey
        self.passwordSeperationView.backgroundColor = Colors.lightGrey
        self.nameSeperationView.backgroundColor = Colors.lightGrey
        self.emailSeperationView.backgroundColor = Colors.lightGrey
        if textField == phoneNumberField{
            addDoneButton(textField: phoneNumberField)
        }
        if textField == emailIDTextField{
            ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0,y: 80))
        }
        else{
            ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0,y: 20))
        }
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == true{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is visible")
            return
        }
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            bottomSpaceToSuperview.constant = keyBoardSize.height+10
            isKeyBoardVisible = true
        }
    }
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyBoardVisible == false{
            AppDelegate.getAppDelegate().log.debug("KeyBoard is not visible")
            return
        }
        isKeyBoardVisible = false
        bottomSpaceToSuperview.constant = 10
    }
    func addDoneButton(textField :UITextField){
        let keyToolBar = UIToolbar()
        keyToolBar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: view, action: #selector(UIView.endEditing(_:)))
        keyToolBar.items = [flexBarButton,doneBarButton]
        
        textField.inputAccessoryView = keyToolBar
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == nameField{
            threshold = 200
        }else{
            return true
        }
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold!
    }
    
    func signupActionColorChange(){
        if phoneNumberField.text != nil && phoneNumberField.text?.isEmpty == false && passwordField.text != nil && passwordField.text?.isEmpty == false && nameField.text != nil && nameField.text?.isEmpty == false && emailIDTextField.text != nil && emailIDTextField.text?.isEmpty == false{
            CustomExtensionUtility.changeBtnColor(sender: self.signUpButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            signUpButton.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: self.signUpButton, color1: UIColor.lightGray, color2: UIColor.lightGray)
            signUpButton.isUserInteractionEnabled = false
        }
    }

    func validateFieldsAndReturnErrorMsgIfAny() -> String?
    {
        AppDelegate.getAppDelegate().log.debug("")
        if (nameField.text?.isEmpty == true && passwordField.text?.isEmpty == true && phoneNumberField.text?.isEmpty == true && emailIDTextField.text?.isEmpty == true){
            self.passwordSeperationView.backgroundColor = Colors.red
            self.phoneNoSeperationView.backgroundColor = Colors.red
            self.nameSeperationView.backgroundColor = Colors.red
            self.emailSeperationView.backgroundColor = Colors.red
            return Strings.fill_all_required_fields
        }
        if (phoneNumberField.text?.isEmpty == true)
        {
            self.phoneNoSeperationView.backgroundColor = Colors.red
            return Strings.fill_all_required_fields
        }
        if (passwordField.text?.isEmpty == true )
        {
            self.passwordSeperationView.backgroundColor = Colors.red
            return Strings.fill_all_required_fields
        }
        if (nameField.text == nil || nameField.text?.isEmpty == true )
        {
            self.nameSeperationView.backgroundColor = Colors.red
            return Strings.fill_all_required_fields
        }
        if UserProfileValidationUtils.validateStringForAlphabatic(string: nameField.text!) == false{
            return Strings.enter_valid_name
        }
        if (emailIDTextField.text?.isEmpty == true )
        {
            self.emailSeperationView.backgroundColor = Colors.red
            return Strings.fill_all_required_fields
        }
        if self.gender == nil{
           return "Please select gender"
        }
        else if AppUtil.isValidEmailId(emailId: emailIDTextField.text!) == false {
            return Strings.enter_valid_email_id
        }
        if (AppUtil.isValidPhoneNo(phoneNo: phoneNumberField.text!, countryCode: phoneCode)) {
            return nil
        }
        else {
            return Strings.enter_valid_phone_no
        }
    }
    
    func createUserProfileFromExistingData(user : User) -> UserProfile{
        let userProfile : UserProfile = UserProfile()
        userProfile.userName = user.userName
        userProfile.userId = Double(user.phoneNumber)
        userProfile.confirmType = false
        userProfile.gender = user.gender
        
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        userProfile.rideMatchPercentageAsRider = clientConfiguration!.rideMatchDefaultPercentageRider
        userProfile.rideMatchPercentageAsPassenger = clientConfiguration!.rideMatchDefaultPercentagePassenger
        return userProfile
    }
    
    @IBAction func promoCodeVerification(_ sender: UIButton) {
        self.view.endEditing(false)
        applyPromoCode()
    }
    @IBAction func changePromoCodeButtonClicked(_ sender: UIButton) {
        self.promoCodeButton.isHidden = false
        self.promoCodeImgBtn.isHidden = false
        self.changePromoCodeView.isHidden = true
        self.changePromoCodeButton.isHidden = true
        self.promocode = nil
    }
    func applyPromoCode()
    {
        AppDelegate.getAppDelegate().log.debug("")
        var negativeBtnTitle : String?
        #if WERIDE
            negativeBtnTitle = nil
        #else
            negativeBtnTitle = Strings.cancel_caps
        #endif
        
        applyPromoCodeView = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard,bundle: nil).instantiateViewController(withIdentifier: "ApplyPromoCodeDialogueView") as? ApplyPromoCodeDialogueView
        
        applyPromoCodeView!.initializeDataBeforePresentingView(title: Strings.apply_promo_code, positiveBtnTitle: Strings.apply_caps, negativeBtnTitle: negativeBtnTitle, promoCode: promocode, isCapitalTextRequired: true, viewController: self, placeHolderText: Strings.apply_promo_code, handler: { (text, result) in
            if Strings.apply_caps == result{
                if text != nil {
                self.verifyReferralCode(promoCode: text)
                }
            }
        })
        if ViewControllerUtils.getCenterViewController().navigationController != nil{
            ViewControllerUtils.getCenterViewController().view.addSubview(applyPromoCodeView!.view)
            ViewControllerUtils.getCenterViewController().navigationController!.addChild(applyPromoCodeView!)
        }else{
            ViewControllerUtils.getCenterViewController().view.addSubview(applyPromoCodeView!.view)
            ViewControllerUtils.getCenterViewController().addChild(applyPromoCodeView!)
        }
        applyPromoCodeView!.view.layoutIfNeeded()
    }
    
    func verifyReferralCode(promoCode : String?){
        QuickRideProgressSpinner.startSpinner()
        
        UserRestClient.verifyReferral(referralCode: promoCode!, uiViewController: self, completionHandler: {
            responseObject, error in
            AppDelegate.getAppDelegate().log.debug("responseObject = \(String(describing: responseObject)); error = \(String(describing: error))")
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil {
                if responseObject!["result"] as! String == "SUCCESS" {
                    self.applyPromoCodeAndEnableChangePromoCodeButton(promoCodeString: promoCode!)
                    self.applyPromoCodeView?.view.removeFromSuperview()
                    self.applyPromoCodeView?.removeFromParent()
                    self.applyPromoCodeView = nil
               }
                else if responseObject!["result"] as! String == "FAILURE" {
                    let responseError = Mapper<ResponseError>().map(JSONObject: responseObject!["resultData"])
                    self.applyPromoCodeView?.handleResponseError(responseError: responseError!)
                }
            }
            else{
                ErrorProcessUtils.handleError(error: error, viewController: self, handler: nil)
            }
        })
    }
    
    func applyPromoCodeAndEnableChangePromoCodeButton(promoCodeString: String)
    {
        AppDelegate.getAppDelegate().log.debug("")
        self.promoCodeButton.isHidden = true
        self.promoCodeImgBtn.isHidden = true
        self.changePromoCodeView.isHidden = false
        self.appliedPromoCodeLabel.text = promoCodeString + " promo code applied successfully!"
        self.promocode = promoCodeString
        self.changePromoCodeButton.isHidden = false
    }
    
    func continueRegistration(status : String?)
    {
        QuickRideProgressSpinner.startSpinner()
        let newUser = User()
        newUser.phoneNumber = Double(phoneNumberField.text!)!
        newUser.password = String(passwordField.text!)
        newUser.userName = String(nameField.text!)
        if gender == nil{
            self.gender = User.USER_GENDER_UNKNOWN
            notToSayButton.backgroundColor = Colors.darkGrey
            notToSayButton.setTitleColor(UIColor.white, for: .normal)
            ViewCustomizationUtils.addBorderToView(view: notToSayButton, borderWidth: 1.0, color: Colors.darkGrey)
        }
        newUser.gender = gender!
        if (self.promocode != nil && self.promocode!.isEmpty == false) {
            newUser.appliedPromoCode = self.promocode
        }
        let versionName = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        if versionName == nil || versionName!.isEmpty {
            newUser.iosAppVersionName = AppConfiguration.APP_CURRENT_VERSION_NO
        }
        else
        {
            newUser.iosAppVersionName = versionName
        }
        let modelName = UIDevice.current.model
        let systemVersion = UIDevice.current.systemVersion
        newUser.phoneModel = modelName + " " + systemVersion
        newUser.countryCode = phoneCode
        newUser.uniqueDeviceId = DeviceUniqueIDProxy().getDeviceUniqueId()
        newUser.googleAdvertisingId = AppDelegate.getAppDelegate().getIDFA()
        if status != nil
        {
            newUser.status = status!
        }
        createUser(user: newUser)
    }
    func createUser(user : User){
        
    }

    func navigateToVerificationViewController(newUser : User,isExistingUser : Bool){
        
    }
    func handleExistingUserFailure(responseError : ResponseError){
        
    }
    func didReceive(_ profile: TCTrueProfile)
    {
        
       self.trueCallerProfile = profile
        
        if self.trueCallerProfile != nil
        {
            fillDetailsFromTrueCaller(profile : profile)
        }
    }
    func didFailToReceiveTrueProfileWithError(_ error: TCError) {
        
    }
    
    @IBAction func genderInfoTapped(_ sender: Any) {
        MessageDisplay.displayInfoViewAlert(title: Strings.gender_info_title, message: Strings.gender_info_msg, infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil) {
        }

    }
    
}
