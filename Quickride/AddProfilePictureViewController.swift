//
//  AddProfilePictureViewController.swift
//  Quickride
//
//  Created by Ashutos on 29/07/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import ObjectMapper

class AddProfilePictureViewController: UIViewController {
    //MARK: Outlets
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userProfilePictureImageView: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var addProfilePictureLabel: UILabel!
    @IBOutlet weak var takeAminuteLabel: UILabel!
     var showingVC = true
    //let PledgeVC = QuickridePledgeViewController()
    
    //MARK: Properties
    private var addProfilePictureViewModel = AddProfilePictureViewModel()
    
    //MARK: ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        definesPresentationContext = true
        userProfilePictureImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(editProfileImage(_:))))
        addObserver()
        continueButton.isEnabled = false
       
        let userProfile = UserDataCache.getInstance()?.userProfile
        userNameLabel.text = "Welcome\n" + (userProfile?.userName ?? "")
        defaultUserImageSelection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide the Navigation Bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //MARK: Methods
    private func addObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleApiFailureError), name: .handleApiFailureError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ProfilePictureAdded), name: Notification.Name("ProfilePictureAdded"), object: nil)
    }
    
    @objc func handleApiFailureError(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        let responseObject = notification.userInfo?["responseObject"] as? NSDictionary
        let error = notification.userInfo?["error"] as? NSError
        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
    }
    
    @objc func ProfilePictureAdded(_ notification: Notification){
        QuickRideProgressSpinner.stopSpinner()
        self.navigateToQuickRidePledgeVC()
    }
    
    @objc func editProfileImage(_ gesture : UITapGestureRecognizer){
        handleProfileImageChange()
    }
    
    func handleProfileImageChange(){
        AppDelegate.getAppDelegate().log.debug("changePhoto()")
        let uploadImageAlertController = UploadImageUtils(isRemoveOptionApplicable: false, viewController: self,delegate: self){ [weak self] (isUpdated, imageURi, image) in
            self?.receivedImage(image: image, isUpdated: isUpdated)
        }
        uploadImageAlertController.handleImageSelection()
    }
    
    @IBAction func skipButtonTap(_ sender: Any) {
        navigateToQuickRidePledgeVC()
    }
    
    @IBAction func continueButtonTap(_ sender: Any) {
        if addProfilePictureViewModel.userImage != nil{
            QuickRideProgressSpinner.startSpinner()
            addProfilePictureViewModel.checkAndSaveUserImage()
        }
    }

    func navigateToQuickRidePledgeVC(){
        SharedPreferenceHelper.storeNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_CARPOOL_ONBORDING_DETAILS, value: true)
        let pledgeDetails = addProfilePictureViewModel.getPleadgeDetails()
        let verifyVC = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyProfileViewController") as! VerifyProfileViewController
        verifyVC.intialData(isFromSignUpFlow: true)
        self.navigationController?.pushViewController(verifyVC, animated: false)
    }
    
    func defaultUserImageSelection(){
        let userProfile = UserDataCache.getInstance()?.userProfile
        if (userProfile?.gender == (User.USER_GENDER_MALE)){
            userProfilePictureImageView.image = UIImage(named: "default_male_userImage")
        }else if (userProfile?.gender == (User.USER_GENDER_FEMALE)){
            userProfilePictureImageView.image = UIImage(named: "default_female_userImage")
        }else{
            userProfilePictureImageView.image =  UIImage(named: "default_noGender_userImage")
        }
        
    }
        
}
extension AddProfilePictureViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
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
        if let newPick = image{
            self.addProfilePictureViewModel.userImage = newPick
            self.userProfilePictureImageView.image = newPick.circle!
            continueButton.backgroundColor = UIColor(netHex: 0x28AA66)
            continueButton.isEnabled = true
            addProfilePictureLabel.isHidden = true
            takeAminuteLabel.isHidden = true
            skipButton.isHidden = true
        }else{
            defaultUserImageSelection()
            continueButton.backgroundColor = UIColor(netHex: 0xAAAAAA)
            continueButton.isEnabled = false
            self.addProfilePictureViewModel.userImage = nil
        }
    }
}
