//
//  UserProfileVerificationViewController.swift
//  Quickride
//
//  Created by Vinutha on 05/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie
import DropDown

class UserProfileVerificationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var profileVerificationImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var currentStatusLabel: UILabel!
    @IBOutlet weak var emailVerificationView: UIView!
    @IBOutlet weak var emailTitleView: UIView!
    @IBOutlet weak var otpView: UIView!
    @IBOutlet weak var emailTextFieldView: UIView!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var emailVerificationStatusLabel: UILabel!
    @IBOutlet weak var emailVerificationSubTitleLabel: UILabel!
    @IBOutlet weak var otpVerificationSubTitleLabel: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var emailViewArrowButton: UIButton!
    @IBOutlet weak var sendOtpButton: UIButton!
    @IBOutlet weak var editEmailButton: UIButton!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var emailViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var govtIdVerificationView: UIView!
    @IBOutlet weak var govtIdVerificationStatusLabel: UILabel!
    @IBOutlet weak var govtIdVerificationSubTitleLabel: UILabel!
    @IBOutlet weak var adharVerificationButton: UIButton!
    @IBOutlet weak var dlVerificationButton: UIButton!
    @IBOutlet weak var adharVerificationViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dlVerificationViewHeight: NSLayoutConstraint!
    @IBOutlet weak var govtIdVerificationSubTitleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var dlVerificationViewViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var adharVerificationViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageVerificationView: UIView!
    @IBOutlet weak var imageVerificationTitleView: UIView!
    @IBOutlet weak var imageVerificationSubTitleView: UIView!
    @IBOutlet weak var imageVerificationSubTitleViewHeight: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var imageVerificationStatusLabel: UILabel!
    @IBOutlet weak var imageVerificationSubTitleLabel: UILabel!
    @IBOutlet weak var imageVerificationArrowButton: UIButton!
    @IBOutlet weak var addActionButton: UIButton!
    @IBOutlet weak var editOrRemoveActionView: UIView!
    @IBOutlet weak var profileVerificationInfoView: UIView!
    
    //MARK: domainStatus
    @IBOutlet weak var orgEmailStatusView: UIView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var verificationStatusLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var counterSlider: UISlider!
    @IBOutlet weak var counterLabel: UILabel!
    
    private let userProfileVerificationViewModel = UserProfileVerificationViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
          definesPresentationContext = true
        userProfileVerificationViewModel.initialiseData(profileVerificationData: UserDataCache.getInstance()?.getCurrentUserProfileVerificationData(), userProfile: UserDataCache.getInstance()?.getLoggedInUserProfile(), emailValidationDelegate: self, profileUpdateDelegate: self)
        emailTextField.delegate = self
        profileVerificationInfoView.addShadow()
        setUpCurrentVerificationStatusView()
        addTargetToTextFields()
        setUpDataEmailVerificationView()
        setUpGovtIDVerificationView()
        setUpImageVerificationView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        confirmNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    private func confirmNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(userProfileUpatedWithOrgEmail(_:)), name: .userProfileUpatedWithOrgEmail, object: userProfileVerificationViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(userProfileUpatedFailed(_:)), name: .userProfileUpatedFailed, object: userProfileVerificationViewModel)
        NotificationCenter.default.addObserver(self, selector: #selector(companyDomainStatusReceived(_:)), name: .companyDomainStatusReceived, object: userProfileVerificationViewModel)
    }
    
    @objc func userProfileUpatedWithOrgEmail(_ notification: Notification) {
        stopLoadingAnimation()
        otpView.isHidden = false
        emailTitleView.isHidden = true
        emailTextFieldView.isHidden = true
        setUpCurrentVerificationStatusView()
    }
    
    @objc func userProfileUpatedFailed(_ notification: Notification) {
        stopLoadingAnimation()
        otpView.isHidden = true
        emailTitleView.isHidden = false
        emailTextFieldView.isHidden = false
        setUpCurrentVerificationStatusView()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    private func addTargetToTextFields(){
        otpTextField1.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField2.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField3.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        otpTextField4.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
    }
    
    @objc func textFieldDidChange(textField : UITextField){
        let text = textField.text
        if text?.utf16.count == 1{
            
            switch textField {
            case otpTextField1:
                otpTextField2.becomeFirstResponder()
            case otpTextField2:
                otpTextField3.becomeFirstResponder()
            case otpTextField3:
                otpTextField4.becomeFirstResponder()
            case otpTextField4:
                otpTextField4.resignFirstResponder()
                verifyOTP()
            default:
                break
            }
            
        }
    }
    
    private func verifyOTP() {
        if otpTextField1.text == nil || otpTextField1.text!.isEmpty || otpTextField2 == nil || otpTextField2.text!.isEmpty || otpTextField3 == nil || otpTextField3.text!.isEmpty || otpTextField4 == nil || otpTextField4.text!.isEmpty
        {
            MessageDisplay.displayAlert(messageString: Strings.verification_code,  viewController: self,handler: nil)
            return
        }
        let verificationText = otpTextField1.text! + otpTextField2.text! + otpTextField3.text! + otpTextField4.text!
        if let userIdInString = QRSessionManager.getInstance()?.getUserId(), let userId = Double(userIdInString), let email = emailTextField.text {
            otpView.isHidden = true
            emailTitleView.isHidden = true
            emailTextFieldView.isHidden = true
            startLoadingAnimation()
            userProfileVerificationViewModel.verifyOtp(userId: userId, email: email, verificationCode: verificationText, viewController: self)
        }
    }
    
    private func setUpCurrentVerificationStatusView() {
        userNameLabel.text = userProfileVerificationViewModel.userProfile?.userName
        profileVerificationImageView.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: userProfileVerificationViewModel.profileVerificationData)
        if userProfileVerificationViewModel.profileVerificationData == nil {
            currentStatusLabel.text = Strings.current_status_not_verified
        } else if userProfileVerificationViewModel.profileVerificationData!.profileVerified && (userProfileVerificationViewModel.profileVerificationData!.emailVerified || userProfileVerificationViewModel.profileVerificationData!.isVerifiedFromEndorsement()) && (userProfileVerificationViewModel.profileVerificationData!.persIDVerified && !userProfileVerificationViewModel.profileVerificationData!.isVerifiedOnlyFromEndorsement()) {
            currentStatusLabel.text = Strings.current_status_verified
        } else if !userProfileVerificationViewModel.profileVerificationData!.profileVerified && (userProfileVerificationViewModel.profileVerificationData!.emailVerified || userProfileVerificationViewModel.profileVerificationData!.isVerifiedFromEndorsement()) && (userProfileVerificationViewModel.profileVerificationData!.persIDVerified && !userProfileVerificationViewModel.profileVerificationData!.isVerifiedOnlyFromEndorsement()) {
            currentStatusLabel.text = Strings.current_status_image_verification_pending
        } else if !userProfileVerificationViewModel.profileVerificationData!.emailVerified && !userProfileVerificationViewModel.profileVerificationData!.isVerifiedFromEndorsement() {
            if userProfileVerificationViewModel.profileVerificationData?.emailVerificationStatus == ProfileVerificationData.INITIATED{
                currentStatusLabel.text = Strings.new_company_addition_pending
            }else{
                currentStatusLabel.text = Strings.current_status_org_id_verification_pending
            }
        } else if !userProfileVerificationViewModel.profileVerificationData!.persIDVerified || (userProfileVerificationViewModel.profileVerificationData!.persIDVerified && userProfileVerificationViewModel.profileVerificationData!.isVerifiedOnlyFromEndorsement()) {
            currentStatusLabel.text = Strings.current_status_govt_id_verification_pending
        } else {
            currentStatusLabel.text = Strings.current_status_not_verified
        }
    }
    
    private func setUpDataEmailVerificationView() {
        emailVerificationView.addShadow()
        otpView.isHidden = true
        animationView.isHidden = true
        orgEmailStatusView.isHidden = true
        if userProfileVerificationViewModel.profileVerificationData == nil || !userProfileVerificationViewModel.profileVerificationData!.emailVerified {
            emailVerificationStatusLabel.text = Strings.org_id_verification_pending
            emailVerificationStatusLabel.textColor = UIColor.black
            sendOtpButton.isHidden = false
            editEmailButton.isHidden = true
            expandFullVerificationView()
            if userProfileVerificationViewModel.userProfile != nil &&  userProfileVerificationViewModel.userProfile!.email != nil && !userProfileVerificationViewModel.userProfile!.email!.isEmpty{
                if userProfileVerificationViewModel.profileVerificationData?.emailVerificationStatus == ProfileVerificationData.PENDING{
                    otpView.isHidden = false
                    emailTitleView.isHidden = true
                    emailTextFieldView.isHidden = true
                }else if userProfileVerificationViewModel.profileVerificationData?.emailVerificationStatus == ProfileVerificationData.INITIATED || userProfileVerificationViewModel.profileVerificationData?.emailVerificationStatus == ProfileVerificationData.REJECTED{
                    otpView.isHidden = true
                    emailTitleView.isHidden = true
                    emailTextFieldView.isHidden = true
                    showVerificationStatus()
                }
            }
        } else {
            if userProfileVerificationViewModel.userProfile != nil && userProfileVerificationViewModel.userProfile!.email != nil && !userProfileVerificationViewModel.userProfile!.email!.isEmpty {
                emailTextField.text = userProfileVerificationViewModel.userProfile!.email
                emailVerificationStatusLabel.text = Strings.org_verified
                emailVerificationStatusLabel.textColor = UIColor(netHex: 0x00B557)
                sendOtpButton.isHidden = true
                editEmailButton.isHidden = false
                hideVerificationView()
            } else {
                emailVerificationStatusLabel.text = Strings.org_id_verification_pending
                emailVerificationStatusLabel.textColor = UIColor.black
                sendOtpButton.isHidden = false
                editEmailButton.isHidden = true
                expandFullVerificationView()
            }
        }
    }
    
    private func expandFullVerificationView() {
        emailTextFieldView.isHidden = false
        emailTitleView.isHidden = false
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        if userProfile != nil && userProfile!.email != nil && !userProfile!.email!.isEmpty {
            sendOtpButton.isHidden = true
            editEmailButton.isHidden = false
        } else {
            sendOtpButton.isHidden = false
            editEmailButton.isHidden = true
        }
        emailViewHeightConstraint.constant = 160
        emailViewArrowButton.setImage(UIImage(named: "arrow_up_grey"), for: .normal)
    }
    
    private func hideVerificationView() {
        emailTitleView.isHidden = false
        emailTextFieldView.isHidden = true
        emailViewHeightConstraint.constant = 0
        otpView.isHidden = true
        emailViewArrowButton.setImage(UIImage(named: "arrow_down_grey"), for: .normal)
    }
    
    private func startLoadingAnimation(){
        animationView.isHidden = false
        animationView.animation = Animation.named("loading_otp")
        animationView.play()
        animationView.loopMode = .loop
    }
    
    private func stopLoadingAnimation(){
        animationView.isHidden = true
        animationView.stop()
    }
    
    func setUpGovtIDVerificationView() {
        govtIdVerificationView.addShadow()
        ViewCustomizationUtils.addBorderToView(view: adharVerificationButton, borderWidth: 1.0, color: Colors.editRouteBtnColor)
        ViewCustomizationUtils.addBorderToView(view: dlVerificationButton, borderWidth: 1.0, color: Colors.editRouteBtnColor)
        if userProfileVerificationViewModel.profileVerificationData != nil && userProfileVerificationViewModel.profileVerificationData!.persIDVerified && !userProfileVerificationViewModel.profileVerificationData!.isVerifiedOnlyFromEndorsement() {
            govtIdVerificationStatusLabel.text = Strings.personal_id_verified
            govtIdVerificationStatusLabel.textColor = UIColor(netHex: 0x00B557)
            if userProfileVerificationViewModel.profileVerificationData!.persVerifSource != nil && !userProfileVerificationViewModel.profileVerificationData!.persVerifSource!.contains(PersonalIdDetail.DL) {
                adharVerificationButton.isHidden = true
                dlVerificationButton.isHidden = false
                adharVerificationViewHeight.constant = 0
                dlVerificationViewHeight.constant = 40
                adharVerificationViewBottomConstraint.constant = 0
                dlVerificationViewViewBottomConstraint.constant = 20
                govtIdVerificationSubTitleLabel.isHidden = false
                govtIdVerificationSubTitleViewHeight.constant = 40
            } else if userProfileVerificationViewModel.profileVerificationData!.persVerifSource != nil && !userProfileVerificationViewModel.profileVerificationData!.persVerifSource!.contains(ProfileVerificationData.ADHAR) {
                adharVerificationButton.isHidden = true
                dlVerificationButton.isHidden = true
                adharVerificationViewHeight.constant = 0
                dlVerificationViewHeight.constant = 0
                adharVerificationViewBottomConstraint.constant = 0
                dlVerificationViewViewBottomConstraint.constant = 0
                govtIdVerificationSubTitleLabel.isHidden = false
                govtIdVerificationSubTitleViewHeight.constant = 0
            } else {
                adharVerificationButton.isHidden = true
                dlVerificationButton.isHidden = true
                adharVerificationViewHeight.constant = 0
                dlVerificationViewHeight.constant = 0
                adharVerificationViewBottomConstraint.constant = 0
                dlVerificationViewViewBottomConstraint.constant = 0
                govtIdVerificationSubTitleLabel.isHidden = true
                govtIdVerificationSubTitleViewHeight.constant = 0
            }
        } else if userProfileVerificationViewModel.profileVerificationData != nil && !userProfileVerificationViewModel.profileVerificationData!.emailVerified && !(ConfigurationCache.getObjectClientConfiguration().adhaarEnabledForRegion ?? false) {
            govtIdVerificationStatusLabel.text = Strings.verify_email_to_get_personal_id_verification
            govtIdVerificationStatusLabel.textColor = UIColor.black
            adharVerificationButton.isHidden = true
            dlVerificationButton.isHidden = true
            adharVerificationViewBottomConstraint.constant = 0
            dlVerificationViewViewBottomConstraint.constant = 0
            adharVerificationViewHeight.constant = 0
            dlVerificationViewHeight.constant = 0
            govtIdVerificationSubTitleLabel.isHidden = true
            govtIdVerificationSubTitleViewHeight.constant = 0
        } else {
            govtIdVerificationStatusLabel.text = Strings.govt_id_verification_pending
            govtIdVerificationStatusLabel.textColor = UIColor.black
            adharVerificationButton.isHidden = true
            dlVerificationButton.isHidden = false
            adharVerificationViewBottomConstraint.constant = 0
            dlVerificationViewViewBottomConstraint.constant = 20
            adharVerificationViewHeight.constant = 0
            dlVerificationViewHeight.constant = 40
            govtIdVerificationSubTitleLabel.isHidden = false
            govtIdVerificationSubTitleViewHeight.constant = 40
        }
        setUpCurrentVerificationStatusView()
    }
    
    func navigateToDlVerificationView(){
        let personalIdVerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PersonalIdVerificationViewController") as! PersonalIdVerificationViewController
        personalIdVerificationViewController.initialiseData(isFromProfile: true, verificationType: PersonalIdDetail.DL) { [weak self] in
            self?.setUpGovtIDVerificationView()
        }
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: personalIdVerificationViewController, animated: false)
    }
    
    func setUpImageVerificationView() {
        imageVerificationView.addShadow()
        ViewCustomizationUtils.addBorderToView(view: addActionButton, borderWidth: 1.0, color: Colors.editRouteBtnColor)
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        if userProfile != nil && userProfile!.imageURI != nil && !userProfile!.imageURI!.isEmpty {
            imageVerificationStatusLabel.text = Strings.image_verified
            imageVerificationStatusLabel.textColor = UIColor(netHex: 0x00B557)
            hideImageVerificationView()
        } else {
            imageVerificationStatusLabel.text = Strings.image_verification_pending
            imageVerificationStatusLabel.textColor = UIColor.black
            expandImageVerificationView()
        }
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: userProfile?.imageURI, gender: userProfile?.gender ?? "U", imageSize: ImageCache.DIMENTION_SMALL)
    }
    
    private func expandImageVerificationView() {
        imageVerificationTitleView.isHidden = false
        imageVerificationSubTitleView.isHidden = false
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        if userProfile != nil && userProfile!.imageURI != nil && !userProfile!.imageURI!.isEmpty {
            addActionButton.isHidden = true
            editOrRemoveActionView.isHidden = false
        } else {
            addActionButton.isHidden = false
            editOrRemoveActionView.isHidden = true
        }
        imageVerificationSubTitleViewHeight.constant = 180
        imageVerificationArrowButton.setImage(UIImage(named: "arrow_up_grey"), for: .normal)
    }
    
    private func hideImageVerificationView() {
        imageVerificationSubTitleView.isHidden = true
        imageVerificationSubTitleViewHeight.constant = 0
        imageVerificationArrowButton.setImage(UIImage(named: "arrow_down_grey"), for: .normal)
    }
    
    private func saveImage(isProfilePicUpdated: Bool, actualImage: UIImage?) {
        if let userProfile = userProfileVerificationViewModel.userProfile {
            if isProfilePicUpdated && actualImage != nil {
                let image = ImageUtils.RBResizeImage(image: actualImage!, targetSize: CGSize(width: 540, height: 540))
                userProfileVerificationViewModel.saveImage(image: image, userProfile: userProfile, viewController: self)
            }else{
                userProfile.imageURI = nil
                userProfileVerificationViewModel.saveUserProfile(userProfile: userProfile, isEmailUpdate: false, viewController: self)
            }
        }
    }
    
    func changePhoto() {
        AppDelegate.getAppDelegate().log.debug("changePhoto()")
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: false, viewController: self,delegate: self){ [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }
    
    @IBAction func verifyAdharClicked(_ sender: UIButton) {
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.ADHAAR_CLICKED, params: ["UserId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
        let personalIdVerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PersonalIdVerificationViewController") as! PersonalIdVerificationViewController
        personalIdVerificationViewController.initialiseData(isFromProfile: true, verificationType: PersonalIdDetail.ADHAR) { [weak self] in
            self?.userProfileVerificationViewModel.profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData()
            self?.setUpGovtIDVerificationView()
            self?.setUpCurrentVerificationStatusView()
        }
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: personalIdVerificationViewController, animated: false)
    }
    
    @IBAction func verifyDLClicked(_ sender: UIButton) {
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.DL_VERIFICATION_INITIATED, params: ["UserId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
        navigateToDlVerificationView()
    }
    
    @IBAction func imageVerificationArrowClicked(_ sender: UIButton) {
        if userProfileVerificationViewModel.isImageVerificationExpandable != nil && userProfileVerificationViewModel.isImageVerificationExpandable! {
            userProfileVerificationViewModel.isImageVerificationExpandable = false
            hideImageVerificationView()
        } else {
            userProfileVerificationViewModel.isImageVerificationExpandable = true
            expandImageVerificationView()
        }
    }
    
    @IBAction func addImageClicked(_ sender: UIButton) {
        changePhoto()
    }
    
    @IBAction func editImageClicked(_ sender: UIButton) {
        changePhoto()
    }
    
    @IBAction func removeImageClicked(_ sender: UIButton) {
        saveImage(isProfilePicUpdated: false, actualImage: nil)
    }
    
    @IBAction func emailVerificationArrowClicked(_ sender: UIButton) {
        if userProfileVerificationViewModel.isOrgVerificationExpandable != nil && userProfileVerificationViewModel.isOrgVerificationExpandable! {
            userProfileVerificationViewModel.isOrgVerificationExpandable = false
            hideVerificationView()
        } else {
            userProfileVerificationViewModel.isOrgVerificationExpandable = true
            expandFullVerificationView()
        }
    }
    
    @IBAction func sendOtpClicked(_ sender: UIButton) {
        if emailTextField.text == nil || emailTextField.text!.isEmpty {
            MessageDisplay.displayAlert(messageString: Strings.enter_valid_email_id, viewController: self, handler: nil)
            return
        }
        let userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
        let input = emailTextField.text
        if userProfile != nil && ((userProfile!.email == nil && input?.isEmpty == false) || (userProfile!.email != nil && input!.isEmpty == true) || (userProfile!.email != nil && userProfile!.email != input)) {
          userProfileVerificationViewModel.isEmailUpdated = true
        }
        otpView.isHidden = true
        emailTitleView.isHidden = true
        emailTextFieldView.isHidden = true
        startLoadingAnimation()
        userProfileVerificationViewModel.userProfile?.email = emailTextField.text
        userProfileVerificationViewModel.saveUserProfile(userProfile: userProfileVerificationViewModel.userProfile, isEmailUpdate: true, viewController: self)
    }
    
    @IBAction func editEmailClicked(_ sender: UIButton) {
        otpView.isHidden = true
        emailTitleView.isHidden = false
        emailTextFieldView.isHidden = false
        editEmailButton.isHidden = true
        sendOtpButton.isHidden = false
    }
    
    @IBAction func resendOtpClicked(_ sender: UIButton) {
        userProfileVerificationViewModel.resendOtp()
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    private func saveOrgMail(companyName : String?){
        userProfileVerificationViewModel.userProfile?.companyName = companyName
        userProfileVerificationViewModel.userProfile?.email = emailTextField.text
        userProfileVerificationViewModel.saveUserProfile(userProfile: userProfileVerificationViewModel.userProfile, isEmailUpdate: true, viewController: self)
    }
    private func checkCompanyDomainStatus(){
        if userProfileVerificationViewModel.profileVerificationData?.emailVerificationStatus == ProfileVerificationData.REJECTED || userProfileVerificationViewModel.profileVerificationData?.emailVerificationStatus == ProfileVerificationData.INITIATED{
            if let range = userProfileVerificationViewModel.userProfile?.email?.range(of: "@") {
                let domain = "@" + (userProfileVerificationViewModel.userProfile?.email?[range.upperBound...] ?? "")
                let verificationStatusViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerificationStatusViewController") as! VerificationStatusViewController
                verificationStatusViewController.initializeVerificationView(companyName: userProfileVerificationViewModel.userProfile?.companyName ?? "", status: userProfileVerificationViewModel.profileVerificationData?.emailVerificationStatus ?? "", emailDomain: String(domain ))
                ViewControllerUtils.addSubView(viewControllerToDisplay: verificationStatusViewController)
            }
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      var threshold : Int?
        if textField == emailTextField{
            threshold = 100
        }else{
           return true
        }
      let currentCharacterCount = textField.text?.count ?? 0
        if textField == emailTextField{
           CompanyDomainSuggestionUtils().getCompanyDomainsBasedOnEnteredCharacter(emailDomain: textField.text ?? "",textField: emailTextField,anchorView: seperatorView)
            if emailTextField.text?.count ?? 0 > 0{
                showSendSendOTPButton(isRequiredToShow: true)
            }
        }
        
      if (range.length + range.location > currentCharacterCount){
        return false
      }
      let newLength = currentCharacterCount + string.count - range.length
      return newLength <= threshold!
    }

    
    private func showSendSendOTPButton(isRequiredToShow: Bool){
        if isRequiredToShow{
            otpView.isHidden = true
            emailTitleView.isHidden = false
            emailTextFieldView.isHidden = false
            editEmailButton.isHidden = true
            sendOtpButton.isHidden = false
        }
    }
    
    private func showVerificationStatus(){
        userProfileVerificationViewModel.getCompanyDomainStatus()
        orgEmailStatusView.isHidden = false
        orgEmailStatusView.addShadow()
        companyNameLabel.text = (userProfileVerificationViewModel.userProfile?.companyName ?? "") + " - "
        if userProfileVerificationViewModel.profileVerificationData?.emailVerificationStatus == ProfileVerificationData.REJECTED{
            descriptionLabel.text = String(format: Strings.verification_hold_status, arguments: [(userProfileVerificationViewModel.userProfile?.companyName ?? "")])
            verificationStatusLabel.textColor = UIColor(netHex: 0xce3939)
            counterSlider.minimumTrackTintColor = UIColor(netHex: 0xd65b5b)
            counterSlider.setThumbImage(UIImage(named: "red_border_icon"), for: .normal)
            verificationStatusLabel.text = Strings.verification_on_rejected
        }else{
            descriptionLabel.text = String(format: Strings.verification_process_status, arguments: [(userProfileVerificationViewModel.userProfile?.companyName ?? ""),(userProfileVerificationViewModel.userProfile?.companyName ?? "")])
            verificationStatusLabel.textColor = UIColor(netHex: 0xd27902)
            counterSlider.minimumTrackTintColor = UIColor(netHex: 0x00b501)
            counterSlider.setThumbImage(UIImage(named: "green_border_icon"), for: .normal)
            verificationStatusLabel.text = Strings.verification_in_process
        }
        setSliderDependingOnCount()
    }
    private func setSliderDependingOnCount(){
        let count = userProfileVerificationViewModel.companyVerificationStatus?.verifiedCount ?? 0
        counterSlider.trackRect(forBounds: CGRect(x: 0, y: 0, width: 20, height: 20))
        if count > 0{
            if count == 1{
                counterSlider.setValue(Float(count + 1), animated: false)
                counterLabel.text = String(format: "Your profile created", arguments: [String(count)])
            }else{
                counterSlider.setValue(Float(count), animated: false)
                counterLabel.text = String(format: Strings.riders_joined, arguments: [String(count)])
            }
            counterLabel.isHidden = false
        }else{
            counterSlider.setValue(Float(count), animated: false)
            counterLabel.isHidden = true
        }
    }
    @objc func companyDomainStatusReceived(_ notification: Notification) {
        setSliderDependingOnCount()
    }
    
    @IBAction func referNowTapped(_ sender: Any) {
        guard let referralCode = UserDataCache.getInstance()?.getReferralCode() else { return }
        InstallReferrer.prepareURLForDeepLink(referralCode: referralCode) { (urlString)  in
            if urlString != nil{
                self.shareReferralContext(urlString: urlString!, referralCode: referralCode)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.referral_error, viewController: self, handler: nil)
            }
        }
    }
    
    private func shareReferralContext(urlString : String,referralCode: String){
        let message = String(format: Strings.share_and_earn_msg, arguments: [referralCode,urlString,UserDataCache.getInstance()!.userProfile!.userName!])
        let activityItem: [AnyObject] = [message as AnyObject]
        let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
        avc.excludedActivityTypes = [UIActivity.ActivityType.airDrop,UIActivity.ActivityType.assignToContact,UIActivity.ActivityType.copyToPasteboard,UIActivity.ActivityType.addToReadingList,UIActivity.ActivityType.saveToCameraRoll,UIActivity.ActivityType.print]
        if #available(iOS 11.0, *) {
            avc.excludedActivityTypes = [UIActivity.ActivityType.markupAsPDF,UIActivity.ActivityType.openInIBooks]
        }
        avc.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
            if completed {
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sent)
            }
            else{
                UIApplication.shared.keyWindow?.makeToast( Strings.message_sending_cancelled)
            }
        }
        self.present(avc, animated: true, completion: nil)
    }
}

