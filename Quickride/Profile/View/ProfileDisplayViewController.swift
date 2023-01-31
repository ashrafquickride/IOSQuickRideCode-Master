//
//  ProfileDisplayViewController.swift
//  Quickride
//
//  Created by Admin on 06/02/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import CoreLocation
import UIKit
import MessageUI

@objc protocol UserSelectedDelegate{
    @objc optional func userSelected()
    @objc optional func userNotSelected()
}

class ProfileDisplayViewController : UIViewController,UITableViewDelegate,UITableViewDataSource, ReceiveLocationDelegate,UITextFieldDelegate, UserBlockReceiver, UserUnBlockReceiver, UserEmailVerificationReceiver, MFMailComposeViewControllerDelegate,UIScrollViewDelegate,AddFavPartnerReceiver, VehicleUpdateDelegate{

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var profileImage: UIImageView!

    @IBOutlet weak var editButton: UIButton!

    @IBOutlet weak var userNamelbl: UILabel!

    @IBOutlet weak var userProfessionLblHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var userProfessionLbl: UILabel!

    @IBOutlet weak var verificationStatusLbl: UILabel!

    @IBOutlet weak var verificationBadge: UIImageView!

    @IBOutlet weak var totalRidesLbl: UILabel!

    @IBOutlet weak var noOfRidesAsRiderView: UIView!

    @IBOutlet weak var noofRidesAsPassengerView: UIView!

    @IBOutlet weak var noOfRidesAsRiderLbl: UILabel!

    @IBOutlet weak var noOfRidesAsPassengerLbl: UILabel!

    @IBOutlet weak var callBtn: UIButton!

    @IBOutlet weak var chatBtn: UIButton!

    @IBOutlet weak var unverifiedView: UIView!

    @IBOutlet weak var verificationPendingLabel: UILabel!
    
    @IBOutlet weak var verificationPendingDescLabel: UILabel!

    @IBOutlet weak var unVerifiedViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var unVerifiedViewTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var ratingsView: UIView!

    @IBOutlet weak var ratingsLbl: UILabel!

    @IBOutlet weak var noOfReviewsLbl: UILabel!

    @IBOutlet weak var onTimePercentageOrNoOfSeatLbl: UILabel!

    @IBOutlet weak var rideNotesView: UIView!

    @IBOutlet weak var rideNotesLbl: UILabel!

    @IBOutlet weak var rideNotesViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var vehicleView: UIView!

    @IBOutlet weak var vehicleTableView: UITableView!

    @IBOutlet weak var addFavouriiteView: UIView!

    @IBOutlet weak var addFavViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addLocationView: UIView!

    @IBOutlet weak var myAccountView: UIView!

    @IBOutlet weak var addedLocationsTitleLbl: UILabel!

    @IBOutlet weak var homeView: UIView!

    @IBOutlet weak var homeViewConstraint: NSLayoutConstraint!

    @IBOutlet weak var homeViewTopSpaceConsttraint: NSLayoutConstraint!

    @IBOutlet weak var officeView: UIView!

    @IBOutlet weak var officeViewConstraint: NSLayoutConstraint!

    @IBOutlet weak var officeViewTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var actionView: UIView!

    @IBOutlet weak var ecoMeterView: UIView!

    @IBOutlet weak var rateAUserView: UIView!

    @IBOutlet weak var rateAUserLbl: UILabel!

    @IBOutlet weak var reportProfileView: UIView!

    @IBOutlet weak var blockAUserView: UIView!

    @IBOutlet weak var blockUserLbl: UILabel!

    @IBOutlet weak var setHomeLocationLbl: UIButton!

    @IBOutlet weak var setOfficeLocationLbl: UIButton!

    @IBOutlet weak var setHomeLocationWidthConstraints: NSLayoutConstraint!

    @IBOutlet weak var myAccountViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var actionViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addedLocationTitleLblHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addedLocationTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var addLocationViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addLocationViewTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var vehicleViewTitle: UILabel!

    @IBOutlet weak var vehicleViewTitleHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var vehicleViewTitleBottomSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var vehicleTableViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var vehicleViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var onTimeTxtLbl: UILabel!

    @IBOutlet weak var homeLocationLbl: UILabel!

    @IBOutlet weak var officeLocationLbl: UILabel!

    @IBOutlet weak var addFavViewTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var addVehicleBtn: UIButton!

    @IBOutlet weak var addVehicleBtnHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var dataView: UIView!

    @IBOutlet weak var setOfficeLocationLeadingSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var homeLocationIcon: UIImageView!

    @IBOutlet weak var officeLocationIcon: UIImageView!

    @IBOutlet weak var myAccountViewTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var setOfficeLocationWidthConstraint: NSLayoutConstraint!

    @IBOutlet weak var addVehicleHieghtConstraint: NSLayoutConstraint!

    @IBOutlet weak var noVehicleLblHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addVehicleLblTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var noVehicleTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var addVehicleLbl: UILabel!

    @IBOutlet weak var noVehicleLbl: UILabel!

    @IBOutlet weak var addedAsFavouriteView: UIView!

    @IBOutlet weak var ratingsViewTittle: UILabel!

    @IBOutlet weak var onTimeOrSeatImageView: UIImageView!

    @IBOutlet weak var dividerView: UIView!

    @IBOutlet weak var ecoMeterForCurrentUserHieghtConstraint: NSLayoutConstraint!

    @IBOutlet weak var ecoMeterForCurrentUser: UIView!

    @IBOutlet weak var ecoMeterForCurrentUserTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var tabelViewNoOfRides: UITableView!

    @IBOutlet weak var totalRidesView: UIView!

    @IBOutlet weak var buttonDropDown: UIButton!

    @IBOutlet weak var profileImageHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var dataViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addFavText: UILabel!

    @IBOutlet weak var backBtn: UIButton!

    @IBOutlet weak var navigationView: UIView!

    @IBOutlet weak var ratingViewBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var rideNotesViewTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var totalRidesTxtLbl: UILabel!

    @IBOutlet weak var backgroundImage: UIImageView!

    @IBOutlet weak var profileImageForOldUser: UIImageView!

    @IBOutlet weak var addVehicleView: UIView!

    @IBOutlet weak var dlVerificationView: UIView!

    @IBOutlet weak var dlVerificationViewTopSpaceConstraint: NSLayoutConstraint!

    @IBOutlet weak var dlVerificationViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var birthDayView: UIView!

    @IBOutlet weak var birthDayViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var addBirthDayView: UIView!

    @IBOutlet weak var safeKeeperView: UIView!
    @IBOutlet weak var safeKeeperLabel: UILabel!
    @IBOutlet weak var safeKeeperViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var safeKeeperViewTopConstraint: NSLayoutConstraint!
    
    //MARK: HobbiesAndSkill
    @IBOutlet weak var addHobbiesAndSkillsView: UIView!
    @IBOutlet weak var hobbiesAndSkillsViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addedHobbiesAndSkillsCollectionView: UICollectionView!
    
    
     //MARK: RideEtiquette certificate
    @IBOutlet weak var rideEtiquetteCertifiedView: UIView!
    @IBOutlet weak var rideEtiquetteCertificateView: UIView!
    @IBOutlet weak var rideEtiquetteCertificateImageView: UIImageView!
    @IBOutlet weak var rideEtiquetteCertificateViewHeightConstraint: NSLayoutConstraint!

    var displayActionButton = false
    var supportCall : CommunicationType = CommunicationType.Chat
    var fullUserprofile = UserFullProfile()
    var isCurrentUserProfile = false
    var userRole : UserRole?
    var profileId : String?
    var userSelectionDelegate : UserSelectedDelegate?
    var homeLocation,officeLocation : UserFavouriteLocation?
    var userVehicles = [Vehicle]()
    var isFromRideDetailView = false
    var isFromFeedbackView = false
    var rideNotes : String?
    var verificationResponseErrorCode : Int?
    var matchedRiderOnTimeCompliance: String?
    var noOfseats : Int?
    var listOfRides = [String]()
    var isDataLoaded = false
    var isSafeKeeper = false
    var isFromQuickShare = false
    private var skillsList = [String]()
    private var hobbiesList = [String]()
    private var rideEtiquetteCertification: RideEtiquetteCertification?
    private var  modelLessDialogue: ModelLessDialogue?

    private var contactOptionsDialogue : ContactOptionsDialouge?

    let  publicDomainEmails = ["@gmail.com",
                               "@yahoo.co.in",
                               "@rocketmail.com",
                               "@aol.com",
                               "@outlook.com",
                               "@hotmail.com",
                               "@msn.com"]

