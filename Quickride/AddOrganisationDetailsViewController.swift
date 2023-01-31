//
//  AddOrganisationDetailsViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 9/20/17.
//  Copyright © 2017 iDisha. All rights reserved.
//

import UIKit
import ObjectMapper
import Lottie

class AddOrganisationDetailsViewController: UIViewController, UITextFieldDelegate, UserEmailAndCompanyNameValidationReceiver 
{
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var companyNameLabel: UILabel!
    
    @IBOutlet weak var officeEmailIDTextField: UITextField!
    
    @IBOutlet weak var continueActnBtn: UIButton!
    
    @IBOutlet weak var skipActnBottomSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var emptyFieldAlertLabel: UILabel!
    
    @IBOutlet weak var emptyFieldAlertHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var emailSeperationView: UIView!
    
    @IBOutlet weak var labelRewardsPoints: UILabel!
    
    
    @IBOutlet weak var bonusPointsTxtlbl: UILabel!
    
    @IBOutlet weak var bonusPointsView: UIView!
    
    @IBOutlet weak var walletImageView: UIImageView!
    
    
    @IBOutlet weak var walletLoadingAnimationView: LOTAnimationView!
    
    var isKeyboardVisible : Bool = false
    var isOfficialDetailsUpdated : Bool = false
    var topViewController : SignUpStepsViewController?
    var isFromActivationPage : Bool = false
    
    func initializeDataBeforePresentingView(isFromActivationPage: Bool)
    {
        self.isFromActivationPage = isFromActivationPage
    }
    override func viewDidLoad()
    {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.emptyFieldAlertLabel.isHidden = true
        self.emptyFieldAlertHeightConstraint.constant = 0
        fillData()
        ViewCustomizationUtils.addCornerRadiusToView(view: continueActnBtn, cornerRadius: 10.0)
        officeEmailIDTextField.delegate = self
        NotificationCenter.default.addObserver(self, selector:  #selector(AddOrganisationDetailsViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddOrganisationDetailsViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        officeEmailIDTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        continueActionColorChange()
    }
    func fillData()
    {
        let userProfile = SharedPreferenceHelper.getUserProfileObject()
        if userProfile != nil {
            if userProfile!.userName != nil{
                nameLabel.text = String(format: Strings.user_name_label_signUp1, arguments: [userProfile!.userName!])
            }
            if userProfile!.email != nil && userProfile!.email!.isEmpty == false{
                officeEmailIDTextField.text = userProfile!.email
            }
        }
        
        if let coupon = SignUpStepsViewController.checkAndReturnSystemCouponIfPresent(usageContext: SystemCouponCode.COUPON_USUAGE_CONTEXT_ADDED_VALID_COMPANY){
            
            self.bonusPointsView.isHidden = false
            walletImageView.isHidden = false
            walletLoadingAnimationView.isHidden = false
            refreshAccountInfo()
            self.bonusPointsTxtlbl.text = String(format: Strings.org_bonus_points_text, arguments: [Strings.percentage_symbol,"\u{20B9}",StringUtils.getStringFromDouble(decimalNumber: coupon.cashDeposit)])
            let attributedString = ViewCustomizationUtils.createNSAttributeWithParagraphStyle(string: self.bonusPointsTxtlbl.text!)
            let range = NSRange(location: 74, length: StringUtils.getStringFromDouble(decimalNumber: coupon.cashDeposit).count + 10)
            attributedString?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(netHex: 0x00B557), range: range)
            self.bonusPointsTxtlbl.attributedText = attributedString
        }else{
            walletImageView.isHidden = true
            walletLoadingAnimationView.isHidden = true
            self.bonusPointsView.isHidden = true
            self.bonusPointsTxtlbl.text = Strings.org_text_without_bonus
            let attributedString = ViewCustomizationUtils.createNSAttributeWithParagraphStyle(string: self.bonusPointsTxtlbl.text!)
            self.bonusPointsTxtlbl.attributedText = attributedString
            
        }
    }
    
