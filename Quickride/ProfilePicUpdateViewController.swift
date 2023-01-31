//
//  ProfilePicUpdateViewController.swift
//  Quickride
//
//  Created by Admin on 16/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

typealias ProfilePicUpdateCompletionHandler = ()->Void

class ProfilePicUpdateViewController : UIViewController{
    

 @IBOutlet weak var userNameLbl: UILabel!
    
 @IBOutlet weak var userImageView: CircularImageView!
    
 @IBOutlet weak var addPictureLbl: UILabel!
    
 @IBOutlet weak var editBtn: UIButton!
    
 @IBOutlet weak var defaultIconView: UIView!
    
 @IBOutlet weak var continueBtn: UIButton!
    
 @IBOutlet weak var nameInitialLetterLbl: UILabel!
    
 var userProfile : UserProfile?
 var isProfilePicUpdated = false
 var isRemoveOptionApplicableForPic = false
 var actualImage: UIImage?
 var handler : ProfilePicUpdateCompletionHandler?
 var prevStatus = true
    
 func initializeDataBeforePresenting(handler : @escaping ProfilePicUpdateCompletionHandler){
   self.handler = handler
 }
  
    
  override func viewDidLoad() {
    definesPresentationContext = true
    self.userProfile = UserDataCache.getInstance()?.getLoggedInUserProfile()
    ViewCustomizationUtils.addCornerRadiusToView(view: userImageView, cornerRadius: 75)
    ViewCustomizationUtils.addCornerRadiusToView(view: defaultIconView, cornerRadius: 20)
    ViewCustomizationUtils.addCornerRadiusToView(view: continueBtn, cornerRadius: 10)
    userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilePicUpdateViewController.userImageImageTapped(_:))))
    defaultIconView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfilePicUpdateViewController.userImageImageTapped(_:))))
    self.userNameLbl.text = String(format: Strings.name_text, arguments: [userProfile!.userName!])
    self.nameInitialLetterLbl.text = "\(userProfile!.userName!.prefix(1))"
     ViewCustomizationUtils.addBorderToView(view: userImageView, borderWidth: 1, colorCode: 0x2196f3)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.continueActnColorChange()
    }

    func showImagePickerAlertController(){
        AppDelegate.getAppDelegate().log.debug("")
        self.view.endEditing(false)
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: isRemoveOptionApplicableForPic, viewController: self, delegate: self){ [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }

    func checkAndSaveUserImage(){
        AppDelegate.getAppDelegate().log.debug("")
        if isProfilePicUpdated  {
            let image = ImageUtils.RBResizeImage(image: self.actualImage!, targetSize: CGSize(width: 540, height: 540))
            SharedPreferenceHelper.setImage(image: self.actualImage!)
            QuickRideProgressSpinner.startSpinner()
            ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: image), targetViewController: self, completionHandler: {(responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                self.processUserImage(responseObject: responseObject,error: error)
            })
        }else{
            handler!()
        }
        
    }
    
    func processUserImage(responseObject : NSDictionary?,error : NSError?){
        if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
            
            if userProfile != nil{
                self.userProfile!.imageURI = responseObject!["resultData"] as? String
                self.userImageView.image = actualImage!.circle
                self.checkAndSaveUserProfile()
            }
        }
        else {
            ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
        }
    }
    
    @objc func userImageImageTapped(_ sender: UITapGestureRecognizer){
        self.showImagePickerAlertController()
    }
    func checkAndSaveUserProfile(){
       QuickRideProgressSpinner.startSpinner()
        ProfileRestClient.putProfileWithBody(targetViewController: self, body: userProfile!.getParamsMap()) { (responseObject, error) -> Void in
        QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                self.userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()?.storeUserProfile(userProfile: self.userProfile!)
                self.dismiss(animated: false, completion: nil)
                self.handler!()
            }else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }
    
    func continueActnColorChange(){
        if userImageView.image != nil{
            CustomExtensionUtility.changeBtnColor(sender: self.continueBtn, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
            continueBtn.isUserInteractionEnabled = true
        }
        else{
            CustomExtensionUtility.changeBtnColor(sender: self.continueBtn, color1: UIColor.lightGray, color2: UIColor.lightGray)
            continueBtn.isUserInteractionEnabled = false
        }
    }
  
    
    
 @IBAction func editIconTapped(_ sender: Any) {
    self.showImagePickerAlertController()
 }
    
  @IBAction func continueBtnClicked(_ sender: Any) {
     self.checkAndSaveUserImage()
  }
    
    
   @IBAction func closeBtnClicked(_ sender: Any) {
    
     self.dismiss(animated: false, completion: nil)
     handler!()
   }
    
}
extension ProfilePicUpdateViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
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
            self.editBtn.isHidden = false
            ViewCustomizationUtils.addBorderToView(view: self.userImageView, borderWidth: 1, colorCode: 0xFFFFFF)
            self.isProfilePicUpdated = true
            self.isRemoveOptionApplicableForPic = true
            self.actualImage = image
            self.userImageView.image = image!.circle!
            self.addPictureLbl.isHidden = true
            self.defaultIconView.isHidden = true
            self.continueActnColorChange()
        }else{
            self.userProfile = SharedPreferenceHelper.getUserProfileObject()
            if self.userProfile != nil{
                self.userProfile!.imageURI = nil
            }
            self.editBtn.isHidden = true
            ViewCustomizationUtils.addBorderToView(view: self.userImageView, borderWidth: 1, colorCode: 0x2196f3)
            self.isProfilePicUpdated = false
            self.addPictureLbl.isHidden = false
            self.defaultIconView.isHidden = false
            if self.userProfile != nil && self.userProfile!.userName != nil{
                self.nameInitialLetterLbl.text = "\(self.userProfile!.userName!.prefix(1))"
            }
            else{
                self.defaultIconView.isHidden = true
            }
            self.userImageView.image = nil
            self.isRemoveOptionApplicableForPic = false
            self.continueActnColorChange()
        }
    }
}