    func initializeDataBeforePresentingView(profileId : String?,isRiderProfile : UserRole,rideVehicle : Vehicle?,userSelectionDelegate : UserSelectedDelegate?,displayAction : Bool, isFromRideDetailView : Bool, rideNotes : String?, matchedRiderOnTimeCompliance: String?, noOfSeats: Int?, isSafeKeeper: Bool) {
        AppDelegate.getAppDelegate().log.debug("")
        self.profileId = profileId
        self.userSelectionDelegate = userSelectionDelegate
        self.userRole = isRiderProfile
        self.displayActionButton = displayAction
        if rideVehicle != nil
        {
            self.userVehicles.append(rideVehicle!)
        }
        self.isFromRideDetailView = isFromRideDetailView
        self.rideNotes = rideNotes
        self.matchedRiderOnTimeCompliance = matchedRiderOnTimeCompliance
        self.noOfseats = noOfSeats
        self.isSafeKeeper = isSafeKeeper
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        definesPresentationContext = true
        scrollView.delegate = self
        profileImage.clipsToBounds = true
        self.tabelViewNoOfRides.isHidden = true
        totalRidesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.totalRidesViewTapped(_:))))
        setHomeLocationLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.selectHomeLocation(_:))))
        setOfficeLocationLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.selectOfficeLocation(_:))))
        ecoMeterView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.ecoMeterViewTapped(_:))))
        rateAUserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.rateUserViewTapped(_:))))
        reportProfileView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.reportProfileViewTapped(_:))))
        blockAUserView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.blockUserViewTapped(_:))))
        myAccountView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.accountViewTapped(_:))))
        unverifiedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.verifyNowViewClicked(_:))))
        ecoMeterForCurrentUser.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.ecoMeterViewTapped(_:))))
        addVehicleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.addVehicleViewTapped(_:))))
        dlVerificationView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.dlVerificationViewTapped(_:))))
        birthDayView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ProfileDisplayViewController.birthDayViewTapped(_:))))
        self.automaticallyAdjustsScrollViewInsets = false

        if profileId == nil {
            profileId = QRSessionManager.getInstance()?.getUserId()
            isCurrentUserProfile = true
        }
        else if profileId == QRSessionManager.getInstance()?.getUserId(){
            isCurrentUserProfile = true
        }else {
            isCurrentUserProfile = false

        }
        self.vehicleTableView.delegate = self
        self.vehicleTableView.dataSource = self
        tabelViewNoOfRides.delegate = self
        tabelViewNoOfRides.dataSource = self
        registerCell()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.getAppDelegate().log.debug("viewWillAppear()")
        loadProfileAndInitializeViews()
        if contactOptionsDialogue != nil{
            contactOptionsDialogue!.displayView()
        }
        self.navigationController?.isNavigationBarHidden = true
        addObserver()
    }

    override func viewDidAppear(_ animated: Bool) {
        ViewCustomizationUtils.addCornerRadiusToView(view: unverifiedView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: editButton, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: addLocationView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: myAccountView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: ecoMeterForCurrentUser, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: actionView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: ecoMeterView, cornerRadius: 8.0, corner1: .topLeft, corner2: .topRight)
        ViewCustomizationUtils.addCornerRadiusToSpecificCornersOfView(view: blockAUserView, cornerRadius: 8.0, corner1: .bottomLeft, corner2: .bottomRight)
        ViewCustomizationUtils.addCornerRadiusToView(view: addFavouriiteView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: addedAsFavouriteView, cornerRadius: 5.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: addVehicleView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: dlVerificationView, cornerRadius: 8.0)
        ViewCustomizationUtils.addCornerRadiusToView(view: birthDayView, cornerRadius: 8.0)
        setColorToEditBtnBasedOnUserProfile()
        actionView.addShadow()
        editButton.addShadow()
        myAccountView.addShadow()
        addLocationView.addShadow()
        addFavouriiteView.addShadow()
        unverifiedView.addShadow()
        ecoMeterForCurrentUser.addShadow()
        tabelViewNoOfRides.addShadow()
        addVehicleView.addShadow()
        dlVerificationView.addShadow()
        birthDayView.addShadow()
        rideEtiquetteCertificateView.addShadow()
        rideEtiquetteCertifiedView.addShadow()
        self.navigationView.addShadowWithOffset(shadowOffSet: CGSize(width: 0, height: 4))
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if !hobbiesList.isEmpty || !skillsList.isEmpty {
            let height = addedHobbiesAndSkillsCollectionView.collectionViewLayout.collectionViewContentSize.height
            hobbiesAndSkillsViewHeightConstraint.constant = height
            self.view.layoutIfNeeded()
            handleScrollViewHeight()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    private func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(moveToHobbiesAndSkillView), name: .addOrEditHobbiesAndSkillsTapped, object: nil)
    }

    private func registerCell() {
        addedHobbiesAndSkillsCollectionView.register(UINib(nibName: "HobbiesAndSkillsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "HobbiesAndSkillsCollectionViewCell")
        addedHobbiesAndSkillsCollectionView.register(UINib(nibName: "HobbiesAndSkillsHeaderCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HobbiesAndSkillsHeaderCollectionReusableView")
        addedHobbiesAndSkillsCollectionView.register(UINib(nibName: "HobbiesAndSkillsFooterCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: "HobbiesAndSkillsFooterCollectionReusableView")
    }
    func setColorToEditBtnBasedOnUserProfile(){
        if isCurrentUserProfile{
            CustomExtensionUtility.changeBtnColor(sender: self.editButton, color1: UIColor.white, color2: UIColor.white)
        }else{
            CustomExtensionUtility.changeBtnColor(sender: self.editButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == vehicleTableView{
            return
        }

        if !isDataLoaded{
            isDataLoaded = true
            return
        }

        let constant = 350
        if scrollView.contentOffset.y < 0.0 {
            return
            profileImage.alpha = 1.0
            backgroundImage.alpha = 1.0
            UIView.animate(withDuration: 0.4) {
                self.navigationView.backgroundColor = UIColor.clear
            }
             profileImageHeightConstraint?.constant = CGFloat(constant) - scrollView.contentOffset.y
        } else {
            let parallaxFactor: CGFloat = 0.50
            let offsetY = scrollView.contentOffset.y * parallaxFactor
            let minOffsetY: CGFloat = 8.0
            let availableOffset = min(offsetY, minOffsetY)
            let contentRectOffsetY = availableOffset / CGFloat(constant)

            profileImageHeightConstraint?.constant = CGFloat(constant) - scrollView.contentOffset.y
            profileImage.layer.contentsRect = CGRect(x: 0, y: -contentRectOffsetY, width: 1, height: 1)
            if profileImageHeightConstraint.constant < 350.0 && profileImageHeightConstraint.constant >= 300.0{
                UIView.animate(withDuration: 0.1) {
                    self.profileImage.alpha = CGFloat(0.7)
                    self.backgroundImage.alpha = CGFloat(0.7)
                }
            }else if profileImageHeightConstraint.constant < 300.0 && profileImageHeightConstraint.constant >= 260 {
                UIView.animate(withDuration: 0.1) {
                    self.profileImage.alpha = CGFloat(0.5)
                    self.backgroundImage.alpha = CGFloat(0.5)
                }
            }else if profileImageHeightConstraint.constant < 260.0{
                UIView.animate(withDuration: 0.1) {
                    self.profileImage.alpha = CGFloat(0.3)
                    self.backgroundImage.alpha = CGFloat(0.3)
                }
             }else{
                UIView.animate(withDuration: 0.1) {
                    self.profileImage.alpha = CGFloat(1.0)
                    self.backgroundImage.alpha = CGFloat(1.0)
                }
            }
            if profileImageHeightConstraint.constant < 215.0{
                UIView.animate(withDuration: 0.4) {
                   self.navigationView.backgroundColor = UIColor.white
                }
            }
            else{
                UIView.animate(withDuration: 0.4) {
                    self.navigationView.backgroundColor = UIColor.clear
                }
            }
        }
    }
    
    private func loadProfileAndInitializeViews() {
        AppDelegate.getAppDelegate().log.debug("loadProfileAndInitializeViews()")
        if self.isCurrentUserProfile{
            getCurrentUserInfo()
        }
        else {
            getOtherUserInfo()
        }
    }

    func getCurrentUserInfo()
    {
        if let userProfileObject = UserDataCache.getInstance()?.getUserProfile(userId: self.profileId!){
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.VIEWED_OWN_PROFILE, params: ["userId": self.profileId ?? ""], uniqueField: User.FLD_USER_ID)
            self.fullUserprofile.userProfile = userProfileObject
            self.fillProfileData()
        }else{
            self.initializeCurrentUserProfileIfRetrievalFails()
        }
    }

    func getOtherUserInfo(){
        AppDelegate.getAppDelegate().log.debug("getOtherUserInfo()")
        QuickRideProgressSpinner.startSpinner()
        UserDataCache.getInstance()?.getOtherUserCompleteProfile(userId: profileId!,completeProfileRetrievalCompletionHandler: { (otherUserInfo, error, responseObject) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.OTHER_PROFILE_VIEWED, params: ["userId": QRSessionManager.getInstance()?.getUserId() ?? "","viewed userId": self.profileId], uniqueField: User.FLD_USER_ID)
            if otherUserInfo != nil{
                self.fullUserprofile.userProfile = otherUserInfo!.userProfile!
                self.fullUserprofile.userProfile?.supportCall = otherUserInfo!.allowCallsFrom!
                self.fullUserprofile.enableChatAndCall = otherUserInfo!.enableChatAndCall
                self.fillProfileData()
            }
            else {
                self.editButton.isHidden = true
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: {(result) -> Void in
                    self.removeViewController()
                })
            }
        })
    }

    func removeViewController(){
        if self.navigationController == nil{
            self.dismiss(animated: false, completion: nil)
        }else{
            self.navigationController?.popViewController(animated: false)
        }
    }
    func initializeCurrentUserProfileIfRetrievalFails()
    {

        self.myAccountView.isHidden = false
        self.myAccountViewHeightConstraint.constant = 80
        self.actionView.isHidden = true
        self.actionViewHeightConstraint.constant = 0
        checkWhetherToDisplayCallOption()
    }

    func checkWhetherToDisplayCallOption() {

        if isCurrentUserProfile || isFromQuickShare || !RideValidationUtils.checkUserJoinedInUpCommingRide(userId: fullUserprofile.userProfile!.userId){
            callBtn.isHidden = true
            chatBtn.isHidden = true
            return
        }

        for blockedUser in  UserDataCache.getInstance()!.getAllBlockedUsers()
        {
            if(blockedUser.blockedUserId == fullUserprofile.userProfile?.userId)
            {
                callBtn.isHidden = true
                chatBtn.isHidden = true
                return
            }
        }
        if UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus == 0 && self.fullUserprofile.enableChatAndCall == false{
            callBtn.backgroundColor = UIColor(netHex: 0xcad2de)
            chatBtn.backgroundColor = UIColor(netHex: 0xcad2de)
        }
        else if userRole == UserRole.Rider || userRole == UserRole.RegularRider || userRole == UserRole.None {
            if RideManagementUtils.getUserQualifiedToDisplayContact(){
                checkCallOptionIsAvailableOrNotAndDisplay()
            }else{
                callBtn.backgroundColor = UIColor(netHex: 0xcad2de)
                chatBtn.backgroundColor = UIColor(netHex: 0xcad2de)
                modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as! ModelLessDialogue
                modelLessDialogue?.initializeViews(message: Strings.no_balance_reacharge_toast, actionText: Strings.link_caps)
                modelLessDialogue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToPayment(_:))))
                modelLessDialogue?.isUserInteractionEnabled = true
                modelLessDialogue?.frame = CGRect(x: 5, y: self.view.frame.size.height/2, width: self.view.frame.width, height: 80)
                self.view.addSubview(modelLessDialogue!)
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.removeModelLessDialogue()
                }
            }
        }else{
            checkCallOptionIsAvailableOrNotAndDisplay()
        }
    }
    
    private func removeModelLessDialogue() {
        if modelLessDialogue != nil {
            modelLessDialogue?.removeFromSuperview()
        }
    }
    
    @objc private func goToPayment(_ recognizer: UITapGestureRecognizer) {
        removeModelLessDialogue()
        let addFavoriteLocationViewController  = UIStoryboard(name : StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
        self.navigationController?.pushViewController(addFavoriteLocationViewController, animated: false)
    }

    func fillProfileData ()
    {
        AppDelegate.getAppDelegate().log.debug("fillProfileData()")
        self.supportCall = UserProfile.isCallSupportAfterJoined(callSupport: fullUserprofile.userProfile!.supportCall, enableChatAndCall: fullUserprofile.enableChatAndCall)
        if displayActionButton == false{
            editButton.isHidden = true
        }else {
            editButton.isHidden = false
            editBtnNameChanging()
        }

        userNamelbl.text = fullUserprofile.userProfile?.userName
        self.ratingsLbl.text = String(self.fullUserprofile.userProfile!.rating)
        self.noOfReviewsLbl.text = "(" + String(self.fullUserprofile.userProfile!.noOfReviews) + ")"

        let gender : String = fullUserprofile.userProfile?.gender ?? ""
        let imageURI : String? = fullUserprofile.userProfile!.imageURI

        self.profileImage.image = nil
        self.profileImageForOldUser.image = nil

        if self.fullUserprofile.userProfile!.roundedImage{
            ImageCache.getInstance().setImageToView(imageView: self.profileImageForOldUser, imageUrl: imageURI, gender: gender,imageSize: ImageCache.DIMENTION_SMALL)
        }else{
            ImageCache.getInstance().setImageToView(imageView: self.profileImage, imageUrl: imageURI, gender: gender,imageSize: ImageCache.DIMENTION_LARGE)
        }



        checkAndDisplayEmailVerification()

        noOfRidesAsPassengerLbl.text = String(describing: NSNumber(value:fullUserprofile.userProfile!.numberOfRidesAsPassenger))
        noOfRidesAsRiderLbl.text = String(describing: NSNumber(value:fullUserprofile.userProfile!.numberOfRidesAsRider))
        totalRidesLbl.text = String(describing: NSNumber(value:fullUserprofile.userProfile!.numberOfRidesAsPassenger + fullUserprofile.userProfile!.numberOfRidesAsRider))
        if listOfRides.isEmpty{
            listOfRides.append(totalRidesLbl.text!)
            listOfRides.append(noOfRidesAsRiderLbl.text!)
            listOfRides.append(noOfRidesAsPassengerLbl.text!)
        }

        initialiseHomeAndOfficeLocations()
        handleProfessionTextView()
        handleVerifiedView()
        initializeVehicleAndAdjustHeight()
        setOnTimeCompliance()
        handleEcoMeterViewVisiblity()
        handleVisibilityOfFavouriteView()
        setRideNotes()
        handleActionViewVisibility()
        handleVisibilityOfAddVehicleView()
        handleVisibilityOfRiderAndPassengerRidesView()
        checkWhetherToDisplayCallOption()
        handleMyAccountViewVisiblity()
        setPendingProfileVerificationStatus()
        handleVisibilityOfUnVerifiedView()
        handleHobbiesAndSkillsView()
        handleRideEtiquetteCertifiedView()
        handleScrollViewHeight()
    }

    private func handleRideEtiquetteCertifiedView() {
        if isCurrentUserProfile {
            if QRReachability.isConnectedToNetwork() == false || profileId == nil {
                rideEtiquetteCertificateView.isHidden = true
                rideEtiquetteCertifiedView.isHidden = true
                rideEtiquetteCertificateViewHeightConstraint.constant = 0
                return
            }
            UserDataCache.getInstance()?.getRideEtiquetteCertificate(userId: profileId!, handler: { (rideEtiquetteCertification) in
                if rideEtiquetteCertification != nil {
                    self.rideEtiquetteCertification = rideEtiquetteCertification
                    self.rideEtiquetteCertificateView.isHidden = true
                    self.rideEtiquetteCertificateViewHeightConstraint.constant = 70
                    self.rideEtiquetteCertifiedView.isHidden = false
                    self.rideEtiquetteCertifiedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showRideEtiquetteCertificationInfoToCurrentUser(_:))))
                } else {
                    self.rideEtiquetteCertifiedView.isHidden = true
                    let image = UIImage(named: "ride_etiquette_certified_icon")?.withRenderingMode(.alwaysTemplate)
                    self.rideEtiquetteCertificateImageView.image = image
                    self.rideEtiquetteCertificateImageView.tintColor = UIColor(netHex:0x00B557)
                    self.rideEtiquetteCertificateView.isHidden = false
                    self.rideEtiquetteCertificateViewHeightConstraint.constant = 165
                }
                self.view.layoutIfNeeded()
                self.handleScrollViewHeight()
            })
        } else if let userProfile = fullUserprofile.userProfile, let rideEtiquetteCertification = userProfile.rideEtiquetteCertification {
            self.rideEtiquetteCertification = rideEtiquetteCertification
            rideEtiquetteCertificateView.isHidden = true
            rideEtiquetteCertificateViewHeightConstraint.constant = 70
            rideEtiquetteCertifiedView.isHidden = false
            rideEtiquetteCertifiedView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.showRideEtiquetteCertificationInfoToOtherUser(_:))))
        } else {
            rideEtiquetteCertifiedView.isHidden = true
            rideEtiquetteCertificateView.isHidden = true
            rideEtiquetteCertificateViewHeightConstraint.constant = 0
        }
    }
    
    @objc private func showRideEtiquetteCertificationInfoToOtherUser(_ sender: UITapGestureRecognizer) {
        MessageDisplay.displayInfoViewAlert(title: Strings.ride_etiquette, titleColor: UIColor.black, message: Strings.ride_etiquette_course_info, infoImage: UIImage(named: "ride_etiquette_certified_icon"), imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil,buttonTitle: Strings.got_it_caps) {
        }
    }
    
    @objc private func showRideEtiquetteCertificationInfoToCurrentUser(_ sender: UITapGestureRecognizer) {
        guard let rideEtiquetteCertification = rideEtiquetteCertification else { return }
        let rideEtiquetteCerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideEtiquetteCerificationViewController") as! RideEtiquetteCerificationViewController
        rideEtiquetteCerificationViewController.initialiseData(userName: self.fullUserprofile.userProfile?.userName ?? "", rideEtiquetteCertification: rideEtiquetteCertification)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: rideEtiquetteCerificationViewController, animated: true)
    }
    
    private func handleHobbiesAndSkillsView() {
        if isCurrentUserProfile, let userProfile = fullUserprofile.userProfile{
            if (userProfile.interests == nil || userProfile.interests!.isEmpty) && (userProfile.skills == nil || userProfile.skills!.isEmpty) {
                hobbiesList.removeAll()
                skillsList.removeAll()
                addedHobbiesAndSkillsCollectionView.isHidden = true
                addHobbiesAndSkillsView.isHidden = false
                hobbiesAndSkillsViewHeightConstraint.constant = 150
                addHobbiesAndSkillsView.addShadow()
                addHobbiesAndSkillsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addHobbiesAndSkillsTapped(_:))))
            } else {
                addHobbiesAndSkillsView.isHidden = true
                hobbiesList.removeAll()
                skillsList.removeAll()
                if let hobbies = userProfile.interests?.split(separator: ",").map({ String($0) }) {
                    for hobby in hobbies {
                        hobbiesList.append(hobby)
                    }
                }
                if let skills = userProfile.skills?.split(separator: ",").map({ String($0) }) {
                    for skill in skills {
                        skillsList.append(skill)
                    }
                }
                if hobbiesList.isEmpty && skillsList.isEmpty {
                    addedHobbiesAndSkillsCollectionView.isHidden = true
                    hobbiesAndSkillsViewHeightConstraint.constant = 0
                } else {
                    addedHobbiesAndSkillsCollectionView.isHidden = false
                    addedHobbiesAndSkillsCollectionView.reloadData()
                }
            }
        } else {
            hobbiesList.removeAll()
            skillsList.removeAll()
            addedHobbiesAndSkillsCollectionView.isHidden = true
            addHobbiesAndSkillsView.isHidden = true
            hobbiesAndSkillsViewHeightConstraint.constant = 0
        }
    }
    
    @objc private func addHobbiesAndSkillsTapped(_ gesture : UITapGestureRecognizer) {
        moveToHobbiesAndSkillView()
    }

    @objc private func moveToHobbiesAndSkillView() {
        let hobbiesAndSkillsViewController = UIStoryboard(name: StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "HobbiesAndSkillsViewController") as! HobbiesAndSkillsViewController
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: hobbiesAndSkillsViewController, animated: true)
    }
    
    private func handleSafeKeeperView() {
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil {
            clientConfiguration = ClientConfigurtion()
        }
        if clientConfiguration!.showCovid19SelfAssessment ?? false && isSafeKeeper {
            safeKeeperView.isHidden = false
            safeKeeperViewHeightConstraint.constant = 115
            safeKeeperViewTopConstraint.constant = 25
            let message = String(format: Strings.user_confirmed_safe_keeper_precautions, arguments: [(fullUserprofile.userProfile?.userName ?? "")])
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            paragraphStyle.lineHeightMultiple = 1.3
            let attributedString1 = NSMutableAttributedString(string: message)
            attributedString1.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString1.length))
            safeKeeperLabel.attributedText = attributedString1
            safeKeeperView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(safeKeeperViewTapped(_:))))
        } else {
            safeKeeperView.isHidden = true
            safeKeeperViewHeightConstraint.constant = 0
            safeKeeperViewTopConstraint.constant = 0
        }
    }

    func handleVisibilityOfAddVehicleView(){
        if isCurrentUserProfile{
            if userVehicles.count > 0{
                addVehicleBtn.isHidden = false
                addVehicleView.isHidden = true
            }else{
                addVehicleBtn.isHidden = true
                addVehicleView.isHidden = false
                if !dlVerificationView.isHidden || !addedLocationsTitleLbl.isHidden{
                    dlVerificationViewTopSpaceConstraint.constant = 60
                    myAccountViewTopSpaceConstraint.constant += 50
                }
                else if !addLocationView.isHidden{
                    if addedLocationsTitleLbl.isHidden{
                        addLocationViewTopSpaceConstraint.constant = 70
                        myAccountViewTopSpaceConstraint.constant += 40
                    }
                    else{
                      addLocationViewTopSpaceConstraint.constant = 130
                    }
                }
            }
            addVehicleBtnHeightConstraint.constant = 30

        }else{
            addVehicleBtn.isHidden = true
            addVehicleBtnHeightConstraint.constant = 0
            addVehicleView.isHidden = true
        }
    }

    func handleVisibilityOfFavouriteView(){
        if isCurrentUserProfile{
            addFavouriiteView.isHidden = true
            addFavViewHeightConstraint.constant = 0
            addFavViewTopSpaceConstraint.constant = 0
            addedAsFavouriteView.isHidden = true
        }else{
            if UserDataCache.getInstance()!.isFavouritePartner(userId: Double(profileId!)!){
                addFavouriiteView.isHidden = true
                addFavViewHeightConstraint.constant = 0
                addFavViewTopSpaceConstraint.constant = 0
                ratingViewBottomConstraint.constant = 0
                addedAsFavouriteView.isHidden = false
            }else{
                addFavouriiteView.isHidden = false
                addFavText.text = String(format: Strings.add_fav_text , arguments: [(fullUserprofile.userProfile?.userName ?? "")])
                ratingViewBottomConstraint.constant = 0
                addFavViewHeightConstraint.constant = 110
                addFavViewTopSpaceConstraint.constant = 20
                addedAsFavouriteView.isHidden = true
            }
        }
    }
    func handleVisibilityOfRiderAndPassengerRidesView(){
        if isCurrentUserProfile{
            noofRidesAsPassengerView.isHidden = false
            noOfRidesAsRiderView.isHidden = false
            buttonDropDown.isHidden = true
        }else{
            buttonDropDown.isHidden = false
            noofRidesAsPassengerView.isHidden = true
            noOfRidesAsRiderView.isHidden = true
        }
    }

    func setOnTimeCompliance(){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if isCurrentUserProfile {
            if self.fullUserprofile.userProfile != nil &&  self.fullUserprofile.userProfile!.onTimeComplianceRating != 0 && Int(fullUserprofile.userProfile!.numberOfRidesAsRider) >= clientConfiguration.totalNoOfRiderRideSharedToShowOnTimeCompliance{
                self.onTimeTxtLbl.isHidden = false
                self.onTimePercentageOrNoOfSeatLbl.text = String(self.fullUserprofile.userProfile!.onTimeComplianceRating) + Strings.percentage_symbol
            }else{
                self.onTimePercentageOrNoOfSeatLbl.text = Strings.NA
                self.onTimeTxtLbl.isHidden = false
            }
        }else if userRole == UserRole.Rider || userRole == UserRole.RegularRider {
            if self.matchedRiderOnTimeCompliance != nil &&  self.fullUserprofile.userProfile != nil && Int(fullUserprofile.userProfile!.numberOfRidesAsRider) >= clientConfiguration.totalNoOfRiderRideSharedToShowOnTimeCompliance{
                self.onTimeTxtLbl.isHidden = false
                self.onTimePercentageOrNoOfSeatLbl.text = self.matchedRiderOnTimeCompliance! + Strings.percentage_symbol
            }else{
                onTimeOrSeatImageView.isHidden = false
                onTimePercentageOrNoOfSeatLbl.isHidden = false
                onTimeTxtLbl.isHidden = false
                self.onTimePercentageOrNoOfSeatLbl.text = Strings.NA
            }
        }else if userRole == UserRole.Passenger || userRole == UserRole.RegularPassenger{
            if self.noOfseats != nil{
                self.ratingsViewTittle.text = Strings.ratings_seats
                self.onTimeTxtLbl.isHidden = false
                self.onTimeOrSeatImageView.isHidden = false
                self.onTimeOrSeatImageView.image = UIImage(named: "seats")
                self.onTimeTxtLbl.text = Strings.seats
                self.onTimePercentageOrNoOfSeatLbl.text = String(self.noOfseats!)
            }else{
                self.onTimeOrSeatImageView.isHidden = false
                self.onTimeOrSeatImageView.image = UIImage(named: "seats")
                self.ratingsViewTittle.text = Strings.ratings_seats
                self.onTimeTxtLbl.isHidden = false
                self.onTimePercentageOrNoOfSeatLbl.text = Strings.NA
                self.onTimeTxtLbl.text = Strings.seats
            }
        }else if UserDataCache.getInstance()!.isFavouritePartner(userId: Double(profileId!)!){
            ratingsViewTittle.text = Strings.ratings_cap
            onTimeOrSeatImageView.isHidden = true
            onTimePercentageOrNoOfSeatLbl.isHidden = true
            onTimeTxtLbl.isHidden = true
            dividerView.isHidden = true
        }else{
            ratingsViewTittle.text = Strings.ratings_cap
            onTimeOrSeatImageView.isHidden = true
            onTimePercentageOrNoOfSeatLbl.isHidden = true
            onTimeTxtLbl.isHidden = true
            dividerView.isHidden = true
        }
    }
    func editBtnNameChanging(){
        if isCurrentUserProfile{
            editButton.setTitle(Strings.edit, for: .normal)
            editButton.setTitleColor(UIColor.black, for: .normal)
            editButton.setTitleColor(UIColor.black, for: .normal)
        }else if userSelectionDelegate != nil {
            if userRole == UserRole.Rider || userRole == UserRole.RegularRider {
                editButton.setTitle(Strings.join, for: .normal)
                editButton.setTitleColor(UIColor.white, for: .normal)
                editButton.setTitleColor(UIColor.white, for: .normal)
            }else if userRole == UserRole.Passenger || userRole == UserRole.RegularPassenger{
                editButton.setTitle(Strings.invite, for: .normal)
                editButton.setTitleColor(UIColor.white, for: .normal)
                editButton.setTitleColor(UIColor.white, for: .normal)
            }
        } else {
            editButton.isHidden = true
        }
    }

    func handleScrollViewHeight(){

        if isCurrentUserProfile{
            setHeightToCurrentUserProfile()
        }else if UserDataCache.getInstance()!.isFavouritePartner(userId: Double(profileId!)!){
            if (userRole == UserRole.Rider || userRole == UserRole.RegularRider){
                dataViewHeightConstraint.constant = 650 + rideNotesViewHeightConstraint.constant + rideNotesViewTopSpaceConstraint.constant + vehicleViewHeightConstraint.constant + safeKeeperViewHeightConstraint.constant + safeKeeperViewTopConstraint.constant
                dataViewHeightConstraint.constant += rideEtiquetteCertificateViewHeightConstraint.constant
            }else{
                dataViewHeightConstraint.constant = 650 + rideNotesViewHeightConstraint.constant + rideNotesViewTopSpaceConstraint.constant + safeKeeperViewHeightConstraint.constant + safeKeeperViewTopConstraint.constant + rideEtiquetteCertificateViewHeightConstraint.constant
            }
        }else{
            if (userRole == UserRole.Rider || userRole == UserRole.RegularRider){
                dataViewHeightConstraint.constant = 730 + addFavViewHeightConstraint.constant + rideNotesViewHeightConstraint.constant + addFavViewTopSpaceConstraint.constant + rideNotesViewTopSpaceConstraint.constant + vehicleViewHeightConstraint.constant
                dataViewHeightConstraint.constant += safeKeeperViewHeightConstraint.constant + safeKeeperViewTopConstraint.constant + rideEtiquetteCertificateViewHeightConstraint.constant
            }else{
                dataViewHeightConstraint.constant = 730 + addFavViewHeightConstraint.constant + rideNotesViewHeightConstraint.constant + addFavViewTopSpaceConstraint.constant + rideNotesViewTopSpaceConstraint.constant
                dataViewHeightConstraint.constant += safeKeeperViewHeightConstraint.constant + safeKeeperViewTopConstraint.constant + rideEtiquetteCertificateViewHeightConstraint.constant
            }
        }
    }

    func setHeightToCurrentUserProfile(){

        let unverifiedViewHeight = unVerifiedViewHeightConstraint.constant + unVerifiedViewTopSpaceConstraint.constant

        let vehicleViewHeight = vehicleViewHeightConstraint.constant + addVehicleHieghtConstraint.constant + addVehicleBtnHeightConstraint.constant

        let homeAndOfficeViewHeight = homeViewConstraint.constant + homeViewTopSpaceConsttraint.constant + officeViewConstraint.constant + officeViewTopSpaceConstraint.constant

        let contentHeight1 = homeAndOfficeViewHeight+unverifiedViewHeight+vehicleViewHeight + addLocationViewHeightConstraint.constant + birthDayViewHeightConstraint.constant + hobbiesAndSkillsViewHeightConstraint.constant + rideEtiquetteCertificateViewHeightConstraint.constant
        let contentHeight2 = addedLocationTopSpaceConstraint.constant+addedLocationTitleLblHeightConstraint.constant

        if  !addLocationView.isHidden && ((!homeView.isHidden && officeView.isHidden) || (!officeView.isHidden && homeView.isHidden)){
             dataViewHeightConstraint.constant = 820 + contentHeight1 + contentHeight2
        }else{
             dataViewHeightConstraint.constant = 900 + contentHeight1 + contentHeight2
        }
        scrollView.contentSize = CGSize(width: self.view.bounds.size.width, height: dataViewHeightConstraint.constant + profileImageHeightConstraint.constant)
        self.view.layoutIfNeeded()
    }

    func handleVerifiedView(){

        verificationBadge.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: fullUserprofile.userProfile!.profileVerificationData)

        verificationStatusLbl.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: fullUserprofile.userProfile!.profileVerificationData, companyName: nil)

        if verificationStatusLbl.text == Strings.not_verified{
            verificationStatusLbl.textColor = UIColor.black
        }else{
            verificationStatusLbl.textColor = UIColor(netHex: 0x24A647)
        }
        if verificationStatusLbl.text!.contains(Strings.endorsed_by_users) && !isCurrentUserProfile {
            verificationStatusLbl.isUserInteractionEnabled = true
            verificationStatusLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(verificationStatusLabelTapped(_:))))
        }
    }
    
    @objc private func verificationStatusLabelTapped(_ gesture : UITapGestureRecognizer) {
        displayEndorseUsers()
    }
    
    private func displayEndorseUsers() {
        UserDataCache.getInstance()?.getEndorsementVerificationInfo(userId: profileId ?? "0", handler: { (endorsementVerificationInfo) in
            if !endorsementVerificationInfo.isEmpty {
                let endorsedUsersListViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EndorsedUsersListViewController") as! EndorsedUsersListViewController
                endorsedUsersListViewController.initialiseData(endorsedUserInfo: endorsementVerificationInfo)
                ViewControllerUtils.addSubView(viewControllerToDisplay: endorsedUsersListViewController)
            }
        })
    }

    private func setPendingProfileVerificationStatus() {
        let profileVerificationData = fullUserprofile.userProfile!.profileVerificationData
        verificationPendingDescLabel.text = Strings.verify_now
        verificationPendingDescLabel.font = UIFont(name: "HelveticaNeue", size: 16)
        if profileVerificationData == nil {
            verificationPendingLabel.text = Strings.profile_verification_pending
        } else if profileVerificationData!.profileVerified && profileVerificationData!.emailVerified && (profileVerificationData!.persIDVerified && !profileVerificationData!.isVerifiedOnlyFromEndorsement()) {
            verificationPendingLabel.text = "Verified"
        } else if !profileVerificationData!.profileVerified && profileVerificationData!.emailVerified && (profileVerificationData!.persIDVerified && !profileVerificationData!.isVerifiedOnlyFromEndorsement()) {
            verificationPendingLabel.text = Strings.image_verification_pending
        } else if !profileVerificationData!.emailVerified {
            if profileVerificationData?.emailVerificationStatus == ProfileVerificationData.INITIATED{
                verificationPendingLabel.text = Strings.org_verifucation_in_process
                verificationPendingDescLabel.text = Strings.refer_colleagues
                verificationPendingDescLabel.font = UIFont(name: "HelveticaNeue", size: 12)
            }else if profileVerificationData?.emailVerificationStatus == ProfileVerificationData.REJECTED{
                verificationPendingLabel.text = Strings.org_verification_on_rejected
                verificationPendingDescLabel.text = Strings.refer_colleagues
                verificationPendingDescLabel.font = UIFont(name: "HelveticaNeue", size: 12)
            }else{
                verificationPendingLabel.text = Strings.org_id_verification_pending
            }
        } else if !profileVerificationData!.persIDVerified || (profileVerificationData!.persIDVerified && profileVerificationData!.isVerifiedOnlyFromEndorsement()) {
            verificationPendingLabel.text = Strings.govt_id_verification_pending
        }
    }
    func handleVisibilityOfUnVerifiedView() {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if !isCurrentUserProfile || fullUserprofile.userProfile!.profileVerificationData == nil {
            unverifiedView.isHidden = true
            unVerifiedViewHeightConstraint.constant = 0
            unVerifiedViewTopSpaceConstraint.constant = 0
            handleSafeKeeperView()
        } else if let profileVerificationData = fullUserprofile.userProfile!.profileVerificationData, isCurrentUserProfile, profileVerificationData.profileVerified, profileVerificationData.emailVerified, (profileVerificationData.persIDVerified && !profileVerificationData.isVerifiedOnlyFromEndorsement()), (clientConfiguration.disableImageVerification && profileVerificationData.imageVerified) {
            unverifiedView.isHidden = true
            unVerifiedViewHeightConstraint.constant = 0
            unVerifiedViewTopSpaceConstraint.constant = 0
            handleSafeKeeperView()
        } else {
            setPendingProfileVerificationStatus()
            unverifiedView.isHidden = false
            unVerifiedViewHeightConstraint.constant = 90
            unVerifiedViewTopSpaceConstraint.constant = 25
            safeKeeperView.isHidden = true
            safeKeeperViewHeightConstraint.constant = 0
            safeKeeperViewTopConstraint.constant = 0
        }
    }

    func initializeVehicleAndAdjustHeight()
    {
        if  isCurrentUserProfile == true{

            self.userVehicles = UserDataCache.getInstance()!.getAllCurrentUserVehicles()
        }
        handleVisibilityOfVehicleDetailsBtn()
    }
    func adjustHeightOfTableView()
    {
         if self.userVehicles.count > 0
            {
                self.vehicleView.isHidden = false
                self.vehicleViewTitleHeightConstraint.constant = 21
                self.vehicleViewTitleBottomSpaceConstraint.constant = 10
                self.vehicleTableViewHeightConstraint.constant = CGFloat(self.userVehicles.count * 40) + 50
                if isCurrentUserProfile{
                  self.vehicleViewHeightConstraint.constant = self.vehicleTableViewHeightConstraint.constant + 40
                }else{
                  self.vehicleViewHeightConstraint.constant = self.vehicleTableViewHeightConstraint.constant
                }
                self.addVehicleLbl.isHidden = true
                self.noVehicleLbl.isHidden = true
                self.addVehicleHieghtConstraint.constant = 0
                self.noVehicleTopSpaceConstraint.constant = 0
                self.noVehicleLblHeightConstraint.constant = 0

         }else if (userRole == UserRole.Rider || userRole == UserRole.RegularRider) && !userVehicles.isEmpty{

                self.vehicleView.isHidden = true
                self.vehicleViewTitleHeightConstraint.constant = 0
                self.vehicleViewTitleBottomSpaceConstraint.constant = 0
                self.vehicleTableViewHeightConstraint.constant = 0
                self.vehicleViewHeightConstraint.constant = self.vehicleTableViewHeightConstraint.constant
                self.addVehicleLbl.isHidden = false
                self.noVehicleLbl.isHidden = false
                self.addVehicleHieghtConstraint.constant = 20
                self.addVehicleLblTopSpaceConstraint.constant = 5
                self.noVehicleTopSpaceConstraint.constant = 10
                self.noVehicleLblHeightConstraint.constant = 20

         }else{
                self.vehicleView.isHidden = true
                self.vehicleViewTitleHeightConstraint.constant = 0
                self.vehicleViewTitleBottomSpaceConstraint.constant = 0
                self.vehicleTableViewHeightConstraint.constant = 0
                self.vehicleViewHeightConstraint.constant = 0
                self.addVehicleLbl.isHidden = true
                self.noVehicleLbl.isHidden = true
                self.addVehicleHieghtConstraint.constant = 0
                self.addVehicleLblTopSpaceConstraint.constant = 0
                self.noVehicleTopSpaceConstraint.constant = 0
                self.noVehicleLblHeightConstraint.constant = 0
            }

    }

    func setRideNotes()
    {
        if(self.rideNotes == nil || self.rideNotes!.isEmpty)
        {
            rideNotesView.isHidden = true
            rideNotesViewTopSpaceConstraint.constant = 0
            rideNotesViewHeightConstraint.constant = 0
            return
        }
        rideNotesView.isHidden = false
        rideNotesLbl.text = self.rideNotes!
        rideNotesViewTopSpaceConstraint.constant = 20
        rideNotesViewHeightConstraint.constant = 100
    }

    func handleProfessionTextView(){
        var professionText :String = ""
        if fullUserprofile.userProfile!.profession != nil && fullUserprofile.userProfile!.profession!.isEmpty == false{
            professionText = professionText+fullUserprofile.userProfile!.profession!
        }
        if fullUserprofile.userProfile!.companyName != nil && fullUserprofile.userProfile!.companyName!.isEmpty == false {
            if professionText.isEmpty == false{
                professionText = "\(professionText) \(Strings.at) \(fullUserprofile.userProfile!.companyName!)"
            }else{
                professionText = "\(Strings.works_at) \(fullUserprofile.userProfile!.companyName!)"
            }
        }
        if professionText.isEmpty == true{
            userProfessionLbl.isHidden = true
            userProfessionLblHeightConstraint.constant = 0
        }else{
            userProfessionLbl.isHidden = false
            userProfessionLbl.text = professionText
            userProfessionLblHeightConstraint.constant = 25
        }
    }
    func initialiseHomeAndOfficeLocations()
    {
        AppDelegate.getAppDelegate().log.debug("initialiseHomeAndOfficeLocations()")
        if isCurrentUserProfile == false{
            homeView.isHidden = true
            officeView.isHidden = true
            homeViewConstraint.constant = 0
            officeViewConstraint.constant = 0
            homeViewTopSpaceConsttraint.constant = 0
            officeViewTopSpaceConstraint.constant = 0
            addedLocationsTitleLbl.isHidden = true
            addedLocationTitleLblHeightConstraint.constant = 0
            addedLocationTopSpaceConstraint.constant = 0
            addLocationView.isHidden = true
            addLocationViewHeightConstraint.constant = 0
            addLocationViewTopSpaceConstraint.constant = 0
            setHomeLocationWidthConstraints.constant = 0
            setOfficeLocationLeadingSpaceConstraint.constant = 0
            dlVerificationView.isHidden = true
            dlVerificationViewTopSpaceConstraint.constant = 0
            dlVerificationViewHeightConstraint.constant = 0
            birthDayView.isHidden = true
            birthDayViewHeightConstraint.constant = 0
        }else{
            let favLocations = UserDataCache.getInstance()?.getFavoriteLocations()
            self.homeLocation = nil
            self.officeLocation = nil
            if  favLocations != nil && !favLocations!.isEmpty{
                checkForHomeAndOfficeLocationVisibility(favLocations: favLocations!)
            }else{
                homeView.isHidden = true
                officeView.isHidden = true
                homeViewConstraint.constant = 0
                officeViewConstraint.constant = 0
                homeViewTopSpaceConsttraint.constant = 10
                officeViewTopSpaceConstraint.constant = 0
                addedLocationsTitleLbl.isHidden = true
                addedLocationTitleLblHeightConstraint.constant = 0
                addedLocationTopSpaceConstraint.constant = 0
                addLocationView.isHidden = false
                addLocationViewHeightConstraint.constant = 130
                addLocationViewTopSpaceConstraint.constant = 20
                setHomeLocationWidthConstraints.constant = 120
                setOfficeLocationLeadingSpaceConstraint.constant = 10
                myAccountViewTopSpaceConstraint.constant = 290
                setOfficeLocationWidthConstraint.constant = 120
            }
          handleVisibilityOfDLVerificationView()
          handleVisibilityOfBirthDayView()
        }
    }

    func handleVisibilityOfBirthDayView(){
        if fullUserprofile.userProfile?.dateOfBirth != nil{
            birthDayView.isHidden = true
            addBirthDayView.isHidden = true
            birthDayViewHeightConstraint.constant = 0
        }else{
            birthDayView.isHidden = false
            addBirthDayView.isHidden = false
            birthDayViewHeightConstraint.constant = 120
        }
    }

    func handleActionViewVisibility(){
        if isCurrentUserProfile{
            actionView.isHidden = true
            actionViewHeightConstraint.constant = 0
        }else{
            actionView.isHidden = false
            actionViewHeightConstraint.constant = 200
            initializeBlockUserLbl()
            initializeRateAUserView()
        }
    }

    func initializeBlockUserLbl()
    {
        let blockedUserList  = UserDataCache.getInstance()!.getAllBlockedUsers()

        var isUserBlocked = false
        for blockedUser in blockedUserList
        {
            if(blockedUser.blockedUserId == self.fullUserprofile.userProfile?.userId)
            {
                isUserBlocked = true
            }
        }
        if(isUserBlocked)
        {
            blockUserLbl.text = Strings.unblock + " " + (fullUserprofile.userProfile?.userName ?? "")
        }
        else
        {
            blockUserLbl.text = Strings.block + " " + (fullUserprofile.userProfile?.userName ?? "")
        }

    }

    func initializeRateAUserView(){
        rateAUserLbl.text = "Rate " + (fullUserprofile.userProfile?.userName ?? "")
    }

    func checkForHomeAndOfficeLocationVisibility(favLocations :[UserFavouriteLocation]){
        AppDelegate.getAppDelegate().log.debug("checkForHomeAndOfficeLocationVisibility()")
        for favLocation in favLocations{
            if UserFavouriteLocation.HOME_FAVOURITE.caseInsensitiveCompare(favLocation.name!) == ComparisonResult.orderedSame{

                self.homeLocation = favLocation
            }else if UserFavouriteLocation.OFFICE_FAVOURITE.caseInsensitiveCompare(favLocation.name!) == ComparisonResult.orderedSame{
                self.officeLocation = favLocation
            }
        }
        checkAndHandleLocationViewVisibility()
    }

    func checkAndHandleLocationViewVisibility(){
        if homeLocation != nil && officeLocation != nil{
            homeLocationLbl.text = homeLocation!.address
            officeLocationLbl.text = officeLocation!.address
            homeLocationIcon.image = UIImage(named: "home_small")
            officeLocationIcon.image = UIImage(named : "briefcase_small")
            homeView.isHidden = false
            officeView.isHidden = false
            homeViewConstraint.constant = 50
            officeViewConstraint.constant = 50
            homeViewTopSpaceConsttraint.constant = 40
            officeViewTopSpaceConstraint.constant = 20
            addedLocationsTitleLbl.isHidden = false
            addedLocationTitleLblHeightConstraint.constant = 20
            addedLocationTopSpaceConstraint.constant = 15
            addLocationView.isHidden = true
            addLocationViewHeightConstraint.constant = 0
            addLocationViewTopSpaceConstraint.constant = 0
            setHomeLocationWidthConstraints.constant = 0
            setOfficeLocationLeadingSpaceConstraint.constant = 0
            setOfficeLocationWidthConstraint.constant = 0
            myAccountViewTopSpaceConstraint.constant = 290
        }else if homeLocation != nil{
            homeLocationLbl.text = homeLocation!.address
            homeLocationIcon.image = UIImage(named: "home_small")
            homeView.isHidden = false
            officeView.isHidden = true
            homeViewConstraint.constant = 50
            officeViewConstraint.constant = 0
            homeViewTopSpaceConsttraint.constant = 40
            officeViewTopSpaceConstraint.constant = 0
            addedLocationsTitleLbl.isHidden = false
            addedLocationTitleLblHeightConstraint.constant = 20
            addedLocationTopSpaceConstraint.constant = 15
            addLocationView.isHidden = false
            addLocationViewHeightConstraint.constant = 130
            addLocationViewTopSpaceConstraint.constant = 110
            setHomeLocationWidthConstraints.constant = 0
            setOfficeLocationLeadingSpaceConstraint.constant = 0
            setOfficeLocationWidthConstraint.constant = 120
            myAccountViewTopSpaceConstraint.constant = 370
        }else if officeLocation != nil{
            officeLocationLbl.text = officeLocation!.address
            officeLocationIcon.image = UIImage(named : "briefcase_small")
            homeView.isHidden = true
            officeView.isHidden = false
            homeViewConstraint.constant = 0
            officeViewConstraint.constant = 50
            homeViewTopSpaceConsttraint.constant = 0
            officeViewTopSpaceConstraint.constant = 40
            addedLocationsTitleLbl.isHidden = false
            addedLocationTitleLblHeightConstraint.constant = 20
            addedLocationTopSpaceConstraint.constant = 15
            addLocationView.isHidden = false
            addLocationViewHeightConstraint.constant = 130
            addLocationViewTopSpaceConstraint.constant = 110
            setHomeLocationWidthConstraints.constant = 120
            setOfficeLocationLeadingSpaceConstraint.constant = 0
            setOfficeLocationWidthConstraint.constant = 0
            myAccountViewTopSpaceConstraint.constant = 370
        }else{
            homeView.isHidden = true
            officeView.isHidden = true
            homeViewConstraint.constant = 0
            officeViewConstraint.constant = 0
            homeViewTopSpaceConsttraint.constant = 0
            officeViewTopSpaceConstraint.constant = 0
            addedLocationsTitleLbl.isHidden = true
            addedLocationTitleLblHeightConstraint.constant = 0
            addedLocationTopSpaceConstraint.constant = 0
            addLocationView.isHidden = false
            addLocationViewHeightConstraint.constant = 130
            addLocationViewTopSpaceConstraint.constant = 20
            setHomeLocationWidthConstraints.constant = 120
            setOfficeLocationLeadingSpaceConstraint.constant = 10
            setOfficeLocationWidthConstraint.constant = 120
            myAccountViewTopSpaceConstraint.constant = 250
        }
    }

    func checkAndDisplayEmailVerification(){
        if(self.fullUserprofile.userProfile!.verificationStatus == 0 && isCurrentUserProfile == true){
            setPendingProfileVerificationStatus()
            unverifiedView.isHidden = false
            unVerifiedViewHeightConstraint.constant = 90
            unVerifiedViewTopSpaceConstraint.constant = 25
        }
    }
    func checkWhetherItIsOfficialEmailId( givenEmailId : String?) -> Bool {
        AppDelegate.getAppDelegate().log.debug( "checking if official email is given, in profileEditActivity")
        for emailDomain in publicDomainEmails{
            if givenEmailId!.contains(emailDomain)
            {
                return false
            }
        }
        return true
    }

    func handleMyAccountViewVisiblity(){
        if isCurrentUserProfile{
            myAccountViewHeightConstraint.constant = 80
            myAccountView.isHidden = false
        }else{
            myAccountViewHeightConstraint.constant = 0
            myAccountView.isHidden = true
        }
    }
    func handleVisibilityOfVehicleDetailsBtn(){
            vehicleViewHeightConstraint.constant = 0
            self.vehicleTableView.reloadData()
            adjustHeightOfTableView()
    }

    func handleVisibilityOfDLVerificationView(){

        let profileVerificationData = self.fullUserprofile.userProfile?.profileVerificationData
        if profileVerificationData != nil && (profileVerificationData!.persVerifSource == nil || !profileVerificationData!.persVerifSource!.contains(PersonalIdDetail.DL)){
            dlVerificationView.isHidden = false
            dlVerificationViewTopSpaceConstraint.constant = 15
            dlVerificationViewHeightConstraint.constant = 90
        }else{
            dlVerificationView.isHidden = true
            dlVerificationViewTopSpaceConstraint.constant = 0
            dlVerificationViewHeightConstraint.constant = 0
            myAccountViewTopSpaceConstraint.constant = myAccountViewTopSpaceConstraint.constant - 90
        }
    }
    func handleEcoMeterViewVisiblity(){
        if isCurrentUserProfile{
            ecoMeterForCurrentUserHieghtConstraint.constant = 100
            ecoMeterForCurrentUserTopSpaceConstraint.constant = 30
            ecoMeterForCurrentUser.isHidden = false

        }else{
            ecoMeterForCurrentUserHieghtConstraint.constant = 0
            ecoMeterForCurrentUserTopSpaceConstraint.constant = 0
            ecoMeterForCurrentUser.isHidden = true
        }
    }
    @objc func selectHomeLocation(_ sender :UITapGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("selectHomeLocation()")
        if homeLocation != nil{
            moveToLocationSelection(requestedLocationType: ChangeLocationViewController.HOME, currentLocation:
                Location(favouriteLocation: homeLocation!))
        }else{
            moveToLocationSelection(requestedLocationType: ChangeLocationViewController.HOME, currentLocation:
                nil)
        }
    }

    @objc func selectOfficeLocation(_ sender :UITapGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("selectOfficeLocation()")
        if officeLocation != nil{
            moveToLocationSelection(requestedLocationType: ChangeLocationViewController.OFFICE, currentLocation:
                Location(favouriteLocation: officeLocation!))
        }else{
            moveToLocationSelection(requestedLocationType: ChangeLocationViewController.OFFICE, currentLocation:
                nil)
        }
    }

    func  moveToLocationSelection(requestedLocationType : String,currentLocation : Location?){
        AppDelegate.getAppDelegate().log.debug("moveToLocationSelection() \(requestedLocationType) \(String(describing: currentLocation))")
        let changeLocationViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ChangeLocationViewController") as! ChangeLocationViewController
        changeLocationViewController.initializeDataBeforePresenting(receiveLocationDelegate: self, requestedLocationType: requestedLocationType, currentSelectedLocation: currentLocation, hideSelectLocationFromMap: false, routeSelectionDelegate: nil, isFromEditRoute: false)
        self.navigationController?.pushViewController(changeLocationViewController, animated: false)
    }

    func receiveSelectedLocation(location: Location, requestLocationType: String) {
        var message = ""
        if ChangeLocationViewController.HOME == requestLocationType{
            if officeLocation != nil{
                LocationClientUtils.checkHomeAndOfficeLocationsSameAndConvey(officeLocation: Location(favouriteLocation: officeLocation!), homeLocation: location)
            }
            
            message = Strings.do_you_want_to_set+location.completeAddress!+Strings.as_home_location
        }else if ChangeLocationViewController.OFFICE == requestLocationType{
            if homeLocation != nil{
                LocationClientUtils.checkHomeAndOfficeLocationsSameAndConvey(officeLocation: location, homeLocation: Location(favouriteLocation: homeLocation!))
            }
            message = Strings.do_you_want_to_set+location.completeAddress!+Strings.as_office_location
        }
        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: message, message2: nil, positiveActnTitle: Strings.yes_caps,negativeActionTitle : Strings.no_caps,linkButtonText: nil, viewController: self, handler: { (result) in
            if Strings.yes_caps == result{
                if ChangeLocationViewController.HOME == requestLocationType{
                    if let officeLoc = self.officeLocation,LocationClientUtils.getDistance(fromLatitude: location.latitude , fromLongitude: location.longitude, toLatitude: officeLoc.latitude ?? 0, toLongitude: officeLoc.longitude ?? 0)/1000 > 100{ // if location is greater than 100 km
                        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.home_office_location_to_far_error, message2: nil, positiveActnTitle: Strings.cancel_caps,negativeActionTitle : Strings.confirm_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                            if Strings.confirm_caps == result{
                                self.saveOrUpdateSelectedLocation(location: location, locationType: requestLocationType)
                            }
                        })
                    }else{
                        self.saveOrUpdateSelectedLocation(location: location, locationType: requestLocationType)
                    }
                }else if ChangeLocationViewController.OFFICE == requestLocationType{
                    if let homeLoc = self.homeLocation,LocationClientUtils.getDistance(fromLatitude: location.latitude , fromLongitude: location.longitude, toLatitude: homeLoc.latitude ?? 0, toLongitude: homeLoc.longitude ?? 0)/1000 > 100{ // if location is greater than 100 km
                        MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.home_office_location_to_far_error, message2: nil, positiveActnTitle: Strings.cancel_caps,negativeActionTitle : Strings.confirm_caps,linkButtonText: nil, viewController: self, handler: { (result) in
                            if Strings.confirm_caps == result{
                                self.saveOrUpdateSelectedLocation(location: location, locationType: requestLocationType)
                            }
                        })
                    }else{
                        self.saveOrUpdateSelectedLocation(location: location, locationType: requestLocationType)
                    }
                }
            }
        })
    }

    func locationSelectionCancelled(requestLocationType: String) {
        AppDelegate.getAppDelegate().log.debug("locationSelectionCancelled()")
    }

    func saveOrUpdateSelectedLocation(location : Location, locationType : String){
        AppDelegate.getAppDelegate().log.debug("saveOrUpdateSelectedLocation()")
        if locationType == ChangeLocationViewController.HOME{
            if homeLocation == nil{
                saveFavouriteLocation(location: location,name : UserFavouriteLocation.HOME_FAVOURITE)

            }else{
                updateSelectedLocation(location: location, name: UserFavouriteLocation.HOME_FAVOURITE)

            }
        }else if locationType == ChangeLocationViewController.OFFICE{
            if officeLocation == nil{
                saveFavouriteLocation(location: location,name : UserFavouriteLocation.OFFICE_FAVOURITE)
            }else{
                updateSelectedLocation(location: location, name: UserFavouriteLocation.OFFICE_FAVOURITE)
            }
        }
    }

    func saveFavouriteLocation(location: Location, name :String){
        AppDelegate.getAppDelegate().log.debug("saveFavouriteLocation()")
        let userFavouriteLocation = UserFavouriteLocation()
        userFavouriteLocation.address = location.completeAddress
        userFavouriteLocation.latitude = location.latitude
        userFavouriteLocation.longitude = location.longitude
        userFavouriteLocation.phoneNumber = Double(profileId!)
        userFavouriteLocation.city = location.city
        userFavouriteLocation.state = location.state
        userFavouriteLocation.areaName = location.areaName
        userFavouriteLocation.streetName = location.streetName
        userFavouriteLocation.country = location.country
        userFavouriteLocation.name = name
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.createUserFavouriteLocation(userFavouriteLocation: userFavouriteLocation, viewController: self) { (responseObject, error) -> Void in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                let location = Mapper<UserFavouriteLocation>().map(JSONObject: responseObject!.value(forKey: "resultData"))! as UserFavouriteLocation
                UserDataCache.getInstance()?.saveFavoriteLocations(favoriteLocations: location)
                self.loadProfileAndInitializeViews()
            }
            else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
            }
        }
    }

    func  getUpdatedFavLocation( location : Location, name : String, id : Double, phone : Double) -> UserFavouriteLocation{
        AppDelegate.getAppDelegate().log.debug("getUpdatedFavLocation()")
        let selectedLocation = UserFavouriteLocation();
        selectedLocation.longitude = location.longitude
        selectedLocation.latitude = location.latitude
        selectedLocation.address = location.completeAddress
        selectedLocation.name = name
        selectedLocation.locationId = id
        selectedLocation.phoneNumber = phone
        selectedLocation.city = location.city
        selectedLocation.state = location.state
        selectedLocation.areaName = location.areaName
        selectedLocation.streetName = location.streetName
        selectedLocation.country = location.country
        return selectedLocation
    }

    func updateSelectedLocation(location: Location, name :String){
        AppDelegate.getAppDelegate().log.debug("updateSelectedLocation()")
        var selectedLocation :UserFavouriteLocation? = nil
        var oldLocation : UserFavouriteLocation? = nil
        if name == UserFavouriteLocation.HOME_FAVOURITE{
            selectedLocation = getUpdatedFavLocation(location: location, name: homeLocation!.name!, id: homeLocation!.locationId!, phone: homeLocation!.phoneNumber!)
            oldLocation = homeLocation
        }else if name == UserFavouriteLocation.OFFICE_FAVOURITE{
            selectedLocation = getUpdatedFavLocation(location: location, name: officeLocation!.name!, id: officeLocation!.locationId!, phone: officeLocation!.phoneNumber!)
            oldLocation = officeLocation
        }
        if selectedLocation != nil{
            UserRestClient.updateFavouriteLocation(favouriteLocation: selectedLocation!, viewController: self, handler: { (responseObject, error) -> Void in
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                    let location = Mapper<UserFavouriteLocation>().map(JSONObject: responseObject!.value(forKey: "resultData"))! as UserFavouriteLocation

                    UserDataCache.getInstance()?.deleteUserFavouriteLocation(location: oldLocation!)

                    UserDataCache.getInstance()?.saveFavoriteLocations (favoriteLocations: location)
                    self.loadProfileAndInitializeViews()
                }
                else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self, handler: nil)
                }
            })
        }
    }

    func userVehicleInfoChanged()
    {
        self.loadProfileAndInitializeViews()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        AppDelegate.getAppDelegate().log.debug("")
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == vehicleTableView{
            if isCurrentUserProfile
            {
                if section == 0{
                    return userVehicles.count
                }else{
                    return 1
                }
            }
            else if userRole == UserRole.Rider || userRole == UserRole.RegularRider
            {
                if section == 0{
                    return userVehicles.count
                }else{
                    return 0
                }
            }
            return 0
        }
        else{
            return listOfRides.count
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == vehicleTableView{
            if isCurrentUserProfile
            {
                if indexPath.section == 0
                {
                    if self.userVehicles[indexPath.row].defaultVehicle{
                        return 70
                    }else{
                        return 60
                    }
                }else{
                    return 70
                }
            }
            if userRole == UserRole.Rider || userRole == UserRole.RegularRider
            {
                if indexPath.section == 0
                {
                    if self.userVehicles[indexPath.row].defaultVehicle{
                        return 70
                    }else{
                        return 60
                    }
                }
                else
                {
                    return 0
                }
            }else{
                return 0
            }
        }
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == vehicleTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath as IndexPath) as! VehicleTableViewCell
            if isCurrentUserProfile
            {

                if self.userVehicles.endIndex <= indexPath.row{
                    return cell
                }
                let vehicle  = self.userVehicles[indexPath.row]
                cell.initializeViews(vehicle: vehicle, isRiderProfile: false,isFromProfile : true, userVehiclesCount: self.userVehicles.count, viewController: self, listener: self)
                return cell

            }
            else
            {
                cell.initializeViews(vehicle: self.userVehicles[0], isRiderProfile : true, isFromProfile: true, userVehiclesCount: self.userVehicles.count, viewController: self, listener: self)
                return cell
            }
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath) as! NoOfRidesCompletedTableViewCell
            cell.setUpUI(row: indexPath.row, noOfRides: listOfRides[indexPath.row])
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){

        if tableView == vehicleTableView{
            if isCurrentUserProfile{
                let vehicle = self.userVehicles[indexPath.row]
                let vehicleSavingViewController = UIStoryboard(name: StoryBoardIdentifiers.vehicle_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.vehicleSavingViewController) as! VehicleSavingViewController
                vehicleSavingViewController.initializeDataBeforePresentingView(presentedFromActivationView: false,rideConfigurationDelegate: nil,vehicle: vehicle, listener: nil)
                self.navigationController?.pushViewController(vehicleSavingViewController, animated: false)
            }else{
                let vehicleDisplayViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "VehicleDisplayViewController") as! VehicleDisplayViewController
                vehicleDisplayViewController.initializeDataBeforePresentingView(vehicle: userVehicles[0])
                self.navigationController?.pushViewController(vehicleDisplayViewController, animated: false)
            }
        }else{
            if !isCurrentUserProfile{
                totalRidesLbl.text = listOfRides[indexPath.row]
                if indexPath.row == 0{
                    totalRidesTxtLbl.text = NoOfRidesCompletedTableViewCell.totalRides
                }else if indexPath.row == 1{
                    totalRidesTxtLbl.text = NoOfRidesCompletedTableViewCell.asRider
                }else{
                    totalRidesTxtLbl.text = NoOfRidesCompletedTableViewCell.asPassenger
                }
             hideNoOfRidesTableViewAndRemoveDelegate()
            }
        }
        tableView.deselectRow(at: indexPath as IndexPath, animated: false)
    }

    func userBlocked() {
        if isFromRideDetailView == true
        {
            let destViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myRidesController)
            self.navigationController?.pushViewController(destViewController, animated: false)
        }else{
            initializeBlockUserLbl()
            checkWhetherToDisplayCallOption()
        }
    }

    func userBlockingFailed(responseError: ResponseError) {
        MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: self,handler: nil)
    }

    func userUnBlocked() {
        initializeBlockUserLbl()
        checkWhetherToDisplayCallOption()
    }

    func emailVerified() {

    self.fullUserprofile.userProfile?.profileVerificationData = UserDataCache.getInstance()?.getCurrentUserProfileVerificationData()

        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if clientConfiguration.disableImageVerification || (self.fullUserprofile.userProfile != nil && self.fullUserprofile.userProfile!.profileVerificationData != nil && self.fullUserprofile.userProfile!.profileVerificationData!.profileVerified) || self.fullUserprofile.userProfile!.verificationStatus == 1{
            unverifiedView.isHidden = true
            unVerifiedViewHeightConstraint.constant = 0
            unVerifiedViewTopSpaceConstraint.constant = 0
        }else{
            setPendingProfileVerificationStatus()
            unverifiedView.isHidden = false
            unVerifiedViewHeightConstraint.constant = 90
            unVerifiedViewTopSpaceConstraint.constant = 25
        }
        handleVerifiedView()
        UserDataCache.getInstance()?.setReverficationStatus(isReVerifyDisplay: false)
    }


    @IBAction func backBtnClicked(_ sender: Any) {

        AppDelegate.getAppDelegate().log.debug("backButtonClicked()")
        if self.navigationController == nil{
            self.dismiss(animated: false, completion: nil)
        }else{
            if self.navigationController?.popViewController(animated: false) == nil{
                self.dismiss(animated: false, completion: nil)
            }
        }
        userSelectionDelegate?.userNotSelected?()

    }

    @IBAction func editBtnClicked(_ sender: Any) {

        if userSelectionDelegate != nil  {
            if self.navigationController == nil{
                self.dismiss(animated: false, completion: nil)
            }else{
                self.navigationController?.popViewController(animated: false)
            }
            self.userSelectionDelegate?.userSelected?()
            editButton.isUserInteractionEnabled = false
        }else{
            let vc = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }

    @IBAction func chatButtonClicked(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("chatButtonClicked()")
        if let chatDisableMsg = getErrorMessageForChat(){
            UIApplication.shared.keyWindow?.makeToast(chatDisableMsg)
            return
        }
        guard let userId = fullUserprofile.userProfile?.userId else { return }
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.initializeDataBeforePresentingView(ride: nil, userId: userId, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: viewController, animated: false)
    }

    @IBAction func callButtonClicked(_ sender: UIButton) {
        if let callDisableMsg = getErrorMessageForCall(){
            UIApplication.shared.keyWindow?.makeToast(callDisableMsg)
            return
        }
        guard let userProfile = fullUserprofile.userProfile else { return }
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: userProfile.userId), refId: Strings.profile,  name: self.fullUserprofile.userProfile?.userName ?? "", targetViewController: self)
    }
    private func getErrorMessageForChat() -> String?{
       if UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus == 0 && self.fullUserprofile.enableChatAndCall == false{
            return Strings.chat_and_call_disable_msg
        }else if userRole == UserRole.Rider || userRole == UserRole.RegularRider || userRole == UserRole.None {
            if !RideManagementUtils.getUserQualifiedToDisplayContact(){
                return Strings.link_wallet_for_call_msg
            }
        }
        return nil
    }

    private func getErrorMessageForCall() -> String?{
        if UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus == 0 && self.fullUserprofile.enableChatAndCall == false{
            return Strings.chat_and_call_disable_msg
        }else if let supportCall = fullUserprofile.userProfile?.supportCall, supportCall == UserProfile.SUPPORT_CALL_AFTER_JOINED{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: fullUserprofile.userProfile!.userId))
            if (contact != nil && contact!.contactType != Contact.RIDE_PARTNER) && !RideValidationUtils.checkUserJoinedInUpCommingRide(userId: fullUserprofile.userProfile!.userId){
                return Strings.call_joined_partner_msg
            }
            
        }else if let supportCall = fullUserprofile.userProfile?.supportCall, supportCall == UserProfile.SUPPORT_CALL_NEVER{
            return Strings.no_call_please_msg
        }else if userRole == UserRole.Rider || userRole == UserRole.RegularRider || userRole == UserRole.None {
            if !RideManagementUtils.getUserQualifiedToDisplayContact(){
                return Strings.link_wallet_for_call_msg
            }
        }
        return nil
    }

    private func checkCallOptionIsAvailableOrNotAndDisplay(){
        if fullUserprofile.userProfile!.supportCall == UserProfile.SUPPORT_CALL_AFTER_JOINED{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: fullUserprofile.userProfile!.userId))
            if (contact != nil && contact!.contactType == Contact.RIDE_PARTNER) || RideValidationUtils.checkUserJoinedInUpCommingRide(userId: fullUserprofile.userProfile!.userId){
                callBtn.backgroundColor = UIColor(netHex: 0x2196f3)
            }else{
                callBtn.backgroundColor = UIColor(netHex: 0xcad2de)
            }
        }else if fullUserprofile.userProfile!.supportCall == UserProfile.SUPPORT_CALL_ALWAYS{
            callBtn.backgroundColor = UIColor(netHex: 0x2196f3)
        }else{
            callBtn.backgroundColor = UIColor(netHex: 0xcad2de)
        }
        chatBtn.backgroundColor = UIColor(netHex: 0x19ac4a)
    }

    @IBAction func vehicleDetailsBtnTapped(_ sender: Any) {
        let vehicleDisplayViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "VehicleDisplayViewController") as! VehicleDisplayViewController
        vehicleDisplayViewController.initializeDataBeforePresentingView(vehicle: userVehicles[0])
        self.navigationController?.pushViewController(vehicleDisplayViewController, animated: false)
    }


    @objc func blockUserViewTapped(_ gesture : UITapGestureRecognizer){
        if blockUserLbl.text == Strings.block + " " + (fullUserprofile.userProfile?.userName ?? "")
        {
            let textViewAlertController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "TextViewAlertController") as! TextViewAlertController
            textViewAlertController.initializeDataBeforePresentingView(title: Strings.confirm_block + " " + (self.fullUserprofile.userProfile?.userName ?? "")+" ?", positiveBtnTitle: Strings.no_caps, negativeBtnTitle: Strings.yes_caps, placeHolder: Strings.placeholder_reason, textAlignment: NSTextAlignment.left, isCapitalTextRequired: false, isDropDownRequired: true, dropDownReasons: Strings.block_reason_list, existingMessage: nil,viewController: self, handler: { (text, result) in
                if Strings.yes_caps == result
                {
                    let reason = text?.trimmingCharacters(in: NSCharacterSet.whitespaces)
                    if reason!.count == 0{
                        MessageDisplay.displayAlert(messageString: Strings.suspend_reason,  viewController: self,handler: nil)
                        return
                    }
                    UserBlockTask.blockUser(phoneNumber: Double(self.profileId!)!, viewController : self, receiver: self, isContactNumber : false, reason: text)
                }
            })
            self.navigationController?.view.addSubview(textViewAlertController.view!)
            self.navigationController?.addChild(textViewAlertController)
        }else if blockUserLbl.text == Strings.unblock + " " + (fullUserprofile.userProfile?.userName ?? "")
        {
            UserUnBlockTask.unBlockUser(phoneNumber: fullUserprofile.userProfile!.userId,viewController : self, receiver: self)
        }
    }

    @objc func rateUserViewTapped(_ gesture : UITapGestureRecognizer){
        let viewController = UIStoryboard(name: "SystemFeedback", bundle: nil).instantiateViewController(withIdentifier: "DirectUserFeedbackViewController") as! DirectUserFeedbackViewController
        viewController.initializeDataAndPresent(name: fullUserprofile.userProfile?.userName ?? "",imageURI: fullUserprofile.userProfile!.imageURI,gender: fullUserprofile.userProfile?.gender ?? "",userId: fullUserprofile.userProfile!.userId, rideId: nil)
        self.navigationController?.view.addSubview(viewController.view)
        self.navigationController?.addChild(viewController)
    }

    @objc func ecoMeterViewTapped(_ gesture : UITapGestureRecognizer){
        if QRReachability.isConnectedToNetwork() == false {
            ErrorProcessUtils.displayNetworkError(viewController: self, handler: nil)
            return
        }
        guard let userProfile = fullUserprofile.userProfile, let id = profileId else { return }
        let ecoMeterVC : NewEcoMeterViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "NewEcoMeterViewController") as! NewEcoMeterViewController
        ecoMeterVC.initializeDataBeforePresenting(userId: profileId!, userName: fullUserprofile.userProfile?.userName ?? "",imageUrl: fullUserprofile.userProfile?.imageURI, gender: fullUserprofile.userProfile!.gender!)
        self.navigationController?.pushViewController(ecoMeterVC, animated: false)
    }

    @objc func reportProfileViewTapped(_ gesture : UITapGestureRecognizer){
        UIGraphicsBeginImageContext(scrollView.contentSize)

        let savedContentOffset = scrollView.contentOffset
        let savedFrame = scrollView.frame

        scrollView.contentOffset = CGPoint.zero
        scrollView.frame = CGRect(x: 0, y: 0, width: scrollView.contentSize.width, height: scrollView.contentSize.height)

        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        scrollView.contentOffset = savedContentOffset
        scrollView.frame = savedFrame

        UIGraphicsEndImageContext()
        let userProfile = UserDataCache.getInstance()?.userProfile
        var subject = ""
        if userProfile?.userName != nil{
            subject = subject+(userProfile?.userName)!
        }
        if userProfile?.userId != nil{
            subject = subject + "(\(StringUtils.getStringFromDouble(decimalNumber : userProfile?.userId)))" + "-" + "found something wrong with "
        }

        if fullUserprofile.userProfile?.userName != nil{
            subject = subject + (fullUserprofile.userProfile?.userName)! + "'s " + "(" + profileId! + ")" + "profile :"
        }


        HelpUtils.sendEmailToSupportWithSubject(delegate: self, viewController: self, messageBody: nil, image: image, listOfIssueTypes: Strings.list_of_report_profile_types, subject: subject, reciepients: nil)
    }

    @objc func accountViewTapped(_ gesture : UITapGestureRecognizer){
        let destViewController = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "MyAccountViewController") as! MyAccountViewController
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: destViewController, animated: false)
    }
    
    @IBAction func getRideEtiquetteCertificateClicked(_ sender: UIButton) {
        
        if let userId = QRSessionManager.getInstance()?.getUserId(), let jwtToken = SharedPreferenceHelper.getJWTAuthenticationToken() {
            var urlString: String?
            if AppConfiguration.useProductionServerForPG {
                 urlString = AppConfiguration.GET_RIDE_ETIQUETTE_CERTIFICATE_PRODUCTION_URL
            } else {
                urlString = AppConfiguration.GET_RIDE_ETIQUETTE_CERTIFICATE_STAGGING_URL
            }
            urlString!.append("?userId=")
            urlString!.append(userId)
            urlString!.append("&token=")
            urlString!.append(jwtToken.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            urlString!.append("&isMobile=true")
            if let name = self.fullUserprofile.userProfile?.userName {
                urlString!.append("&name=")
                urlString!.append(name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
            }
            if let url = URL(string: urlString!) {
                let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
                webViewController.backImage = UIImage(named: "close_new")
                webViewController.initializeDataBeforePresenting(titleString: "Ride Etiquette Certificate", url: url, actionComplitionHandler: nil)
                ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: webViewController, animated: true)
            } else {
                UIApplication.shared.keyWindow?.makeToast(Strings.cant_open_this_web_page)
            }
        }
    }

    @IBAction func updateHomeLocationClicked(_ sender: Any) {

        AppDelegate.getAppDelegate().log.debug("updateHomeLocationClicked()")

        if homeLocation == nil{
            return
        }
        displayHomeAndOfficePopUpMenu(favouriteLocation: homeLocation!, locationType: ChangeLocationViewController.HOME , locationName: homeLocationLbl.text)

    }

    @IBAction func updateOfficeLocationClicked(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("updateOfficeLocationClicked()")
        if officeLocation == nil{
            return
        }
        displayHomeAndOfficePopUpMenu(favouriteLocation: officeLocation!, locationType: ChangeLocationViewController.OFFICE, locationName: officeLocationLbl.text)
    }

    func displayHomeAndOfficePopUpMenu( favouriteLocation : UserFavouriteLocation, locationType : String,locationName : String?){

        AppDelegate.getAppDelegate().log.debug("displayHomeAndOfficePopUpMenu()")
        let alertController : HomeAndOfficeLocationAlertController = HomeAndOfficeLocationAlertController(viewController: self) { (result) -> Void in
            if result == Strings.update{
                self.moveToLocationSelection(requestedLocationType: locationType, currentLocation: Location(favouriteLocation: favouriteLocation))
            }else if result == Strings.delete{
                QuickRideProgressSpinner.startSpinner()
                UserRestClient.deleteFavouriteLocations(id: favouriteLocation.locationId!, viewController: self, completionHandler: { (responseObject, error) -> Void in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject == nil || responseObject!["result"] as! String == "FAILURE" {
                        ErrorProcessUtils.handleError(responseObject: responseObject,error: error, viewController: self, handler: nil)
                    }else if responseObject!["result"] as! String == "SUCCESS"{

                        UserDataCache.getInstance()?.deleteUserFavouriteLocation(location: favouriteLocation)
                        if locationType == ChangeLocationViewController.HOME {
                           SharedPreferenceHelper.storeHomeLocation(homeLocation: nil)
                        }else{
                           SharedPreferenceHelper.storeOfficeLocation(officeLocation: nil)
                        }

                        self.loadProfileAndInitializeViews()
                      }
                })
            }
        }
        alertController.updateAlertAction()
        alertController.deleteAlertAction()
        alertController.addRemoveAlertAction()
        alertController.showAlertController()
    }

    @objc func verifyNowViewClicked(_ gesture : UITapGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("")
        if !QRReachability.isConnectedToNetwork(){
            UIApplication.shared.keyWindow?.makeToast(Strings.NetworkConnectionNotAvailable_Msg)
            return
        }
        let verifyProfileVC = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyProfileViewController") as! VerifyProfileViewController
        verifyProfileVC.intialData(isFromSignUpFlow: false)
        self.navigationController?.pushViewController(verifyProfileVC, animated: false)
    }


    @IBAction func addAsFavouriteBtnClicked(_ sender: Any) {
        QuickRideProgressSpinner.startSpinner()
        AddFavouritePartnerTask.addFavoritePartner(userId: (QRSessionManager.getInstance()?.getUserId())!, favouritePartnerUserIds: [Double(profileId!)!], receiver: self, viewController: self)
    }

    func favPartnerAdded() {
        handleVisibilityOfFavouriteView()
        handleScrollViewHeight()
    }

    func favPartnerAddingFailed(responseError: ResponseError) {
        MessageDisplay.displayErrorAlert(responseError: responseError, targetViewController: self,handler: nil)

    }

    @IBAction func addVehicleBtnClicked(_ sender: Any) {
       navigateToVehicleView()
    }

    func navigateToVehicleView(){
        let vehicleSavingViewController = UIStoryboard(name: StoryBoardIdentifiers.vehicle_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.vehicleSavingViewController) as! VehicleSavingViewController
        vehicleSavingViewController.initializeDataBeforePresentingView(presentedFromActivationView: false,rideConfigurationDelegate: nil,vehicle: nil, listener: nil)
        self.navigationController?.pushViewController(vehicleSavingViewController, animated: false)
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HelpUtils.displayMailStatusAndDismiss(controller: controller, result: result)
    }

    @objc func totalRidesViewTapped(_ sender :UITapGestureRecognizer){
        if !buttonDropDown.isHidden{
            if !tabelViewNoOfRides.isHidden{
                hideNoOfRidesTableViewAndRemoveDelegate()
            }
            else{
                tabelViewNoOfRides.isHidden = false
                tabelViewNoOfRides.delegate = self
                tabelViewNoOfRides.dataSource = self
                tabelViewNoOfRides.reloadData()
            }
        }
    }

    func hideNoOfRidesTableViewAndRemoveDelegate(){
        tabelViewNoOfRides.isHidden = true
        tabelViewNoOfRides.delegate = nil
        tabelViewNoOfRides.dataSource = nil
    }

    @objc func addVehicleViewTapped(_ gesture : UITapGestureRecognizer){
        self.navigateToVehicleView()
    }

    @objc func dlVerificationViewTapped(_ gesture : UITapGestureRecognizer){
        self.navigateToDlVerificationView()
    }

    @objc func birthDayViewTapped(_ gesture : UITapGestureRecognizer){
        let vc = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
        self.navigationController?.pushViewController(vc, animated: false)
    }

    func navigateToDlVerificationView(){
        let personalIdVerificationViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PersonalIdVerificationViewController") as! PersonalIdVerificationViewController
        personalIdVerificationViewController.initialiseData(isFromProfile: true, verificationType: PersonalIdDetail.DL) { [weak self] in
            self?.handleVisibilityOfDLVerificationView()
        }
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: personalIdVerificationViewController, animated: false)
    }

    @objc func safeKeeperViewTapped(_ gesture: UITapGestureRecognizer) {
        let safeKeeperInfoVC = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SafeKeeperInfoViewController") as! SafeKeeperInfoViewController
        safeKeeperInfoVC.initializeData(name: fullUserprofile.userProfile?.userName)
        ViewControllerUtils.addSubView(viewControllerToDisplay: safeKeeperInfoVC)
    }
    
}
extension ProfileDisplayViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return hobbiesList.count
        } else {
            return skillsList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HobbiesAndSkillsCollectionViewCell", for: indexPath) as! HobbiesAndSkillsCollectionViewCell
        if indexPath.section == 0 {
            if hobbiesList.endIndex <= indexPath.row {
                return cell
            }
            cell.tag = 1
            cell.setupUI(hobbyOrSkill: hobbiesList[indexPath.row], selectedHobbies: [String](), selectedSkills: [String](), section: indexPath.section)
        } else {
            if skillsList.endIndex <= indexPath.row {
                return cell
            }
            cell.tag = 1
            cell.setupUI(hobbyOrSkill: skillsList[indexPath.row], selectedHobbies: [String](), selectedSkills: [String](), section: indexPath.section)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            if hobbiesList.isEmpty {
                return CGSize(width: view.frame.size.width, height: 0)
            } else {
                return CGSize(width: view.frame.size.width, height: 50)
            }
        } else {
            if skillsList.isEmpty{
                return CGSize(width: view.frame.size.width, height: 0)
            } else {
                return CGSize(width: view.frame.size.width, height: 50)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            if hobbiesList.isEmpty || (!hobbiesList.isEmpty && !skillsList.isEmpty){
                return CGSize(width: view.frame.size.width, height: 0)
            } else {
                return CGSize(width: view.frame.size.width, height: 50)
            }
        } else {
            if skillsList.isEmpty {
                return CGSize(width: view.frame.size.width, height: 0)
            } else {
                return CGSize(width: view.frame.size.width, height: 50)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HobbiesAndSkillsHeaderCollectionReusableView", for: indexPath) as! HobbiesAndSkillsHeaderCollectionReusableView
            headerView.tag = 1
            if indexPath.section == 0 {
                headerView.setupUI(headerText: Strings.hobbies.uppercased())
            } else {
                headerView.setupUI(headerText: Strings.skills.uppercased())
            }
            return headerView
        } else {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HobbiesAndSkillsFooterCollectionReusableView", for: indexPath) as! HobbiesAndSkillsFooterCollectionReusableView
            if indexPath.section == 0 {
                footerView.tag = 1
                footerView.setupUI(searchDataForHobbies: [String](), searchDataForSkills: [String](), defaultText: Strings.add_or_edit_hobbies)
            } else {
                footerView.tag = 1
                if !hobbiesList.isEmpty && !skillsList.isEmpty {
                    footerView.setupUI(searchDataForHobbies: [String](), searchDataForSkills: [String](), defaultText: Strings.add_hobbies_and_skills)
                } else {
                    footerView.setupUI(searchDataForHobbies: [String](), searchDataForSkills: [String](), defaultText: Strings.add_or_edit_skills)
                }
            }
            return footerView
        }
    }
    
}
extension ProfileDisplayViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
    }
}
extension ProfileDisplayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var text = ""
        if indexPath.section == 0 {
            text = hobbiesList[indexPath.item]
        } else {
            text = skillsList[indexPath.item]
        }
        
        let cellWidth = text.size(withAttributes:[.font: UIFont(name: "Roboto-Medium", size: 16) as Any]).width + 35.0
        return CGSize(width: cellWidth + 35, height: 40.0)
    }
}
