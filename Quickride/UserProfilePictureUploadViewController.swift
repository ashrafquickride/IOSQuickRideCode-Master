//
//  UserProfilePictureUploadViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 9/20/17.
//  Copyright © 2017 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper
import Lottie

class UserProfilePictureUploadViewController: UIViewController, UINavigationControllerDelegate
{
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var addPictureLabel: UILabel!
    
    @IBOutlet weak var continueActnBtn: UIButton!
   
    @IBOutlet weak var initialUserNameView: UIView!
    
    @IBOutlet weak var nameInitialLetterLabel: UILabel!
    
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var labelRewardsPoints: UILabel!
    
    @IBOutlet weak var bonusPointsTxtLbl: UILabel!
    
    @IBOutlet weak var bonusPointsView: UIView!
    
    
    @IBOutlet weak var walletLoadingAnimationView: LOTAnimationView!

    @IBOutlet weak var walletImageView: UIImageView!
    
    var preferredRole : String?
    var isProfilePicUpdated = false
    var isRemoveOptionApplicableForPic = false
    var userProfile : UserProfile?
    var topViewController : SignUpStepsViewController?
    var actualImage: UIImage?
    
    override func viewDidLoad()
    {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.editBtn.isHidden = true
        self.userProfile = SharedPreferenceHelper.getUserProfileObject()
        if userProfile != nil && userProfile!.imageURI != nil{
            ImageCache.getInstance().setImageToView(imageView: self.userImageView, imageUrl: userProfile!.imageURI!, placeHolderImg: SharedPreferenceHelper.getImage())
            self.editBtn.isHidden = false
            self.isRemoveOptionApplicableForPic = true
            self.initialUserNameView.isHidden = true
            addPictureLabel.isHidden = true
            ViewCustomizationUtils.addBorderToView(view: userImageView, borderWidth: 1, colorCode: 0xFFFFFF)
        }
        else{
            if userProfile != nil && userProfile!.userName != nil {
                initialUserNameView.isHidden = false
                self.nameInitialLetterLabel.text = "\(userProfile!.userName!.prefix(1))"
            }
            else{
                self.initialUserNameView.isHidden = true
            }
            self.editBtn.isHidden = true
            addPictureLabel.isHidden = false
            ViewCustomizationUtils.addBorderToView(view: userImageView, borderWidth: 1, colorCode: 0x2196f3)
        }
        
        if let coupon = SignUpStepsViewController.checkAndReturnSystemCouponIfPresent(usageContext: SystemCouponCode.COUPON_USUAGE_CONTEXT_ADDED_PICTURE){
            self.walletLoadingAnimationView.isHidden = false
            self.walletImageView.isHidden = false
            self.bonusPointsView.isHidden = false
            refreshAccountInfo()
            let string = String(format: Strings.pic_bonus_points_text, arguments: ["\u{20B9}",StringUtils.getStringFromDouble(decimalNumber: coupon.cashDeposit)])
            let attributedString = ViewCustomizationUtils.createNSAttributeWithParagraphStyle(string: string)
            let range = NSRange(location: 101, length: StringUtils.getStringFromDouble(decimalNumber: coupon.cashDeposit).count + 10)
            attributedString?.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(netHex: 0x00B557), range: range)
            self.bonusPointsTxtLbl.attributedText = attributedString
        }else{
            self.bonusPointsTxtLbl.text = Strings.pic_text_without_bonus
            self.walletImageView.isHidden = true
            self.walletLoadingAnimationView.isHidden = true
            self.bonusPointsView.isHidden = true
            let attributedString = NSMutableAttributedString(string: self.bonusPointsTxtLbl.text!)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            paragraphStyle.lineHeightMultiple = 1.5
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            self.bonusPointsTxtLbl.attributedText = attributedString
        }
     
        
        ViewCustomizationUtils.addCornerRadiusToView(view: userImageView, cornerRadius: 75)
        ViewCustomizationUtils.addCornerRadiusToView(view: initialUserNameView, cornerRadius: 20)
        ViewCustomizationUtils.addCornerRadiusToView(view: continueActnBtn, cornerRadius: 10)
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserProfilePictureUploadViewController.userImageImageTapped(_:))))
        initialUserNameView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(UserProfilePictureUploadViewController.userImageImageTapped(_:))))
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }
    override func viewDidAppear(_ animated: Bool) {
        continueActnColorChange()
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
                    self.labelRewardsPoints.text = StringUtils.getPointsInDecimal(points: userAccount!.rewardsPoints)
                    self.walletLoadingAnimationView.isHidden = true
                    self.walletLoadingAnimationView.stop()
                    self.bonusPointsView.isHidden = false
                }
            })
        }
    }
    func displayProfilePicAlert(){
        let userProfilePicSatus = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_PROFILE_PIC_UPLOAD)
        if !isProfilePicUpdated && (userProfilePicSatus == nil ||  userProfilePicSatus == false){
            MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.please_upload_profile_picture, message2: nil, positiveActnTitle: Strings.UPLOAD_CAPS, negativeActionTitle : Strings.skip_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                if Strings.skip_caps == result{
                    self.moveToNextPage()
                }
                else{
                    self.showImagePickerAlertController()
                    
                }
            })
        }
        else{
           self.moveToNextPage()
           self.checkAndSaveUserImage()
        }
    }
    
    @IBAction func editIconTapped(_ sender: Any) {
       self.showImagePickerAlertController()
    }
    @objc func userImageImageTapped(_ sender: UITapGestureRecognizer){
        self.showImagePickerAlertController()
    }
    func checkAndSaveUserProfile(){
         ProfileRestClient.putProfileWithBody(targetViewController: self, body: userProfile!.getParamsMap()) { (responseObject, error) -> Void in
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"])
                SharedPreferenceHelper.storeUserProfileObject(userProfileObj: self.userProfile!)
                self.topViewController?.refreshAccountInformation()
                if SignUpStepsViewController.checkAndReturnSystemCouponIfPresent(usageContext: SystemCouponCode.COUPON_USUAGE_CONTEXT_ADDED_PICTURE) != nil{
                   SignUpStepsViewController.accountActivationViewController?.refreshAccountInfo()
                }
             }else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    func moveToNextPage()
    {
        let user = SharedPreferenceHelper.getUserObject()
        var preferredRole = SharedPreferenceHelper.getUserPreferredRole()
        if preferredRole == nil{
            preferredRole = UserProfile.PREFERRED_ROLE_BOTH
        }
        UserRestClient.sendRegistrationMailAfterSignup(userId: StringUtils.getStringFromDouble(decimalNumber: user?.phoneNumber), preferedRole: preferredRole!, viewController: self) { (responseObject, error) in
            
        }
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_PROFILE_PIC_UPLOAD, value: true)
        self.topViewController?.moveToAccountActivatedView()
        self.topViewController = nil
        
    }
    func continueActnColorChange(){
        if userImageView.image != nil{
            CustomExtensionUtility.changeBtnColor(sender: self.continueActnBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            continueActnBtn.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: self.continueActnBtn, color1: UIColor.lightGray, color2: UIColor.lightGray)
            continueActnBtn.isUserInteractionEnabled = false
        }
    }
    func showImagePickerAlertController(){
        AppDelegate.getAppDelegate().log.debug("")
        self.view.endEditing(false)
        let uploadImageAlertController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "UploadImageAlertController") as! UploadImageAlertController
        uploadImageAlertController.initializeDataBeforePresentingView(isRemoveOptionApplicable: isRemoveOptionApplicableForPic, viewController: self, handler: { (isUpdated, imageURI, image) in
            if image != nil{
                self.editBtn.isHidden = false
                ViewCustomizationUtils.addBorderToView(view: self.userImageView, borderWidth: 1, colorCode: 0xFFFFFF)
                self.isProfilePicUpdated = true
                self.isRemoveOptionApplicableForPic = true
                self.actualImage = image
                self.userImageView.image = image!.circle!
                self.addPictureLabel.isHidden = true
                self.initialUserNameView.isHidden = true
                self.continueActnColorChange()
            }
            else{
                self.userProfile = SharedPreferenceHelper.getUserProfileObject()
                if self.userProfile != nil{
                    self.userProfile!.imageURI = nil
                }
                self.editBtn.isHidden = true
                ViewCustomizationUtils.addBorderToView(view: self.userImageView, borderWidth: 1, colorCode: 0x2196f3)
                self.isProfilePicUpdated = false
                self.addPictureLabel.isHidden = false
                self.initialUserNameView.isHidden = false
                if self.userProfile != nil && self.userProfile!.userName != nil{
                    self.nameInitialLetterLabel.text = "\(self.userProfile!.userName!.prefix(1))"
                }
                else{
                    self.initialUserNameView.isHidden = true
                }
                self.userImageView.image = nil
                self.isRemoveOptionApplicableForPic = false
                self.continueActnColorChange()
            }
            
        })
        self.navigationController?.view.addSubview(uploadImageAlertController.view)
        self.navigationController?.addChild(uploadImageAlertController)
        uploadImageAlertController.view!.layoutIfNeeded()
    }
    
    func checkAndSaveUserImage(){
        AppDelegate.getAppDelegate().log.debug("")
        if isProfilePicUpdated  {
            let image = ImageUtils.RBResizeImage(image: self.actualImage!, targetSize: CGSize(width: 540, height: 540))
            SharedPreferenceHelper.setImage(image: self.actualImage!)
            ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: image), targetViewController: self, completionHandler: {(responseObject, error) in
                 self.processUserImage(responseObject: responseObject,error: error)
            })
        }
        else{
            self.userProfile = SharedPreferenceHelper.getUserProfileObject()
            if userProfile != nil{
               checkAndSaveUserProfile()
            }
            
        }
    }
    func processUserImage(responseObject : NSDictionary?,error : NSError?){
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_IMAGE_DETAILS_SIGN_UP, params: [
                "user_image_uploaded" : true])
            self.userProfile = SharedPreferenceHelper.getUserProfileObject()
            if userProfile != nil{
                self.userProfile!.imageURI = responseObject!["resultData"] as? String
                self.userImageView.image = actualImage!.circle
                self.checkAndSaveUserProfile()
            }
            SharedPreferenceHelper.setSavingStatusForKey(key: SharedPreferenceHelper.SAVING_STATUS_PIC_DETAILS, status: true)
        }
        else {
            SharedPreferenceHelper.setSavingStatusForKey(key: SharedPreferenceHelper.SAVING_STATUS_PIC_DETAILS, status: false)
        }
    }
    @IBAction func continueActnClicked(_ sender: Any) {
        var configuration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if configuration == nil{
            configuration = ClientConfigurtion()
        }
        if configuration!.disableImageVerification {
           self.checkAndSaveUserImage()
           self.moveToNextPage()
        }
        else{
           displayProfilePicAlert()
        }
    }

    @IBAction func skipBtnClicked(_ sender: Any) {
       
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.USER_IMAGE_DETAILS_SIGN_UP, params: [
            "user_image_uploaded" : false])
        
        var configuration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if configuration == nil{
            configuration = ClientConfigurtion()
        }
        if configuration!.disableImageVerification {
            self.moveToNextPage()
        }
        else{
            self.displayProfilePicAlert()
        }
    }
}
