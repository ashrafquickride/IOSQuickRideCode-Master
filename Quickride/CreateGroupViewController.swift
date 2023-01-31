//
//  CreateGroupViewController.swift
//  Quickride
//
//  Created by rakesh on 3/8/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper
import CoreLocation


class CreateGroupViewController :  UIViewController, UINavigationControllerDelegate,UITextFieldDelegate,ReceiveLocationDelegate,CLLocationManagerDelegate{

    @IBOutlet weak var scrollViewBottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var groupImageView: UIImageView!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var groupDescriptionField: UITextField!
    @IBOutlet weak var publicView: UIView!
    @IBOutlet weak var privateView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var editGroupImage: UIButton!
    
    @IBOutlet weak var addGroupImageView: UIImageView!
    @IBOutlet weak var locationSelectionLabel: UILabel!
    @IBOutlet weak var publicGroupImageView: UIImageView!
    @IBOutlet weak var privateGroupImageView: UIImageView!
    
    @IBOutlet weak var createGroupBtn: UIButton!
    @IBOutlet weak var generalView: UIView!
    @IBOutlet weak var corporateView: UIView!
    @IBOutlet weak var generalCategoryImageView: UIImageView!
    @IBOutlet weak var corporateCategoryImageView: UIImageView!
    
    var isKeyboardVisible = false
    var isRemoveOptionApplicableForPic = false
    var isPicChanged = false
    var createdGroup : Group?
    var isPublicViewSelected = true
    var isPrivateViewSelected = false
    var isGeneralViewSelected = true
    var isCommunityViewSelected = false
    var isCorporateViewSelected = false
    var location = Location()
    var isGroupImageSaved = false
    var locationManager : CLLocationManager = CLLocationManager()
    private var  modelLessDialogue: ModelLessDialogue?
    
