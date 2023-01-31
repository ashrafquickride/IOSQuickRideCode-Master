//
//  VerifyOrganisationViewController.swift
//  Quickride
//
//  Created by Vinutha on 04/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie
import TransitionButton

class VerifyOrganisationViewController: UIViewController {

    //MARK: Outlets
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var navigationTitleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var verifyOrganisationView: UIView!
    @IBOutlet weak var emailTextFiled: UITextField!
    @IBOutlet weak var sendOrSubmitOtpButton: TransitionButton!
    @IBOutlet weak var enodorsementAndOrgIdVerificationView: UIView!
    @IBOutlet weak var otpLoaderAnimationView: AnimationView!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var congratsAnimationView: AnimationView!
    @IBOutlet weak var sendOtpButtomConstraint: NSLayoutConstraint!
    @IBOutlet weak var otpVerificationView: UIView!
    @IBOutlet weak var otpSentLabel: UILabel!
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var otpDurationLabel: UILabel!
    @IBOutlet weak var resendOtpButton: UIButton!
    @IBOutlet weak var tryOtherMethodView: UIView!
    @IBOutlet weak var verifyByCompanyIdViewSeperator: UIView!
    @IBOutlet weak var verifyByCompanyIdButton: UIButton!
    @IBOutlet weak var verifyByEndorsementButton: UIButton!
    @IBOutlet weak var verifyByCompanyIdView: UIView!

    //MARK: Properties
    private var isKeyboardVisible : Bool = false
    private var countdownTimer: Timer!
    private var timeLeft = 30
    private var isCompanyIdVerified = false
    private var isVerifiedByEndorsement = false
    private var verifyOrganisationViewModel = VerifyOrganisationViewModel()
     var isFromSignUpFlow = false
    var showingPage = true

    func IntialDateHidding(isFromSignUpFlow: Bool){
        self.isFromSignUpFlow =  isFromSignUpFlow

    }

    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        verifyByEndorsementButton.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        setUpUI()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    //MARK: Methods
    private func setUpUI() {
        handleViewCustomization()
        verifyOrganisationViewModel.delegate = self
        tryOtherMethodView.isHidden = true
        successView.isHidden = true
        enodorsementAndOrgIdVerificationView.isHidden = true
        verifyByCompanyIdView.isHidden = true
        let profileVerificationData = UserDataCache.getInstance()?.getLoggedInUserProfile()?.profileVerificationData
        if let email = UserDataCache.getInstance()?.getLoggedInUserProfile()?.email, !email.isEmpty, profileVerificationData?.emailVerificationStatus == ProfileVerificationData.PENDING {
            otpSentLabel.text = String(format: Strings.otp_sent_to, arguments: [email])
            verifyOrganisationView.isHidden = true
            otpLoaderAnimationView.isHidden = true
            otpVerificationView.isHidden = false
            sendOrSubmitOtpButton.isHidden = false
            sendOrSubmitOtpButton.setTitle("SUBMIT OTP", for: .normal)
            startTimer()
            if let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData(), profileVerificationData.emailVerified, profileVerificationData.profVerifSource == 3 {
                verifyByCompanyIdView.isHidden = true
            } else {
                UserDataCache.getInstance()?.getCompanyIdVerificationData(handler: {(companyIdVerificationData) in
                    if companyIdVerificationData == nil {
                        self.verifyByCompanyIdView.isHidden = false
                    }
                })
            }
        } else {
            if profileVerificationData?.emailVerificationStatus == ProfileVerificationData.INITIATED || profileVerificationData?.emailVerificationStatus == ProfileVerificationData.REJECTED {
                showVerificationStatus()
            }
            if let email =  UserDataCache.getInstance()?.getLoggedInUserProfile()?.email, !email.isEmpty {
                emailTextFiled.text = email
            }
            verifyByEndorsementButton.isHidden = true
            verifyByCompanyIdButton.isHidden = true
            verifyByCompanyIdViewSeperator.isHidden = true
            if profileVerificationData?.noOfEndorsers ?? 0 > 0 {
                isVerifiedByEndorsement = true
                verifyByEndorsementButton.isHidden = true
            } else {
                isVerifiedByEndorsement = false
                verifyByEndorsementButton.isHidden = true
            }
            if let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData(), profileVerificationData.emailVerified, profileVerificationData.profVerifSource == 3 {
                isCompanyIdVerified = true
                verifyByCompanyIdViewSeperator.isHidden = true
                verifyByCompanyIdButton.isHidden = true
                handleVisibilityOfVerifyEmailBtn(textField: self.emailTextFiled)
            } else {
                UserDataCache.getInstance()?.getCompanyIdVerificationData(handler: {(companyIdVerificationData) in
                    if companyIdVerificationData != nil {
                        self.isCompanyIdVerified = true
                    } else {
                        self.isCompanyIdVerified = false
                        if !self.isVerifiedByEndorsement {
                            self.verifyByCompanyIdViewSeperator.isHidden = false
                        }
                        self.verifyByCompanyIdButton.isHidden = false
                    }
                    self.handleVisibilityOfVerifyEmailBtn(textField: self.emailTextFiled)
                })
            }
            verifyOrganisationView.isHidden = false
            sendOrSubmitOtpButton.isHidden = false
            sendOrSubmitOtpButton.setTitle("SEND OTP", for: .normal)
        }
    }