extension UserProfileVerificationViewController: EmailValidationDelegate {
    
    func emailVerificationSuccess() {
        stopLoadingAnimation()
        setUpDataEmailVerificationView()
        setUpGovtIDVerificationView()
        setUpCurrentVerificationStatusView()
        checkCompanyDomainStatus()
    }
    
    func emailVerificationFailed() {
        stopLoadingAnimation()
        otpView.isHidden = false
        emailTitleView.isHidden = true
        emailTextFieldView.isHidden = true
        otpTextField1.text = ""
        otpTextField2.text = ""
        otpTextField3.text = ""
        otpTextField4.text = ""
    }
}

extension UserProfileVerificationViewController: ProfileUpdateDelegate {
    func profileUpdateSuccess(isEmailUpdated: Bool) {
        if !isEmailUpdated {
            setUpImageVerificationView()
            setUpCurrentVerificationStatusView()
        }
    }
}
extension UserProfileVerificationViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        AppDelegate.getAppDelegate().log.debug("imagePickerControllerDidCancel()")
        receivedImage(image: nil, isUpdated: false)
        self.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        AppDelegate.getAppDelegate().log.debug("imagePickerController()")
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
        let normalizedImage = UploadImageUtils.fixOrientation(img: image)
        let newImage = UIImage(data: normalizedImage.uncompressedPNGData as Data)
        receivedImage(image: newImage, isUpdated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    private func receivedImage(image: UIImage?,isUpdated: Bool){
        if image != nil{
            self.saveImage(isProfilePicUpdated: true, actualImage: image)
        }else{
            self.saveImage(isProfilePicUpdated: false, actualImage: nil)
        }
    }
}
