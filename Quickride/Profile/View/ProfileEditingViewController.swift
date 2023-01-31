//
  //  ProfileEditingViewController.swift
  //  Quickride
  //
  //  Created by QuickRideMac on 13/04/16.
  //  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
  //

  import UIKit
  import Alamofire
  import ObjectMapper
  import AVFoundation
  import DropDown

protocol  VehicleDetailsUpdateListener{
    func VehicleDetailsUpdated()
  }
class ProfileEditingViewController: UIViewController, UITextFieldDelegate ,UINavigationControllerDelegate, SelectDateDelegate{

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var userImage: UIImageView!

    @IBOutlet weak var editUserImage: UILabel!

    @IBOutlet var userNameTextField: UITextField!

    @IBOutlet weak var designationTextField: UITextField!

    @IBOutlet weak var emailIdTextField: UITextField!

    @IBOutlet weak var emailIdForCommunication: UITextField!

    @IBOutlet weak var saveButton: UIButton!

    @IBOutlet weak var infoIcon: UIImageView!

    @IBOutlet weak var upadatePersonalInfoBottomConstarint: NSLayoutConstraint!

    @IBOutlet weak var findRideView: UIView!

    @IBOutlet weak var offerRideView: UIView!

    @IBOutlet weak var bothView: UIView!

    @IBOutlet weak var findRideLbl: UILabel!

    @IBOutlet weak var offerRideLbl: UILabel!

    @IBOutlet weak var bothRideLbl: UILabel!

    @IBOutlet weak var birthDateLabel: UILabel!

    @IBOutlet weak var birthDateView: UIView!

    @IBOutlet weak var birthDateViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addBirthDateView: UIView!

    @IBOutlet weak var addBirthDateViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var orgSeparetorView: UIView!

    var isKeyboardVisible : Bool = false
    var isProfilePicUpdated : Bool = false
    var isProfileUpdated : Bool = false
    var isEmailUpdated : Bool = false
    var isRemoveOptionApplicableForPic : Bool = false
    var emergencyContact : String?
    var isValidEmail = false
    var activeTextField : UITextField!
    var setProfileImage = false
    var user : User?
    var userProfile : UserProfile?
    var userId : String?
    var currentUserVehicles : [Vehicle]? = [Vehicle]()
    var userPreferredRole : String?
    var presentedFromActivationView : Bool = false
    var setDesignation = false

    private var defaultClientConfiguration : ClientConfigurtion?

    var facebookID = ""

    var storePreviousTextField = UITextField()
    let buttons = ["OK"]
    var actualImage : UIImage?