    func refreshAccountInfo(){
        self.bonusPointsView.isHidden = true
        walletLoadingAnimationView.setAnimation(named : "wallet_loading")
        walletLoadingAnimationView.isHidden = false
        walletLoadingAnimationView.play()
        walletLoadingAnimationView.loopAnimation = true
        if let userProfile = SharedPreferenceHelper.getUserProfileObject(){
            AccountRestClient.getAccountInfo(userId: StringUtils.getPointsInDecimal(points: userProfile.userId), targetViewController: nil, completionHandler: { (responseObject, error) -> Void in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let userAccount = Mapper<Account>().map(JSONObject: responseObject!["resultData"])
                    self.walletLoadingAnimationView.stop()
                    self.walletLoadingAnimationView.isHidden = true
                    self.labelRewardsPoints.text = StringUtils.getPointsInDecimal(points: userAccount!.rewardsPoints)
                    self.bonusPointsView.isHidden = false
                }
            })
        }
    }
   
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    private func isEmailIdValid(emailId : String?) -> Bool {
        AppDelegate.getAppDelegate().log.debug("")
        
        return AppUtil.isValidEmailId(emailId: emailId!)
    }
    @objc func textFieldDidChange(textField : UITextField){
        continueActionColorChange()
    }
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
         CustomExtensionUtility.changeBtnColor(sender: self.continueActnBtn, color1: UIColor.lightGray, color2: UIColor.lightGray)
        continueActnBtn.isUserInteractionEnabled = false
        return true
    }
    func continueActionColorChange(){
        if officeEmailIDTextField.text != nil && officeEmailIDTextField.text?.isEmpty == false
        {
            CustomExtensionUtility.changeBtnColor(sender: self.continueActnBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            continueActnBtn.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: self.continueActnBtn, color1: UIColor.lightGray, color2: UIColor.lightGray)
            continueActnBtn.isUserInteractionEnabled = false
        }
    }
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if isKeyboardVisible == true{
            return
        }
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
            skipActnBottomSpaceConstraint.constant = keyBoardSize.height+35
            isKeyboardVisible = true
            ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0,y: keyBoardSize.height-40))
        }
    }
    
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("")
        if (isKeyboardVisible) {
            skipActnBottomSpaceConstraint.constant = 30
        }
        ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0,y: 0))
        isKeyboardVisible = false
    }
    
    func validateFieldsAndReturnErrorMsgIfAny() -> String? {
        AppDelegate.getAppDelegate().log.debug("")
        
        if officeEmailIDTextField.text != nil && officeEmailIDTextField.text!.isEmpty == false && isEmailIdValid(emailId: officeEmailIDTextField.text) == false  {
            return Strings.enter_valid_email_id
        }
        return nil
    }
    func checkWhetherOfficialEmailIdValid() -> Bool{
        AppDelegate.getAppDelegate().log.debug("")
        if officeEmailIDTextField.text != nil && officeEmailIDTextField.text!.isEmpty == false{
            self.isOfficialDetailsUpdated = true
            if !UserProfileValidationUtils.isOrganisationEmailIdIsValid(orgEmail: officeEmailIDTextField.text!){
                MessageDisplay.displayAlert( messageString: Strings.invalid_org_email_msg, viewController: self,handler: nil)
                return false
            }else if UserProfile.checkIsOfficeEmailAndConveyAccordingly(emailId: officeEmailIDTextField.text) == false {
                self.displayEmailNotValidConfirmationDialog(userMessage: Strings.not_official_email_dialog)
                
                return false
            }
            return true
        }
        else
        {
            return true
        }
    }
    func displayEmailNotValidConfirmationDialog(userMessage : String)
    {
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: userMessage, message2: nil, positiveActnTitle: Strings.change_caps, negativeActionTitle : Strings.skip_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.skip_caps == result{
                self.continueSaving()
            }
            else{
                self.officeEmailIDTextField.becomeFirstResponder()
            }
        })
    }
    
    func displayEmailNotMatchingConfirmationDialog(userMessage : String){
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: userMessage, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.yes_caps == result{
                self.continueSaving()
            }
            else{
                self.officeEmailIDTextField.becomeFirstResponder()
            }
        })
    }
    @IBAction func continueActnBtnTapped(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("")
        self.view.endEditing(true)
        let validationErrorMsg = validateFieldsAndReturnErrorMsgIfAny()
        if (validationErrorMsg != nil) {
            self.emailSeperationView.backgroundColor = Colors.red
            self.emptyFieldAlertLabel.isHidden = false
            self.emptyFieldAlertHeightConstraint.constant = 20
            self.emptyFieldAlertLabel.text = "* " + validationErrorMsg!
            return
        }
        if !checkWhetherOfficialEmailIdValid()
        {
            return
        }
        if officeEmailIDTextField.text != nil && officeEmailIDTextField.text!.isEmpty == false{
            UserCompanyNameAndEmailValidator(email: officeEmailIDTextField.text!, viewController: self, listener: self).validate()
        }
       
    }
    
    
    func receiveEmailValid(valid : Bool, responseErrorCode : Int)
    {
        if !valid
        {
            self.displayEmailNotMatchingConfirmationDialog(userMessage: Strings.email_not_matching_with_company_dialog)
        }else{
            self.continueSaving()
        }
    }
    func displayInfoDialog(valid : Bool, responseErrorCode : Int)
    {
        if valid == true{
            if let range = officeEmailIDTextField.text!.range(of: "@") {
                let domainName = officeEmailIDTextField.text![range.upperBound...]
                if let userProfile = SharedPreferenceHelper.getUserProfileObject(){
                    userProfile.companyName = String(domainName)
                    SharedPreferenceHelper.storeUserProfileObject(userProfileObj: userProfile)
                }
                self.continueSaving()
            }
        }
    }
    func continueSaving(){
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ORGANIZATION_DETAILS, value: true)
        let userProfile = SharedPreferenceHelper.getUserProfileObject()
        if isOfficialDetailsUpdated && userProfile != nil
        {
            if self.officeEmailIDTextField.text!.isEmpty == false{
                userProfile?.email = self.officeEmailIDTextField.text!
            }else{
                userProfile?.email = nil
            }
            SharedPreferenceHelper.storeUserProfileObject(userProfileObj: userProfile!)
            ProfileRestClient.putProfileWithBody(targetViewController: self, body: userProfile!.getParamsMap()) { (responseObject, error) -> Void in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    let userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"])
                    AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_PROFFESSION_DETAILS_SIGN_UP, params: [
                        "org_email" : self.officeEmailIDTextField.text!])
                    self.isOfficialDetailsUpdated = false
                    SharedPreferenceHelper.setSavingStatusForKey(key: SharedPreferenceHelper.SAVING_STATUS_ORG_DETAILS, status: true)
                }else {
                    SharedPreferenceHelper.setSavingStatusForKey(key: SharedPreferenceHelper.SAVING_STATUS_ORG_DETAILS, status: false)
                }
                self.topViewController?.refreshAccountInformation()
            }
            if self.isFromActivationPage{
                self.moveToAccountActivationPage()
            }else{
                self.topViewController?.moveToSelectedView(index: 2)
            }
        }
        else
        {
            if self.isFromActivationPage{
                self.moveToAccountActivationPage()
            }
            SharedPreferenceHelper.setSavingStatusForKey(key: SharedPreferenceHelper.SAVING_STATUS_ORG_DETAILS, status: true)
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.emptyFieldAlertLabel.isHidden = true
        self.emptyFieldAlertHeightConstraint.constant = 0
        self.emailSeperationView.backgroundColor = Colors.lightGrey
    }
    
    @IBAction func skipBtnClicked(_ sender: Any) {
        self.view.endEditing(true)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_ORGANIZATION_DETAILS, value: true)
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.SAVING_STATUS_ORG_DETAILS, value: true)
        if self.isFromActivationPage{
            self.moveToAccountActivationPage()
        }
        else{
            self.topViewController?.moveToSelectedView(index: 2)
        }
    }
    func moveToAccountActivationPage(){
        let vc = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AccountActivationAndVerificationViewController") as! AccountActivationAndVerificationViewController
        vc.initializeDataBeforePresenting(userProfile: SharedPreferenceHelper.getUserProfileObject(), userObj: SharedPreferenceHelper.getUserObject())
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: vc, animated: false)
        
    }
    
}
