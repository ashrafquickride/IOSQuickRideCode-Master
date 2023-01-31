//
//  ProfileVerificationViewController.swift
//  Quickride
//
//  Created by Admin on 15/11/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI
import TransitionButton
import Lottie
import DropDown

class ProfileVerificationViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var profileDetailsView: UIView!
    @IBOutlet weak var addPictureView: UIView!
    @IBOutlet weak var confirmBtn: UIButton!
    @IBOutlet weak var organizationDetailInputView: UIView!
    @IBOutlet weak var addOrganizationMailView: UIView!
    @IBOutlet weak var organizationTextField: UITextField!
    @IBOutlet weak var verifyEmailBtn: TransitionButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var otpVerificationView: UIView!
    @IBOutlet weak var verificationTextField1: UITextField!
    @IBOutlet weak var verificationTextField2: UITextField!
    @IBOutlet weak var verificationTextfield3: UITextField!
    @IBOutlet weak var verificationTextField4: UITextField!
    @IBOutlet weak var emailVerificationView: UIView!
    @IBOutlet weak var congratsAnimationView: AnimationView!
    @IBOutlet weak var subtitleLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var otpSentToTextLabel: UILabel!
    @IBOutlet weak var otpView: UIStackView!
    @IBOutlet weak var otpVerificationSpinner: AnimationView!
    @IBOutlet weak var newCompanyAlertView: UIView!
    @IBOutlet weak var newCompnayNameLabel: UILabel!
    @IBOutlet weak var newCompanyDescLabel: UILabel!
    @IBOutlet weak var orgEmailSeperatorView: UIView!
    
    //MARK: Properties
    private let profileVerificationViewModel = ProfileVerificationViewModel()
    private var handler : DialogDismissCompletionHandler?
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        setUpUI()
        profileVerificationViewModel.delegate = self
    }
    
    
    //MARK: Methods
    
    func initializeViews(rideType : String?,handler : DialogDismissCompletionHandler?){
        self.handler = handler
        profileVerificationViewModel.initializeData(rideType: rideType)
    }
    
    private func setUpUI(){
        checkVerificationStatusAndHandleUI()
        animateUI()
        organizationTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        handleViewCustomization()
        verificationTextField1.addTarget(self, action: #selector(textFieldDidChangeForVericationCode(textField:)), for: UIControl.Event.editingChanged)
        verificationTextField2.addTarget(self, action: #selector(textFieldDidChangeForVericationCode(textField:)), for: UIControl.Event.editingChanged)
        verificationTextfield3.addTarget(self, action: #selector(textFieldDidChangeForVericationCode(textField:)), for: UIControl.Event.editingChanged)
        verificationTextField4.addTarget(self, action: #selector(textFieldDidChangeForVericationCode(textField:)), for: UIControl.Event.editingChanged)
        ViewCustomizationUtils.addCornerRadiusToView(view: verificationTextField1, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: verificationTextField2, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: verificationTextfield3, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: verificationTextField4, cornerRadius: 5.0)
    }
    private func checkVerificationStatusAndHandleUI(){
        if let userProfile = profileVerificationViewModel.userProfile,let profileVerificationData = userProfile.profileVerificationData{
            if !profileVerificationData.imageVerified && !profileVerificationData.emailVerified{
                confirmBtn.isHidden = true
                profileDetailsView.isHidden = false
                addPictureView.isHidden = false
                checkIfNewUserAndSetTitle(userProfile: userProfile)
                checkWhetherEmailIdPresentAndHandleUI()
                subtitleLabel.text = Strings.verify_your_profile_subtitle
                nameLabel.text = userProfile.userName
            }else if !profileVerificationData.imageVerified{
                addPictureView.isHidden = false
                confirmBtn.isHidden = false
                profileDetailsView.isHidden = false
                organizationDetailInputView.isHidden = true
                titleLabel.text = Strings.verify_profile_picture
                subtitleLabel.text = Strings.verify_profile_pic_subtitle
                nameLabel.text = userProfile.userName
            }else if !profileVerificationData.emailVerified{
                addPictureView.isHidden = true
                confirmBtn.isHidden = true
                profileDetailsView.isHidden = true
                checkWhetherEmailIdPresentAndHandleUI()
                titleLabel.text = Strings.verify_org_id
                subtitleLabel.text = Strings.verify_your_profile_subtitle
            }
        }
        userImageView.image = ImageCache.getInstance().getDefaultUserImage(gender: profileVerificationViewModel.userProfile?.gender ?? "U")
    }
    
    private func checkWhetherEmailIdPresentAndHandleUI(){
        if let userProfile = UserDataCache.getInstance()?.userProfile,userProfile.email != nil{
            organizationDetailInputView.isHidden = true
            otpVerificationView.isHidden = false
            otpSentToTextLabel.text = String(format: Strings.otp_sent_to, arguments: [UserDataCache.getInstance()?.userProfile?.email ?? ""])
        }else{
            organizationDetailInputView.isHidden = false
            otpVerificationView.isHidden = true
            if let orgEmail = SharedPreferenceHelper.getOrganizationEmailId(){
                organizationTextField.text = orgEmail
            }
        }
    }
    
    private func checkIfNewUserAndSetTitle(userProfile : UserProfile){
        let totalRides = userProfile.numberOfRidesAsRider + userProfile.numberOfRidesAsPassenger
        if totalRides > 0{
            titleLabel.text = Strings.verify_your_profile
        }else{
            if let rideType = profileVerificationViewModel.rideType{
                if rideType == Ride.RIDER_RIDE{
                    titleLabel.text = Strings.verify_your_profile_new_user_rider
                }else{
                    titleLabel.text = Strings.verify_your_profile_new_user
                }
            }else{
                if userProfile.roleAtSignup == UserProfile.PREFERRED_ROLE_RIDER{
                   titleLabel.text = Strings.verify_your_profile_new_user_rider
                }else{
                   titleLabel.text = Strings.verify_your_profile_new_user
                }
            }
        }
    }
    
    private func handleViewCustomization(){
        ViewCustomizationUtils.addCornerRadiusToView(view: alertView, cornerRadius: 20.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: confirmBtn, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: verifyEmailBtn, cornerRadius: 3.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: addOrganizationMailView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: addPictureView, cornerRadius: 8.0)
        ViewCustomizationUtils.addBorderToView(view: addPictureView, borderWidth: 1.0, color: UIColor(netHex: 0x2196f3))
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:))))
        addPictureView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPictureViewTapped(_:))))
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPictureViewTapped(_:))))
    }
    
    @objc private func backgroundTapped(_ gesture : UITapGestureRecognizer){
        SharedPreferenceHelper.incrementCountForVerificationViewDisplay()
        UserDataCache.getInstance()?.updateEntityDisplayStatus(key: UserDataCache.VERIFICATION_VIEW, status: true)
        closeView()
    }
    
    @objc private func addPictureViewTapped(_ gesture : UITapGestureRecognizer){
        handleProfileImageChange()
    }
    @objc private func textFieldDidChange(textField : UITextField){
        handleVisibilityOfVerifyEmailBtn(textField: textField)
    }
    
    private func handleVisibilityOfVerifyEmailBtn(textField : UITextField){
        if textField.text == nil || textField.text!.isEmpty{
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .transitionFlipFromRight,animations: { [weak self] in
                },completion: { [weak self] _ in
                    self?.verifyEmailBtn.isHidden = true
            })
        }else{
            UIView.animate(withDuration: 0.5, delay: 0.2, options: .transitionFlipFromRight,animations: { [weak self] in
                },completion: { [weak self] _ in
                    self?.verifyEmailBtn.isHidden = false
            })
        }
    }
    
    private func handleProfileImageChange(){
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: false, viewController: self, delegate: self){ [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }
    
    private func animateUI(){
        UIView.animate(withDuration: 0.5, delay: 0, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {
                            return
                        }
                        self.alertView.frame = CGRect(x: 0, y: -300, width: self.alertView.frame.width, height: self.alertView.frame.height)
                        self.alertView.layoutIfNeeded()
            }, completion: nil)
    }
    
    private func closeView(){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: { [weak self] in
            guard let self = `self` else{
                return
            }
            self.alertView.center.y += self.alertView.bounds.height
            self.alertView.layoutIfNeeded()
        }) { [weak self] (value) in
            guard let self = `self`else{
                return
            }
            self.handler?()
            self.view.removeFromSuperview()
            self.removeFromParent()
        }
    }
    
    private func navigateToGovtIdVerificationViewController(){
        let govtIdVerificationVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "GovtIDVerificationController") as! GovtIDVerificationController
        ViewControllerUtils.addSubView(viewControllerToDisplay: govtIdVerificationVC)
        govtIdVerificationVC.view.layoutIfNeeded()
    }
    
    private func resendOTP(){
        
        guard let userId = QRSessionManager.getInstance()?.getUserId() else{
            return
        }
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.resendVerificationEmail(userId: userId, viewController: self, completionHandler: { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast( Strings.verification_resend_toast)
            }
            else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        })
    }
    
    @objc func textFieldDidChangeForVericationCode(textField : UITextField){
        let text = textField.text
        if text?.utf16.count == 1{
            
            switch textField {
            case verificationTextField1:
                handleUIUpdateBasedOnTextFieldText(textField: verificationTextField1)
                verificationTextField2.becomeFirstResponder()
            case verificationTextField2:
                handleUIUpdateBasedOnTextFieldText(textField: verificationTextField2)
                verificationTextfield3.becomeFirstResponder()
            case verificationTextfield3:
                handleUIUpdateBasedOnTextFieldText(textField: verificationTextfield3)
                verificationTextField4.becomeFirstResponder()
            case verificationTextField4:
                handleUIUpdateBasedOnTextFieldText(textField: verificationTextField4)
                verificationTextField4.resignFirstResponder()
                let verificationText = verificationTextField1.text! + verificationTextField2.text! + verificationTextfield3.text! + verificationTextField4.text!
                if let email = profileVerificationViewModel.userProfile?.email{
                    profileVerificationViewModel.verifyProfile(verificationText: verificationText, viewController: self, email: email)
                    startSpinning()
                }
            default:
                break
            }
            
        }else{
            switch textField {
            case verificationTextField4:
                resetTextFieldBackGroundColor(textField: verificationTextField4)
                verificationTextField4.resignFirstResponder()
                verificationTextfield3.becomeFirstResponder()
            case verificationTextfield3:
                resetTextFieldBackGroundColor(textField: verificationTextfield3)
                verificationTextfield3.resignFirstResponder()
                verificationTextField2.becomeFirstResponder()
            case verificationTextField2:
                resetTextFieldBackGroundColor(textField: verificationTextField2)
                verificationTextField2.resignFirstResponder()
                verificationTextField1.becomeFirstResponder()
            case verificationTextField1:
                resetTextFieldBackGroundColor(textField: verificationTextField1)
                verificationTextField1.becomeFirstResponder()
            default:
                break
            }
        }
    }
    
    private func resetTextFieldBackGroundColor(textField : UITextField){
           textField.backgroundColor = UIColor(netHex: 0xe7e7e7)
           ViewCustomizationUtils.addBorderToView(view: textField, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
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
    
    
    //MARK: Actions
    @IBAction func confirmBtnClicked(_ sender: Any) {
        closeView()
    }
    
    @IBAction func verifyEmailBtnClicked(_ sender: TransitionButton) {
        if !profileVerificationViewModel.checkWhetherOfficialEmailIdValid(email: organizationTextField.text!)
        {
            return
        }
        
        if !AppUtil.isValidEmailId(emailId: organizationTextField.text!){
            return
        }
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.ORG_EMAIL_ENTERED, params: ["UserId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
        verifyEmailBtn.startAnimation()
        saveOrgMail(companyName: organizationTextField.text)
    }
    
    @IBAction func verifyGovtIDBtnClicked(_ sender: Any) {
        closeView()
        navigateToGovtIdVerificationViewController()
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.ORG_EMAIL_NOT_AVAILABLE, params: ["UserId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.VERIFY_GOVT_ID, params: ["UserId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
    }
    
    
    @IBAction func resendOtpBtnClicked(_ sender: Any) {
        resendOTP()
    }
    
    
    @IBAction func needSupportBtnClicked(_ sender: Any) {
        sendEmailToSupport()
    }
}

//MARK: ProfileVerificationViewModelDelegate
extension ProfileVerificationViewController : ProfileVerificationViewModelDelegate{
    func startEmailVerifiedAnimation() {
        emailVerificationView.isHidden = false
        titleLabel.isHidden = true
        otpVerificationView.isHidden = true
        congratsAnimationView.animation = Animation.named("signup_congrats")
        congratsAnimationView.play()
        congratsAnimationView.loopMode = .loop
        stopEmailVerifiedAnimation()
        checkCompanyDomainStatus()
    }
    
    func stopEmailVerifiedAnimation(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            self?.congratsAnimationView.stop()
            self?.closeView()
        }
    }
    
    func closeVerificationView() {
        closeView()
    }
    
    func stopButtonAnimation() {
        verifyEmailBtn.stopAnimation()
    }
    
    func handleOTPViewVisibility() {
        self.view.endEditing(false)
        verifyEmailBtn.stopAnimation()
        addPictureView.isHidden = true
        confirmBtn.isHidden = true
        profileDetailsView.isHidden = true
        organizationDetailInputView.isHidden = true
        otpVerificationView.isHidden = false
        otpSentToTextLabel.text = String(format: Strings.otp_sent_to, arguments: [organizationTextField.text!])
        titleLabel.text = Strings.verify_email_otp
        subtitleLabel.isHidden = true
        subtitleLabelHeightConstraint.constant = 0
    }
    
    func displayEmailNotValidConfirmationDialog(userMessage : String)
    {
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: userMessage, message2: nil, positiveActnTitle: Strings.change_caps, negativeActionTitle : Strings.skip_caps,linkButtonText: nil, viewController: self, handler: { [weak self](result) in
            if Strings.skip_caps == result{
                self?.closeView()
            }
            else{
                self?.organizationTextField.becomeFirstResponder()
            }
        })
    }
    
    func startSpinning() {
        
        otpView.isHidden = true
        otpVerificationSpinner.isHidden = false
        otpVerificationSpinner.animation = Animation.named("loading_otp")
        otpVerificationSpinner.play()
        otpVerificationSpinner.loopMode = .loop
        
    }
    
    func stopSpinning() {
        
        otpView.isHidden = false
        otpVerificationSpinner.isHidden = true
        otpVerificationSpinner.stop()
        
    }
    private func checkCompanyDomainStatus(){
        let profileVerificationData = profileVerificationViewModel.userProfile?.profileVerificationData
        if profileVerificationData?.emailVerificationStatus == ProfileVerificationData.REJECTED || profileVerificationData?.emailVerificationStatus == ProfileVerificationData.INITIATED{
            let verificationStatusViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerificationStatusViewController") as! VerificationStatusViewController
            ViewControllerUtils.addSubView(viewControllerToDisplay: verificationStatusViewController)
        }
    }
    
    private func saveOrgMail(companyName : String?){
        profileVerificationViewModel.userProfile?.companyName = companyName
        profileVerificationViewModel.userProfile?.email = organizationTextField.text
        profileVerificationViewModel.saveUserProfile(email: organizationTextField.text, viewController: self)
    }
}

//MARK: UITextFieldDelegate
extension ProfileVerificationViewController : UITextFieldDelegate{
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        handleVisibilityOfVerifyEmailBtn(textField: textField)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if profileVerificationViewModel.errorOccured{
            profileVerificationViewModel.errorOccured = false
            verificationTextField1.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: verificationTextField1, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
            verificationTextField2.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: verificationTextField2, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
            verificationTextfield3.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: verificationTextfield3, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
            verificationTextField4.backgroundColor = UIColor(netHex: 0xe7e7e7)
            ViewCustomizationUtils.addBorderToView(view: verificationTextField4, borderWidth: 1.0, color: UIColor(netHex: 0xe7e7e7))
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      var threshold : Int?
        if textField == organizationTextField{
            threshold = 100
        }else{
            return true
        }
      let currentCharacterCount = textField.text?.count ?? 0
        if textField == organizationTextField{
            CompanyDomainSuggestionUtils().getCompanyDomainsBasedOnEnteredCharacter(emailDomain: textField.text ?? "",textField: organizationTextField,anchorView: orgEmailSeperatorView)
        } 
      if (range.length + range.location > currentCharacterCount){
        return false
      }
      let newLength = currentCharacterCount + string.count - range.length
      return newLength <= threshold!
    }
}

//MARK: MFMailComposerDelegate

extension ProfileVerificationViewController : MFMailComposeViewControllerDelegate{
    func sendEmailToSupport(){
        AppDelegate.getAppDelegate().log.debug("sendEmailToSupport()")
        if MFMailComposeViewController.canSendMail() {
            let userProfile = UserDataCache.getInstance()?.userProfile
            let mailComposeViewController = MFMailComposeViewController()
            var subject = ""
            if UserDataCache.getInstance()!.isReVerifyShouldDisplay != nil && UserDataCache.getInstance()!.isReVerifyShouldDisplay!{
                subject = Strings.reverification_mail_not_received
            }
            else{
                subject = Strings.verification_mail_not_received
            }
            if userProfile?.userName != nil{
                subject = subject+(userProfile?.userName)!
            }
            if userProfile?.userId != nil{
                subject = subject + " UserId: \(StringUtils.getStringFromDouble(decimalNumber : userProfile?.userId))"
            }
            subject = subject + " ContactNo:" + QRSessionManager.getInstance()!.getCurrentSession().contactNo
            if userProfile?.email != nil{
                subject = subject + " Email:"+(userProfile?.email)!
            }
            if userProfile?.companyName != nil
            {
                subject = subject + " CompanyName:"+(userProfile?.companyName)!
            }
            mailComposeViewController.setSubject(subject)
            mailComposeViewController.mailComposeDelegate = self
            var recepients = [String]()
            var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
            if clientConfiguration == nil{
                clientConfiguration = ClientConfigurtion()
            }
            recepients.append(clientConfiguration!.verificationSupportMail)
            mailComposeViewController.setToRecipients(recepients)
            if let fileData = NSData(contentsOf: AppDelegate.getAppDelegate().logPath! as URL) {
                mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName)
            }
            let logPathBackup = AppDelegate.getAppDelegate().logPathBackup
            if logPathBackup != nil{
                if let fileData = NSData(contentsOf: logPathBackup! as URL){
                    mailComposeViewController.addAttachmentData(fileData as Data, mimeType: "txt", fileName: AppDelegate.logFileName_Backup)
                }
            }
            self.present(mailComposeViewController, animated: false, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_send_mail)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }
}



//MARK: GovtIDVerificationClass
class GovtIDVerificationController : UIViewController{
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var drivingLicenseVerificationBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI(){
        animateUI()
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: alertView, cornerRadius: 20, corner1: .topLeft, corner2: .topRight)
        ViewCustomizationUtils.addBorderToView(view: drivingLicenseVerificationBtn, borderWidth: 1.0, color: UIColor(netHex: 0x2196f3))
        ViewCustomizationUtils.addCornerRadiusToView(view: drivingLicenseVerificationBtn, cornerRadius: 8.0)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backgroundTapped(_:))))
    }
    
    private func animateUI(){
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [.transitionCurlDown],
                       animations: { [weak self] in
                        guard let self = `self` else {
                            return
                        }
                        self.alertView.frame = CGRect(x: 0, y: -300, width: self.alertView.frame.width, height: self.alertView.frame.height)
                        self.alertView.layoutIfNeeded()
            }, completion: nil)
    }
    
    private func closeView(isFromDl : Bool){
        UIView.animate(withDuration: 0.5, delay: 0, options: .transitionCurlDown, animations: { [weak self] in
            guard let self = `self` else{
                return
            }
            self.alertView.center.y += self.alertView.bounds.height
            self.alertView.layoutIfNeeded()
        }) { [weak self] (value) in
            guard let self = `self`else{
                return
            }
            self.view.removeFromSuperview()
            self.removeFromParent()
            if isFromDl{
                self.navigateToDLVerificationScreen()
            }
        }
    }
    
    @objc private func backgroundTapped(_ gesture : UITapGestureRecognizer){
        closeView(isFromDl: false)
    }
    
    private func navigateToDLVerificationScreen(){
        let personalIdVerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PersonalIdVerificationViewController") as! PersonalIdVerificationViewController
        personalIdVerificationViewController.initialiseData(isFromProfile: true, verificationType: PersonalIdDetail.DL) {
        }
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: personalIdVerificationViewController, animated: false)
    }
    
    @IBAction func dlButtonClicked(_ sender: Any) {
        closeView(isFromDl: true)
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.DL_VERIFICATION_INITIATED, params: ["UserId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
    }
    
    
}
extension ProfileVerificationViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
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
            self.addPictureView.isHidden = true
            self.userImageView.image = image!.circle!
            self.profileVerificationViewModel.saveUserImage(actualImage: image!, viewController: self)
        }else{
            self.userImageView.image = UIImage(named: "default_user_image")
        }
    }
}