    func initializeView(setProfileImage: Bool, setDesignation: Bool){
        self.setProfileImage = setProfileImage
        self.setDesignation = setDesignation
    }
    override func viewDidLoad() {
      AppDelegate.getAppDelegate().log.debug("viewDidLoad()")
        super.viewDidLoad()
      definesPresentationContext = true
      initializeUserProfileFromCache()
      userNameTextField.delegate = self
      designationTextField.delegate = self
      emailIdTextField.delegate = self
      emailIdForCommunication.delegate = self
      self.scrollView.isScrollEnabled = true
      self.scrollView.contentSize = CGSize(width: 320,height: 800)
      self.automaticallyAdjustsScrollViewInsets = false
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileEditingViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfileEditingViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        editUserImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileEditingViewController.editProfileImage(_:))))
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileEditingViewController.editProfileImage(_:))))
        findRideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileEditingViewController.findRideViewTapped(_:))))
        offerRideView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileEditingViewController.offerRideViewTapped(_:))))
        bothView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileEditingViewController.bothViewTapped(_:))))

    }

    deinit{
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func saveButtonPressed(_ sender: UIButton) {
        self.view.endEditing(false)
        saveProfileChanges()
    }

    @IBAction func backButtonPressed(_ sender: UIButton) {

      AppDelegate.getAppDelegate().log.debug("backButtonPressed()")
        self.view.endEditing(false)
      emailIdTextField.text = emailIdTextField.text!.replacingOccurrences(of: " ", with: "")
      emailIdForCommunication.text = emailIdForCommunication.text!.replacingOccurrences(of: " ", with: "")
      let validationErrorMsg = validateFieldsAndReturnErrorMsgIfAny()
      if validationErrorMsg != nil {
        MessageDisplay.displayAlert( messageString: validationErrorMsg!, viewController: self,handler: nil)
        return
      }
      checkWhetherProfileDetailsChanged()

      if(isProfileUpdated || isProfilePicUpdated || isEmailUpdated)
      {
        if userProfile != nil && userProfile!.imageURI == nil{
            saveProfileChanges()
        }
        else{
            displayConfirmationDialogueForSavingData()
        }
      }else{
            removeViewViewController()
      }

    }
    func displayConfirmationDialogueForSavingData(){
      AppDelegate.getAppDelegate().log.debug("displayConfirmationDialogueForSavingData()")
      MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.save_changes, message2: nil, positiveActnTitle: Strings.save_caps, negativeActionTitle : Strings.discard_caps,linkButtonText: nil, viewController: self, handler: { (result) in
        if Strings.save_caps == result{
          self.saveProfileChanges()
        }
        else{

          self.removeViewViewController()
        }
      })
    }
    func removeViewViewController(){

     

        if presentedFromActivationView{
          let helpVideosViewController = UIStoryboard(name: "Help", bundle: nil).instantiateViewController(withIdentifier: "HelpVideosViewController") as! HelpVideosViewController
          helpVideosViewController.fromActivation = true
          self.navigationController?.pushViewController(helpVideosViewController, animated: false)
        }else{
          self.navigationController?.popViewController(animated: false)
        }

    }
    func initializeDataBeforePresentingView (presentedFromActivationView : Bool) {
      AppDelegate.getAppDelegate().log.debug("initializeDataBeforePresentingView()")
      self.presentedFromActivationView = presentedFromActivationView
    }

    override func viewWillAppear(_ animated: Bool) {
      AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
      super.viewWillAppear(animated)
      self.emailIdForCommunication.delegate = self
      if self.userProfile?.imageURI != nil && !(self.userProfile?.imageURI?.isEmpty)!
      {
        self.isRemoveOptionApplicableForPic = true
      }
}

    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToView(view: self.saveButton, cornerRadius: 8.0)
        CustomExtensionUtility.changeBtnColor(sender: self.saveButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        ViewCustomizationUtils.addCornerRadiusToView(view: findRideView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: offerRideView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: bothView, cornerRadius: 5.0)
        ViewCustomizationUtils.addBorderToView(view: findRideView, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        ViewCustomizationUtils.addBorderToView(view: offerRideView, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        ViewCustomizationUtils.addBorderToView(view: bothView, borderWidth: 1.0, color: UIColor(netHex:0xbbbbbb))
        if setProfileImage{
            setProfileImage = false
            handleProfileImageChange()
            return
        } else if setDesignation {
            setDesignation = false
            designationTextField.becomeFirstResponder()
            return
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
      textField.endEditing(true)
      return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
      ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 0))
      textField.endEditing(true)
    }

    internal func textFieldDidBeginEditing(_ textField: UITextField) {
      if textField == emailIdTextField
      {
        ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 290) )
      }else if textField == emailIdForCommunication
      {
        ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 330) )
      }
      else{
        let y = textField.superview!.frame.origin.y+textField.frame.origin.y
        ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: y-100))
      }


    }

    private func isEmailIdValid(emailId : String?) -> Bool {
      AppDelegate.getAppDelegate().log.debug("isEmailIdValid()")
      if emailId == nil || emailId!.isEmpty {
        return false

      }
      return AppUtil.isValidEmailId(emailId: emailId!)
    }


    @objc func keyBoardWillShow(notification : NSNotification){
      AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")

      if (!isKeyboardVisible) {
        if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
          upadatePersonalInfoBottomConstarint.constant = keyBoardSize.height + 20
        }
      }
      isKeyboardVisible = true
    }

    @objc func keyBoardWillHide(notification: NSNotification){
      AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
     if (isKeyboardVisible) {
        upadatePersonalInfoBottomConstarint.constant = 20
      }
      isKeyboardVisible = false
    }

    func initializeUserProfileFromCache(){
      AppDelegate.getAppDelegate().log.debug("initializeUserProfileFromCache()")
      self.defaultClientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()

      self.userId = QRSessionManager.getInstance()!.getUserId()
        if let userObject = UserDataCache.getInstance()?.getUser(){
            self.user = userObject.copy() as? User
            if self.user != nil && self.userProfile != nil {
              self.populateDataInView()
            }
        }
        if let userProfileObject = UserDataCache.getInstance()?.getUserProfile(userId: self.userId!){
          self.userProfile = userProfileObject.copy() as? UserProfile
          if self.user != nil && self.userProfile != nil {
            self.populateDataInView()
          }
        }
    }

    func populateDataInView(){
        AppDelegate.getAppDelegate().log.debug("populateDataInView()")
        ImageCache.getInstance().setImageToView(imageView: self.userImage, imageUrl: self.userProfile?.imageURI, gender: (self.userProfile?.gender)!,imageSize: ImageCache.DIMENTION_SMALL)
        self.userNameTextField.text = self.userProfile?.userName
        self.designationTextField.text = self.userProfile?.profession
        self.emailIdTextField.text = self.userProfile?.email
        self.emailIdForCommunication.text = self.userProfile?.emailForCommunication
        self.userPreferredRole = self.userProfile?.roleAtSignup
        if userProfile?.dateOfBirth != nil{
            birthDateView.isHidden = true
            addBirthDateView.isHidden = true
            addBirthDateViewHeightConstraint.constant = 0
            birthDateViewHeightConstraint.constant = 0
        }else{
            birthDateView.isHidden = false
            self.birthDateLabel.text = Strings.birth_date_placeholder
            self.birthDateLabel.textColor = UIColor.black.withAlphaComponent(0.4)
            addBirthDateView.isHidden = false
            addBirthDateViewHeightConstraint.constant = 40
            birthDateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileEditingViewController.birthDateViewTapped(_:))))
            birthDateViewHeightConstraint.constant = 50
        }

        ImageUtils.setTintedIcon(origImage: UIImage(named: "info_icon_blue")!, imageView: infoIcon, color: UIColor(netHex: 0xC56E00))
        QuickRideProgressSpinner.stopSpinner()
        checkForNewUserToast()
        handlePreferredRoleViewBasedOnDefaultRole()
    }

    func handlePreferredRoleViewBasedOnDefaultRole(){

        if self.userPreferredRole == UserProfile.PREFERRED_ROLE_RIDER{
            findRideView.backgroundColor = UIColor.white
            offerRideView.backgroundColor = UIColor(netHex: 0x636363)
            bothView.backgroundColor = UIColor.white
            findRideLbl.textColor = UIColor(netHex: 0x666666)
            offerRideLbl.textColor = UIColor.white
            bothRideLbl.textColor = UIColor(netHex: 0x666666)

        }else if self.userPreferredRole == UserProfile.PREFERRED_ROLE_PASSENGER{
           findRideView.backgroundColor = UIColor(netHex: 0x636363)
            offerRideView.backgroundColor = UIColor.white
            bothView.backgroundColor = UIColor.white
            findRideLbl.textColor = UIColor.white
            offerRideLbl.textColor = UIColor(netHex: 0x666666)
            bothRideLbl.textColor = UIColor(netHex: 0x666666)

        }else{
            findRideView.backgroundColor = UIColor.white
            offerRideView.backgroundColor = UIColor.white
            bothView.backgroundColor = UIColor(netHex: 0x636363)
            findRideLbl.textColor = UIColor(netHex: 0x666666)
            offerRideLbl.textColor = UIColor(netHex: 0x666666)
            bothRideLbl.textColor = UIColor.white

        }
    }


    @objc func editProfileImage(_ gesture : UITapGestureRecognizer){
        handleProfileImageChange()
    }
    func handleProfileImageChange(){
        AppDelegate.getAppDelegate().log.debug("changePhoto()")
        self.view.endEditing(false)
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: isRemoveOptionApplicableForPic, viewController: self,delegate: self){ [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }

    override func didReceiveMemoryWarning() {
      AppDelegate.getAppDelegate().log.debug("didReceiveMemoryWarning()")
      super.didReceiveMemoryWarning()
      // Dispose of any resources that can be recreated.
    }


    func moveScrollToOffset(textField:UITextField) {
      AppDelegate.getAppDelegate().log.debug("moveScrollToOffset()")
      if storePreviousTextField.frame.origin.y != textField.frame.origin.y
      {
        if scrollView!.contentOffset.y < self.view.frame.height - 80
        {
            scrollView!.setContentOffset(CGPoint(x: scrollView!.contentOffset.x, y: textField.frame.origin.y - scrollView!.contentOffset.y - 80), animated: false)
        }
        else{
            scrollView!.setContentOffset(CGPoint(x: scrollView!.contentOffset.x, y:textField.frame.origin.y - scrollView!.contentOffset.y + self.view.frame.height), animated: false)
        }
      }
    }


    func checkIsOfficeEmailAndConveyAccordingly(emailId : String?) -> Bool{
      if emailId == nil || emailId!.isEmpty{
        return true
      }
      for emailDomain in UserProfile.publicDomainEmails{
        if emailId!.contains(emailDomain){
            UIApplication.shared.keyWindow?.makeToast(Strings.official_email_error)
          return false
        }
      }
      return true
    }
    private func saveProfileChanges() {
      AppDelegate.getAppDelegate().log.debug("saveProfileChanges()")
      self.view.endEditing(true)
     emailIdTextField.text = emailIdTextField.text!.replacingOccurrences(of: " ", with: "")
     emailIdForCommunication.text = emailIdForCommunication.text!.replacingOccurrences(of: " ", with: "")
      let validationErrorMsg = validateFieldsAndReturnErrorMsgIfAny()
      if (validationErrorMsg != nil) {
        MessageDisplay.displayAlert( messageString: validationErrorMsg!, viewController: self,handler: nil)
        return
      }
      checkWhetherProfileDetailsChanged()

      self.continueProfileSaving()
    }
    func continueProfileSaving(){
      if QRReachability.isConnectedToNetwork() == false {
        ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
        return
      }
      if self.isProfileUpdated || self.isProfilePicUpdated || self.isEmailUpdated{

        if isEmailUpdated{
          let givenEmailId = self.emailIdTextField.text
            if givenEmailId != nil && givenEmailId!.isEmpty == false{
                if !UserProfileValidationUtils.isOrganisationEmailIdIsValid(orgEmail: givenEmailId!) {
                    MessageDisplay.displayAlert( messageString: Strings.invalid_org_email_msg, viewController: self,handler: nil)
                    return
                }else if self.checkIsOfficeEmailAndConveyAccordingly(emailId: self.emailIdTextField.text) == false{
                self.displayEmailNotValidConfirmationDialog(userMessage: Strings.not_official_email_dialog)
                return
              }
                AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.ORG_EMAIL_ENTERED, params: ["UserId" : QRSessionManager.getInstance()?.getUserId() ?? ""], uniqueField: User.FLD_USER_ID)
              self.updateUserProfileWithNewDetails()
              return
            }else{
              self.updateUserProfileWithNewDetails()
            }
        }
        else{
          self.updateUserProfileWithNewDetails()
        }
      }else{
        self.checkCompletionOfSavingProfileAndTerminate()
      }
    }
    func checkForNewUserToast(){
      if presentedFromActivationView{
       UIApplication.shared.keyWindow?.makeToast( Strings.comapnyname_official_email_required)
      }
    }

    func displayEmailNotValidConfirmationDialog( userMessage : String)
    {
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: userMessage, message2: nil, positiveActnTitle: Strings.change_caps, negativeActionTitle : Strings.skip_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.skip_caps == result{
                self.updateUserProfileWithNewDetails()
            }
            else{
                self.emailIdTextField.becomeFirstResponder()
                ScrollViewUtils.scrollToPoint(scrollView: self.scrollView, point: CGPoint(x: 0, y: 120))
            }
        })
    }

    func displayEmailNotMatchingConfirmationDialog( userMessage : String)
    {
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: userMessage, message2: nil, positiveActnTitle: Strings.no_caps, negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.yes_caps == result{
                self.updateUserProfileWithNewDetails()
            }
            else{
                self.emailIdTextField.becomeFirstResponder()
                ScrollViewUtils.scrollToPoint(scrollView: self.scrollView, point: CGPoint(x: 0, y: 120))
            }
        })
    }
    func updateUserProfileWithNewDetails(){
      if self.userNameTextField.text!.isEmpty == false{
        userProfile?.userName = self.userNameTextField.text!

      }else{
        userProfile?.userName = nil
      }

      if self.designationTextField.text!.isEmpty == false{
        userProfile?.profession = self.designationTextField.text!
      }else{
        userProfile?.profession = nil
      }

      if self.emailIdTextField.text!.isEmpty == false{
        userProfile?.email = self.emailIdTextField.text!
      }else{
        userProfile?.email = nil
        userProfile?.companyName = nil
      }
      if self.emailIdForCommunication.text!.isEmpty == false{
        userProfile?.emailForCommunication = self.emailIdForCommunication.text!
      }else{
        userProfile?.emailForCommunication = nil
      }
      userProfile?.emergencyContactNumber =  emergencyContact
       userProfile?.roleAtSignup = self.userPreferredRole!
        if birthDateLabel.text != nil && !birthDateLabel.text!.isEmpty && birthDateLabel.text != Strings.birth_date_placeholder{
            let dateObj = DateUtils.getDateFromString(date: birthDateLabel.text, dateFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
            userProfile?.dateOfBirth = DateUtils.getDoubleFromNSDate(date: dateObj, dateFormat: DateUtils.DATE_FORMAT_yyyy_MM_dd_HH_mm_ss)
        }
       QuickRideProgressSpinner.startSpinner()
      checkAndSaveUserImage()
    }

    func checkAndSaveUserImage(){
      AppDelegate.getAppDelegate().log.debug("checkAndSaveUserImage()")
      if isProfilePicUpdated  {


        let image = ImageUtils.RBResizeImage(image: self.actualImage!, targetSize: CGSize(width: 540, height: 540))

        ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: image), targetViewController: self, completionHandler: {(responseObject, error) in
            self.processUserImage(responseObject: responseObject,error: error)
        })
      }else{
        self.checkAndSaveUserProfile()
        }
    }
    func processUserImage(responseObject : NSDictionary?,error : NSError?){
      if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{

        self.userProfile!.imageURI = responseObject!["resultData"] as? String
        ImageCache.getInstance().storeImageToCache(imageUrl: self.userProfile!.imageURI!, image: self.actualImage!)
        self.userImage.image = actualImage!.circle
        self.isProfilePicUpdated = false
        self.isProfileUpdated = true
        self.checkAndSaveUserProfile()
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.PICTURE_ADDED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "" ,"context": "PROFILE"], uniqueField: User.FLD_USER_ID)
      }
      else {
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
      }
    }

    func checkAndSaveUserProfile(){
        var configuration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if configuration == nil{
            configuration = ClientConfigurtion()
        }
        if userProfile != nil && userProfile!.imageURI == nil && !configuration!.disableImageVerification{
            QuickRideProgressSpinner.stopSpinner()
            self.view.endEditing(false)
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.please_upload_profile_picture, message2: nil, positiveActnTitle: Strings.UPLOAD_CAPS, negativeActionTitle : Strings.skip_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.skip_caps == result{
                    QuickRideProgressSpinner.startSpinner()
                    self.continueSavingUserProfile()
                }
                else{
                    self.handleProfileImageChange()
                }
            })
        }
        else{
            self.continueSavingUserProfile()
        }
    }

    func continueSavingUserProfile(){
        if isProfileUpdated == false && isEmailUpdated == false{
            return
        }
        AppDelegate.getAppDelegate().log.debug("saveUserProfile()")
        ProfileRestClient.putProfileWithBody(targetViewController: self, body: userProfile!.getParamsMap()) { (responseObject, error) -> Void in

            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserProfile(userProfile: self.userProfile!)
                self.isProfileUpdated = false
                if self.isEmailUpdated{
                    self.isEmailUpdated = false
                }
                self.checkCompletionOfSavingProfileAndTerminate()

            }else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    func checkCompletionOfSavingProfileAndTerminate(){

      if isProfileUpdated == false && isProfilePicUpdated == false && isEmailUpdated == false{
        QuickRideProgressSpinner.stopSpinner()
        removeViewViewController()
        if userProfile!.verificationStatus == 0 && isValidEmail && userProfile!.email != nil
        {
         UIApplication.shared.keyWindow?.makeToast( "\(Strings.verify_mail_sent_part1) \(userProfile!.email!) . \(Strings.verify_mail_sent_part2)")
        }
        else
        {
         UIApplication.shared.keyWindow?.makeToast( Strings.user_profile_update)
        }
      }
    }

    func checkWhetherProfileDetailsChanged(){
      AppDelegate.getAppDelegate().log.debug("checkWhetherProfileDetailsChanged()")
      if userProfile == nil || user == nil{
        return
      }
      var input = userNameTextField.text
      if (userProfile!.userName == nil && input?.isEmpty == false) || (userProfile!.userName != nil && input!.isEmpty == true) || (userProfile!.userName != nil && userProfile!.userName != input){
        self.isProfileUpdated = true
      }

      input = emailIdTextField.text
      if (userProfile!.email == nil && input?.isEmpty == false) || (userProfile!.email != nil && input!.isEmpty == true) || (userProfile!.email != nil && userProfile!.email != input){
        self.isEmailUpdated = true
      }

      input = emailIdForCommunication.text

      if (userProfile!.emailForCommunication == nil && input?.isEmpty == false) || (userProfile!.emailForCommunication != nil && input?.isEmpty == true) || (userProfile!.emailForCommunication != nil && userProfile!.emailForCommunication != input){
        self.isProfileUpdated = true
      }

      input = designationTextField.text
      if (userProfile!.profession == nil && input!.isEmpty == false) || (userProfile!.profession != nil && input!.isEmpty == true) || (userProfile!.profession != nil && userProfile!.profession != input){
        self.isProfileUpdated = true
      }

        input = birthDateLabel.text
        if userProfile!.dateOfBirth == nil && input != Strings.birth_date_placeholder {
            self.isProfileUpdated = true
        }

        if userProfile!.roleAtSignup != self.userPreferredRole{
            self.isProfileUpdated = true
        }
    }
    func validateFieldsAndReturnErrorMsgIfAny() -> String? {
      AppDelegate.getAppDelegate().log.debug("validateFieldsAndReturnErrorMsgIfAny()")
      if userNameTextField.text == nil || userNameTextField.text?.isEmpty == true {
        return Strings.enter_name
      }else if UserProfileValidationUtils.validateStringForAlphabatic(string: userNameTextField.text!) == false{
        return Strings.enter_valid_name
      }else if emailIdTextField.text != nil && emailIdTextField.text!.isEmpty == false && isEmailIdValid(emailId: emailIdTextField.text) == false{
        return Strings.enter_valid_email_id
      }else if emailIdForCommunication.text == nil || emailIdForCommunication.text!.isEmpty{
        return Strings.enter_communication_email_id
      }
      else if isEmailIdValid(emailId: emailIdForCommunication.text!) == false {
        return Strings.enter_valid_email_id
      }

      return nil
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
      var threshold : Int?
      if textField == userNameTextField{
        threshold = 200
      }else if textField == designationTextField{
        threshold = 100
      }else if textField == emailIdTextField || textField == emailIdForCommunication{
        threshold = 100
      }else{
        return true
      }
      let currentCharacterCount = textField.text?.count ?? 0
        if textField == emailIdTextField{
            CompanyDomainSuggestionUtils().getCompanyDomainsBasedOnEnteredCharacter(emailDomain: textField.text ?? "",textField: emailIdTextField,anchorView: orgSeparetorView)
        }
      if (range.length + range.location > currentCharacterCount){
        return false
      }
      let newLength = currentCharacterCount + string.count - range.length
      return newLength <= threshold!
    }

    @objc func findRideViewTapped(_ gesture : UITapGestureRecognizer){
        findRideView.backgroundColor = UIColor(netHex: 0x636363)
        offerRideView.backgroundColor = UIColor.white
        bothView.backgroundColor = UIColor.white
        findRideLbl.textColor = UIColor.white
        offerRideLbl.textColor = UIColor(netHex: 0x666666)
        bothRideLbl.textColor = UIColor(netHex: 0x666666)
        self.userPreferredRole = UserProfile.PREFERRED_ROLE_PASSENGER
    }

    @objc func offerRideViewTapped(_ gesture : UITapGestureRecognizer){
        findRideView.backgroundColor = UIColor.white
        offerRideView.backgroundColor = UIColor(netHex: 0x636363)
        bothView.backgroundColor = UIColor.white
        findRideLbl.textColor = UIColor(netHex: 0x666666)
        offerRideLbl.textColor = UIColor.white
        bothRideLbl.textColor = UIColor(netHex: 0x666666)
        self.userPreferredRole = UserProfile.PREFERRED_ROLE_RIDER
    }

    @objc func bothViewTapped(_ gesture : UITapGestureRecognizer){
        findRideView.backgroundColor = UIColor.white
        offerRideView.backgroundColor = UIColor.white
        bothView.backgroundColor = UIColor(netHex: 0x636363)
        findRideLbl.textColor = UIColor(netHex: 0x666666)
        offerRideLbl.textColor = UIColor(netHex: 0x666666)
        bothRideLbl.textColor = UIColor.white
        self.userPreferredRole = UserProfile.PREFERRED_ROLE_BOTH
    }

    @objc func birthDateViewTapped(_ gesture : UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let scheduleLater:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        let maxDate = Calendar.current.date(byAdding: .year, value: -18, to: Date())
        let timeInterval = Double(maxDate!.timeIntervalSince1970)
        scheduleLater.initializeDataBeforePresentingView(minDate : nil,maxDate: timeInterval, defaultDate: timeInterval, isDefaultDateToShow: false, delegate: self, datePickerMode: UIDatePicker.Mode.date, datePickerTitle: nil, handler: nil)
        scheduleLater.modalPresentationStyle = .overCurrentContext
        self.present(scheduleLater, animated: false, completion: nil)
    }

    func getTime(date: Double) {
        birthDateLabel.text = DateUtils.getDateStringFromNSDate(date: NSDate(timeIntervalSince1970: date), dateFormat: DateUtils.DATE_FORMAT_dd_MMM_yyy)
        self.birthDateLabel.textColor = UIColor.black.withAlphaComponent(1)
        addBirthDateView.isHidden = true
        addBirthDateViewHeightConstraint.constant = 0
    }
    
  }
extension ProfileEditingViewController: UIImagePickerControllerDelegate{
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
            self.isProfilePicUpdated = isUpdated
            self.isRemoveOptionApplicableForPic = true
            self.actualImage = image
            self.userImage.image = image!.circle!
        }else{
            self.isProfileUpdated = isUpdated
            self.userProfile!.imageURI = nil
            self.userImage.image = ImageCache.getInstance().getDefaultUserImage(gender: self.user?.gender ?? "U")
            self.isRemoveOptionApplicableForPic = false
        }
    }
}