    private func handleViewCustomization() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        emailTextFiled.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField1.addTarget(self, action: #selector(textFieldDidChangeForVericationCode(textField:)), for: UIControl.Event.editingChanged)
        otpTextField2.addTarget(self, action: #selector(textFieldDidChangeForVericationCode(textField:)), for: UIControl.Event.editingChanged)
        otpTextField3.addTarget(self, action: #selector(textFieldDidChangeForVericationCode(textField:)), for: UIControl.Event.editingChanged)
        otpTextField4.addTarget(self, action: #selector(textFieldDidChangeForVericationCode(textField:)), for: UIControl.Event.editingChanged)
        ViewCustomizationUtils.addCornerRadiusToView(view: otpTextField1, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: otpTextField2, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: otpTextField3, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: otpTextField4, cornerRadius: 5.0)
    }

    deinit{
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyBoardWillShow(notification : NSNotification){
        if (!isKeyboardVisible) {
            if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                sendOtpButtomConstraint.constant = keyBoardSize.height - 30
            }
        }
        isKeyboardVisible = true
    }

    @objc func keyBoardWillHide(notification: NSNotification){
        if (isKeyboardVisible) {
            sendOtpButtomConstraint.constant = 0
        }
        isKeyboardVisible = false
    }

    @objc private func textFieldDidChange(textField : UITextField){
        handleVisibilityOfVerifyEmailBtn(textField: textField)
    }

    private func handleVisibilityOfVerifyEmailBtn(textField : UITextField){
        if textField.text == nil || textField.text!.isEmpty{
            sendOrSubmitOtpButton.isUserInteractionEnabled = false
            sendOrSubmitOtpButton.backgroundColor = UIColor(netHex: 0xC7C7CC)
            if isCompanyIdVerified && isVerifiedByEndorsement {
                enodorsementAndOrgIdVerificationView.isHidden = true
            } else {
                enodorsementAndOrgIdVerificationView.isHidden = false
            }
        }else{
            enodorsementAndOrgIdVerificationView.isHidden = true
            sendOrSubmitOtpButton.isUserInteractionEnabled = true
            sendOrSubmitOtpButton.backgroundColor = UIColor(netHex: 0x00B557)
        }
    }

    @objc func textFieldDidChangeForVericationCode(textField : UITextField){
        let text = textField.text
        if text?.utf16.count == 1{

            switch textField {
            case otpTextField1:
                handleUIUpdateBasedOnTextFieldText(textField: otpTextField1)
                otpTextField2.becomeFirstResponder()
            case otpTextField2:
                handleUIUpdateBasedOnTextFieldText(textField: otpTextField2)
                otpTextField3.becomeFirstResponder()
            case otpTextField3:
                handleUIUpdateBasedOnTextFieldText(textField: otpTextField3)
                otpTextField4.becomeFirstResponder()
            case otpTextField4:
                handleUIUpdateBasedOnTextFieldText(textField: otpTextField4)
                otpTextField4.resignFirstResponder()
                sendOrSubmitOtpButton.isUserInteractionEnabled = true
                sendOrSubmitOtpButton.backgroundColor = UIColor(netHex: 0x00B557)
            default:
                break
            }

        }else{
            switch textField {
            case otpTextField4:
                resetTextFieldBackGroundColor(textField: otpTextField4)
                otpTextField4.resignFirstResponder()
                otpTextField3.becomeFirstResponder()
            case otpTextField3:
                resetTextFieldBackGroundColor(textField: otpTextField3)
                otpTextField3.resignFirstResponder()
                otpTextField2.becomeFirstResponder()
            case otpTextField2:
                resetTextFieldBackGroundColor(textField: otpTextField2)
                otpTextField2.resignFirstResponder()
                otpTextField1.becomeFirstResponder()
            case otpTextField1:
                resetTextFieldBackGroundColor(textField: otpTextField1)
                otpTextField1.becomeFirstResponder()
            default:
                break
            }
        }
    }

    private func resetTextFieldBackGroundColor(textField : UITextField){
        textField.backgroundColor = UIColor(netHex: 0xe7e7e7)
        ViewCustomizationUtils.addBorderToView(view: textField, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
        sendOrSubmitOtpButton.isUserInteractionEnabled = false
        sendOrSubmitOtpButton.backgroundColor = UIColor(netHex: 0xC7C7CC)
    }

    private func handleUIUpdateBasedOnTextFieldText(textField : UITextField){
        if textField.text!.isEmpty{
            textField.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: textField, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
        }else{
            textField.backgroundColor = .white
            ViewCustomizationUtils.addBorderToView(view: textField, borderWidth: 1.0, color: UIColor(netHex: 0xe1e1e1))
        }
    }

    private func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }

    @objc private func updateTime() {
        resendOtpButton.isHidden = true
        otpDurationLabel.isHidden = false
        otpDurationLabel.text = "\(timeFormatted(timeLeft))"
        if timeLeft != 0 {
            timeLeft -= 1
        } else {
            endTimer()
        }
    }

    private func endTimer() {
        countdownTimer.invalidate()
        resendOtpButton.isHidden = false
        otpDurationLabel.isHidden = true
        tryOtherMethodView.isHidden = false
    }

    private func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func closeView() {
        if isFromSignUpFlow {
        let pledgeVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "QuickridePledgeViewController") as! QuickridePledgeViewController
        pledgeVC.initializeDataBeforePresenting(titles: Strings.pledge_titles, messages: Strings.pledge_details_ride_giver, images: Strings.pledgeImages, actionName: Strings.i_agree_caps, heading: Strings.pledge_title_text) { () in
            let userProfile = UserDataCache.getInstance()?.userProfile
            if userProfile?.preferredRole == UserProfile.PREFERRED_ROLE_RIDER{
                SharedPreferenceHelper.setDisplayStatusForRideGiverPledge(status: true)
            }else{
                SharedPreferenceHelper.setDisplayStatusForRideTakerPledge(status: true)
            }
            RideManagementUtils.updateStatusAndNavigate(isFromSignupFlow: true, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
        }
        self.navigationController?.pushViewController(pledgeVC , animated: false)
        }else {
            self.navigationController?.popViewController(animated: false)
        }
    }
    private func showVerificationStatus() {
        if let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile(), let range = userProfile.email?.range(of: "@") {
            let domain = "@" + (userProfile.email?[range.upperBound...] ?? "")
            let verificationStatusViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerificationStatusViewController") as! VerificationStatusViewController
            verificationStatusViewController.initializeVerificationView(companyName: userProfile.companyName ?? "", status: userProfile.profileVerificationData?.emailVerificationStatus ?? "", emailDomain: String(domain ))
            ViewControllerUtils.addSubView(viewControllerToDisplay: verificationStatusViewController)
        }
    }

    //MARK: Actions
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }



    @IBAction func verifyByOrganisationIdClicked(_ sender: Any) {
        let organisationIDCardVerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OrganisationIDCardVerificationViewController" ) as! OrganisationIDCardVerificationViewController
        organisationIDCardVerificationViewController.pageissue(myagree : false)
        self.navigationController?.pushViewController(organisationIDCardVerificationViewController, animated: false)

    }

    @IBAction func resendOTPClicked(_ sender: Any) {
        verifyOrganisationViewModel.resendOTP(viewController: self)
    }

    @IBAction func tryOtherMethodClicked(_ sender: UIButton) {
        let sendEmailForVerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard,bundle: nil).instantiateViewController(withIdentifier: "SendEmailForVerificationViewController") as! SendEmailForVerificationViewController
        sendEmailForVerificationViewController.initialiseData { (action) in
            if action == Strings.success {
                self.closeView()
            }
        }
        ViewControllerUtils.addSubView(viewControllerToDisplay: sendEmailForVerificationViewController)
    }

    @IBAction func sendOrSubmitOtpClicked(_ sender: UIButton) {
        if otpVerificationView.isHidden {
            if let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile(), let email = userProfile.email, !email.isEmpty, email == emailTextFiled.text, let profileVerificationData = UserDataCache.getInstance()?.getLoggedInUserProfile()?.profileVerificationData, (profileVerificationData.emailVerificationStatus == ProfileVerificationData.INITIATED || profileVerificationData.emailVerificationStatus == ProfileVerificationData.REJECTED) {
               UIApplication.shared.keyWindow?.makeToast( "Email not editted")
                return
            }
            if !AppUtil.isValidEmailId(emailId: emailTextFiled.text!){
                UIApplication.shared.keyWindow?.makeToast(Strings.enter_valid_email_id)
                return
            }
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.ORG_EMAIL_ENTERED, params: ["UserId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
            startSpinning()
            verifyOrganisationViewModel.saveUserProfile(email: emailTextFiled.text!, viewController: self)
        } else {
            let verificationText = otpTextField1.text! + otpTextField2.text! + otpTextField3.text! + otpTextField4.text!
            if let email = UserDataCache.getInstance()?.getLoggedInUserProfile()?.email {
                startSpinning()
                verifyOrganisationViewModel.verifyProfile(verificationText: verificationText, viewController: self, email: email)
            }
        }
    }
}

//MARK: UITextFieldDelegate
extension VerifyOrganisationViewController: UITextFieldDelegate {

    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        handleVisibilityOfVerifyEmailBtn(textField: textField)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
      ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 0))
      textField.endEditing(true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == emailTextFiled {
            ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 0) )
        }
        if verifyOrganisationViewModel.errorOccured{
            verifyOrganisationViewModel.errorOccured = false
            otpTextField1.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: otpTextField1, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
            otpTextField2.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: otpTextField2, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
            otpTextField3.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: otpTextField3, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
            otpTextField4.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: otpTextField4, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
        }
    }
}