    override func viewDidLoad() {
     nameField.delegate = self
     definesPresentationContext = true
     groupDescriptionField.delegate = self
     ViewCustomizationUtils.addCornerRadiusToView(view: createGroupBtn, cornerRadius: 5.0)
      ViewCustomizationUtils.addCornerRadiusToView(view: editGroupImage, cornerRadius: editGroupImage.bounds.size.width/2.0)
     addGroupImageView.image = addGroupImageView.image!.withRenderingMode(.alwaysTemplate)
     addGroupImageView.tintColor = UIColor.white
     automaticallyAdjustsScrollViewInsets = false
     checkAndPlaceCursorPosition()
        NotificationCenter.default.addObserver(self, selector: #selector(CreateGroupViewController.keyBoardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(CreateGroupViewController.keyBoardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        locationSelectionLabel.isUserInteractionEnabled = true
        locationSelectionLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreateGroupViewController.selectLocationTapped(_:))))

        publicView.isUserInteractionEnabled = true
        publicView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreateGroupViewController.publicViewTapped(_:))))
        privateView.isUserInteractionEnabled = true
        privateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreateGroupViewController.privateViewTapped(_:))))
        generalView.isUserInteractionEnabled = true
        generalView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreateGroupViewController.generalViewTapped(_:))))

        corporateView.isUserInteractionEnabled = true
        corporateView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreateGroupViewController.corporateViewTapped(_:))))
       
    }
  
   
    @IBAction func EditImageBtnTapped(_ sender: Any) {
   
        AppDelegate.getAppDelegate().log.debug("changePhoto()")
        view.endEditing(false)
        handleGroupImageChange(sender as! UIButton)
    }
    
    func handleGroupImageChange(_ sender: UIButton){
        if (createdGroup?.imageURI != nil && self.createdGroup?.imageURI?.isEmpty  == false) {
            isRemoveOptionApplicableForPic = true
        }
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: isRemoveOptionApplicableForPic, viewController: self,delegate: self){ [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }
    
    func checkAndSaveGroupImage(){
        AppDelegate.getAppDelegate().log.debug("")
        
        if isPicChanged{
            var imageURI : String?
  
            QuickRideProgressSpinner.startSpinner()
            ImageRestClient.saveImage(photo: ImageUtils.convertToBase64String(imageToConvert: groupImageView.image!),targetViewController: self) { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    imageURI = responseObject!["resultData"]! as? String
                    ImageCache.getInstance().storeImageToCache(imageUrl: imageURI!, image: self.groupImageView.image!)
                    self.createGroupObjectAndSaveGroup(imageURI : imageURI)
                }
                else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            }
        }else{
            self.createGroupObjectAndSaveGroup(imageURI : nil)
        }
    }
    func createGroupObjectAndSaveGroup(imageURI : String?){
        var groupType = String()
        if self.isPublicViewSelected{
            groupType = Group.USER_GROUP_TYPE_PUBLIC
        }else if self.isPrivateViewSelected{
            groupType = Group.USER_GROUP_TYPE_PRIVATE
        }
        var groupCategory = String()
        if self.isGeneralViewSelected{
            groupCategory = Group.USER_GROUP_CATEGORY_GENERAL
        }else if self.isCommunityViewSelected{
            groupCategory = Group.USER_GROUP_CATEGORY_COMMUNITY
        }else{
            groupCategory = Group.USER_GROUP_CATEGORY_CORPORATE
        }
        
        let userProfile = UserDataCache.getInstance()!.getLoggedInUserProfile()
        
        if groupCategory == Group.USER_GROUP_CATEGORY_CORPORATE && userProfile?.verificationStatus == 0{
            self.displayEmailUnverifiedDialogue()
            return
        }
        var companyCode : String?
        if userProfile?.companyCode != nil{
            companyCode = userProfile!.companyCode!
        }else{
            companyCode = nil
        }
        self.createdGroup = Group(name: self.nameField.text! , imageURI: imageURI, description: self.groupDescriptionField.text!, type: groupType, creatorId: Double(QRSessionManager.getInstance()!.getUserId())!, url: nil, category: groupCategory, latitude:  self.location.latitude, longitude: self.location.longitude, address: self.location.completeAddress, creationTime: NSDate().getTimeStamp(), companyCode: companyCode)
        self.saveGroup()
    }
    @IBAction func saveGroupBtnClicked(_ sender: Any) {
       
        self.view.endEditing(false)
       let validationErrorMsg = validateFieldsAndReturnErrorMsgIfAny()
        if validationErrorMsg != nil {
            MessageDisplay.displayAlert( messageString: validationErrorMsg!, viewController: self,handler: nil)
            return
        }
      self.checkAndSaveGroupImage()
    }
    func saveGroup(){
        QuickRideProgressSpinner.startSpinner()
        GroupRestClient.createNewGroup(group: createdGroup!, viewController: self, handler: { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
             if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                let userGroup = Mapper<Group>().map(JSONObject: responseObject!["resultData"])
                UserDataCache.getInstance()!.addOrUpdateGroup(newGroup: userGroup!)
                self.navigationController?.popViewController(animated: false)
                UIApplication.shared.keyWindow?.makeToast( Strings.group_added)
            }else{
               ErrorProcessUtils.handleError(responseObject: responseObject,error: error,viewController: self, handler: nil)
             }
        })

    }

 @IBAction func backButtonPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func selectLocationTapped(_ sender: UITapGestureRecognizer){
        if locationSelectionLabel.text!.isEmpty{
            moveToSelectedLocation(locationType: ChangeLocationViewController.DESTINATION, location:nil)
        }else{
            moveToSelectedLocation(locationType: ChangeLocationViewController.DESTINATION, location: self.location)
        }
    }
    func moveToSelectedLocation(locationType : String, location : Location?){
        let storyboard = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil)
        let changeLocationVC: ChangeLocationViewController = storyboard.instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationVC.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: locationType, currentSelectedLocation: location, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: changeLocationVC, animated: false)
    }
    func receiveSelectedLocation(location: Location, requestLocationType: String) {
            self.location = location
            locationSelectionLabel.text = location.shortAddress
            locationSelectionLabel.textColor = Colors.locationTextColor
            locationSelectionLabel.font = locationSelectionLabel.font.withSize(15)
    }
    
    func locationSelectionCancelled(requestLocationType: String) {
        
    }
  
    
    @objc func publicViewTapped(_ sender: UITapGestureRecognizer){
     
        isPublicViewSelected = true
        isPrivateViewSelected = false
        publicGroupImageView.image = UIImage(named: "group_tick_icon")!
        privateGroupImageView.image = UIImage(named: "tick_icon")!
    }
    @objc func privateViewTapped(_ sender: UITapGestureRecognizer){
     
        isPublicViewSelected = false
        isPrivateViewSelected = true
        publicGroupImageView.image = UIImage(named: "tick_icon")!
        privateGroupImageView.image = UIImage(named: "group_tick_icon")!
    }
    
    @objc func generalViewTapped(_ sender: UITapGestureRecognizer){
        isGeneralViewSelected = true
        isCommunityViewSelected = false
        isCorporateViewSelected = false
        generalCategoryImageView.image = UIImage(named: "group_tick_icon")!
        corporateCategoryImageView.image = UIImage(named: "tick_icon")!
    }
    
    @objc func corporateViewTapped(_ sender: UITapGestureRecognizer){
        isGeneralViewSelected = false
        isCommunityViewSelected = false
        isCorporateViewSelected = true
        generalCategoryImageView.image = UIImage(named: "tick_icon")!
        corporateCategoryImageView.image = UIImage(named: "group_tick_icon")!
    }
    
    @objc func keyBoardWillShow(notification : NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillShow()")
        
        if (!isKeyboardVisible) {
            if let keyBoardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue{
                scrollViewBottomSpaceConstraint.constant = keyBoardSize.height
            }
        }
        isKeyboardVisible = true
    }
    
    @objc func keyBoardWillHide(notification: NSNotification){
        AppDelegate.getAppDelegate().log.debug("keyBoardWillHide()")
        if (isKeyboardVisible) {
            scrollViewBottomSpaceConstraint.constant = 0
        }
        isKeyboardVisible = false
    }
    
    func validateFieldsAndReturnErrorMsgIfAny() -> String? {
        AppDelegate.getAppDelegate().log.debug("validateFieldsAndReturnErrorMsgIfAny()")
        if nameField.text == nil || nameField.text!.isEmpty{
            return Strings.enter_group_name
        }else if groupDescriptionField.text == nil || groupDescriptionField.text!.isEmpty{
            return Strings.enter_description
       }
    
        return nil
    }
    
    func displayEmailUnverifiedDialogue(){
        modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as! ModelLessDialogue
        modelLessDialogue?.initializeViews(message: Strings.required_verification, actionText: Strings.verify_now)
        modelLessDialogue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToProfile(_:))))
        modelLessDialogue?.isUserInteractionEnabled = true
        modelLessDialogue?.frame = CGRect(x: 5, y: self.view.frame.size.height/2, width: self.view.frame.width - 10, height: 80)
        self.view.addSubview(modelLessDialogue!)
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            self.removeModelLessDialogue()
        }
    }
    
    func removeModelLessDialogue() {
        if modelLessDialogue != nil {
            modelLessDialogue?.removeFromSuperview()
        }
    }
    
    @objc private func moveToProfile(_ recognizer: UITapGestureRecognizer) {
        removeModelLessDialogue()
        let vc = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }
  
    func textFieldDidBeginEditing(_ textField: UITextField) {
      if textField == groupDescriptionField{
            ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 220))
        }
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       
        ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 0))
         textField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var threshold : Int?
        if textField == nameField{
            threshold = 100
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
    



    func checkAndPlaceCursorPosition()
    {
        if (self.nameField.text == nil || self.nameField.text?.isEmpty == true)
        {
            self.nameField.becomeFirstResponder()
            ScrollViewUtils.scrollToPoint(scrollView: scrollView, point: CGPoint(x: 0, y: 170))
            
        } else if (self.groupDescriptionField.text == nil || self.groupDescriptionField.text?.isEmpty == true)
        {
            self.groupDescriptionField.becomeFirstResponder()
            
        }
    }
    
    @IBAction func currentLocationBtnTapped(_ sender: Any) {
       setCurrentLocation()
    }
    func setCurrentLocation(){
        let location = locationManager.location
        
        if location == nil{
            return
        }
        LocationCache.getCacheInstance().getLocationInfoForLatLng(useCase: "iOS.App.locationname.CreateUserGroupView", coordinate: location!.coordinate) { (location,error) -> Void in

            if error != nil && error == QuickRideErrors.NetworkConnectionNotAvailableError{
                UIApplication.shared.keyWindow?.makeToast( Strings.DATA_CONNECTION_NOT_AVAILABLE)
            }else if location == nil{
                UIApplication.shared.keyWindow?.makeToast( Strings.location_not_found)
            }else{
                self.location = location!
                self.locationSelectionLabel.text = location!.completeAddress
                self.locationSelectionLabel.textColor = Colors.locationTextColor
                self.locationSelectionLabel.font = self.locationSelectionLabel.font.withSize(15)
            }
        }
    }
    
   
 
}
extension CreateGroupViewController: UIImagePickerControllerDelegate{
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
            self.isPicChanged = isUpdated
            self.isRemoveOptionApplicableForPic = true
            self.groupImageView.image = ImageUtils.RBResizeImage(image: image!, targetSize: CGSize(width: 540, height: 540))
        }
        else{
            self.isPicChanged = isUpdated
            self.createdGroup?.imageURI = nil
            self.groupImageView.image = UIImage(named: "new_group_icon")
            self.isRemoveOptionApplicableForPic = false
        }
    }
}