//MARK: Verify Organisation Ciew Model delegate
extension VerifyOrganisationViewController: ProfileVerificationViewModelDelegate {
    func displayEmailNotValidConfirmationDialog(userMessage: String) {}

    func handleOTPViewVisibility() {
        if let profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData(), profileVerificationData.emailVerified, profileVerificationData.profVerifSource == 3 {
            verifyByCompanyIdView.isHidden = true
        } else {
            UserDataCache.getInstance()?.getCompanyIdVerificationData(handler: {(companyIdVerificationData) in
                if companyIdVerificationData == nil {
                    self.verifyByCompanyIdView.isHidden = false
                }
            })
        }
        verifyOrganisationView.isHidden = true
        otpLoaderAnimationView.isHidden = true
        otpVerificationView.isHidden = false
        otpSentLabel.text = String(format: Strings.otp_sent_to, arguments: [emailTextFiled.text!])
        sendOrSubmitOtpButton.isUserInteractionEnabled = false
        sendOrSubmitOtpButton.backgroundColor = UIColor(netHex: 0xC7C7CC)
        sendOrSubmitOtpButton.isHidden = false
        sendOrSubmitOtpButton.setTitle("SUBMIT OTP", for: .normal)
        startTimer()
    }

    func closeVerificationView() {
        closeView()
    }

    func stopButtonAnimation() {}

    func startEmailVerifiedAnimation() {
        sendOrSubmitOtpButton.isHidden = true
        verifyOrganisationView.isHidden = true
        otpVerificationView.isHidden = true
        successView.isHidden = false
        congratsAnimationView.isHidden = false
        congratsAnimationView.animation = Animation.named("signup_congrats")
        congratsAnimationView.play()
        congratsAnimationView.loopMode = .loop
        stopEmailVerifiedAnimation()
    }

    func stopEmailVerifiedAnimation(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.congratsAnimationView.stop()
            self?.closeView()
        }
    }

    func startSpinning() {
        sendOrSubmitOtpButton.isHidden = true
        verifyOrganisationView.isHidden = true
        otpVerificationView.isHidden = true
        otpLoaderAnimationView.isHidden = false
        otpLoaderAnimationView.animation = Animation.named("loading_otp")
        otpLoaderAnimationView.play()
        otpLoaderAnimationView.loopMode = .loop
    }

    func stopSpinning() {
        sendOrSubmitOtpButton.isHidden = false
        verifyOrganisationView.isHidden = true
        otpVerificationView.isHidden = false
        otpLoaderAnimationView.isHidden = true
        otpLoaderAnimationView.stop()

    }
}
