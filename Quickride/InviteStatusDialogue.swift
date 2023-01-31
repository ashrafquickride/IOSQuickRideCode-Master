//
//  InviteStatusDialogue.swift
//  Quickride
//
//  Created by QuickRideMac on 16/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

typealias InviteStatusDialogueActionHandler = (_ invitationStatus: RideInviteStatus?) -> Void

class InviteStatusDialogue: ModelViewController,OnInvitedUserCallBack,MatchedUserReceiver,UserSelectedDelegate, CommunicationUtilsListener{
    
    @IBOutlet weak var InvitationStatusTitle: UILabel!
    
    @IBOutlet weak var invitationStatusSubTitle: UILabel!
    
    @IBOutlet weak var InvitationStatusIcon: UIImageView!
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    
    @IBOutlet weak var verifiedBadge: UIImageView!
    
    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var fromLocation: UILabel!
    
    @IBOutlet weak var toLocation: UILabel!
    
    @IBOutlet weak var ratinglabel: UILabel!
    
    @IBOutlet weak var cancelInvitation: UIButton!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet var backGroundView: UIView!
    
    @IBOutlet weak var matchedUserDetailsView: UIView!
    
    @IBOutlet weak var matchedUserDetailsViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var matchedUserPickupTime: UILabel!
    
    @IBOutlet weak var matchedUserRideMatchPercentage: UILabel!
    
    @IBOutlet weak var matchedUserFare: UILabel!
    
    @IBOutlet weak var fareView: UIView!
    
    @IBOutlet weak var callUserButton: UIButton!
    
    @IBOutlet weak var sendAgainButton: UIButton!
    
    @IBOutlet weak var viewUserDetailHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pickUpTimeView: UIView!
    
    @IBOutlet weak var pickUpText: UILabel!
    
    @IBOutlet weak var fareText: UILabel!
    
    @IBOutlet weak var rideStatusStartedLbl: UILabel!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var profileImageForOldUser: UIImageView!
    
    @IBOutlet weak var labelNoOfRidesCompleted: UILabel!
    
    @IBOutlet weak var labelNoOfReview: UILabel!
    
    @IBOutlet weak var viewUserDetails: UIView!
    
    @IBOutlet weak var viewAutoInviteHeading: UIView!
    
    @IBOutlet weak var labelAutoInviteText: UILabel!
    
    @IBOutlet weak var autoInviteInfoIcon: UIImageView!
    
    @IBOutlet weak var viewAutoInviteHeadingHeight: NSLayoutConstraint!
    
    var invitedUser : UserBasicInfo?
    var rideInvitation : RideInvitation?
    var currentUserRide : Ride?
    var matchedUser : MatchedUser?
    var inviteStatusDialogueActionHandler : InviteStatusDialogueActionHandler?
    var liveRideViewController : BaseLiveRideMapViewController?
    
    func initializeDataAndPresent( invitedUser: UserBasicInfo,currentUserRide :Ride,  rideInvitation : RideInvitation, liveRideViewController : BaseLiveRideMapViewController, inviteStatusDialogueActionHandler : @escaping InviteStatusDialogueActionHandler){
        AppDelegate.getAppDelegate().log.debug("")
        self.invitedUser = invitedUser
        self.rideInvitation = rideInvitation
        self.inviteStatusDialogueActionHandler = inviteStatusDialogueActionHandler
        self.currentUserRide = currentUserRide
        self.liveRideViewController = liveRideViewController
    }
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        backGroundView.isUserInteractionEnabled = true
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InviteStatusDialogue.backGroundViewTapped(_:))))
        viewAutoInviteHeading.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InviteStatusDialogue.viewAutoInviteHeadingTapped(_:))))
        initializeInvitationStatusViews()
        invitedUserDetailViews()
        initializePickUpTimeView()
        setTitleForContactBtn()
        initializeAutoConfirmHeading()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CustomExtensionUtility.changeBtnColor(sender: self.sendAgainButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        CustomExtensionUtility.changeBtnColor(sender: self.callUserButton, color1: UIColor(netHex:0xF3F3F3), color2: UIColor(netHex:0xF3F3F3))
        CustomExtensionUtility.changeBtnColor(sender: self.cancelInvitation, color1: UIColor.white, color2: UIColor.white)
        cancelInvitation.addShadow()
        callUserButton.addShadow()
    }
    
    func initializeAutoConfirmHeading(){
        if rideInvitation!.autoInvite{
            autoInviteInfoIcon.image = autoInviteInfoIcon.image!.withRenderingMode(.alwaysTemplate)
            autoInviteInfoIcon.tintColor = UIColor.lightGray
            viewAutoInviteHeading.isHidden = false
            viewAutoInviteHeadingHeight.constant = 14
            if Ride.RIDER_RIDE == rideInvitation!.rideType{
                labelAutoInviteText.text = Strings.ride_auto_invited
            }else{
                labelAutoInviteText.text = Strings.ride_auto_requested
            }
        }
        else{
            viewAutoInviteHeading.isHidden = true
            viewAutoInviteHeadingHeight.constant = 0
        }
    }
    
    func initializePickUpTimeView(){
        if AppConfiguration.APP_NAME != "MyRide" && currentUserRide?.rideType == Ride.RIDER_RIDE{
            self.matchedUserPickupTime.textColor = Colors.editRouteBtnColor
            self.pickUpText.textColor = Colors.editRouteBtnColor
            self.pickUpTimeView.isUserInteractionEnabled = true
            self.pickUpTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InviteStatusDialogue.pickUpTimeViewTapped(_:))))
        }else{
            self.matchedUserPickupTime.textColor = UIColor.black
            self.pickUpText.textColor = UIColor.black
        }
    }
    func checkWhetherToDisplayCallOption(){
        if matchedUser == nil || matchedUser!.enableChatAndCall == false{
            callUserButton.isHidden = true
        }
        else if (matchedUser!.userRole == MatchedUser.RIDER || matchedUser!.userRole == MatchedUser.REGULAR_RIDER) && !RideManagementUtils.getUserQualifiedToDisplayContact(){
            callUserButton.isHidden = true
            let modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as! ModelLessDialogue
            modelLessDialogue.initializeViews(message: Strings.no_balance_reacharge_toast, actionText: Strings.link_caps)
            let position = CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height*2/3)
            self.view.showToast(toast: modelLessDialogue, duration: 10.0, position: position, completion: { (didTap) -> Void in
                if didTap == true{
                    ContainerTabBarViewController.indexToSelect = 3
                    self.navigationController?.popToRootViewController(animated: false)
                    self.view.removeFromSuperview()
                    self.removeFromParent()
                }
            })
        }
        else{
            callUserButton.isHidden = false
        }
    }
    
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer)
    {
        self.removeSuperView()
    }
    func displayView(){
        
        ViewControllerUtils.addSubView(viewControllerToDisplay: self)
    }
    func initializeInvitationStatusViews(){
        AppDelegate.getAppDelegate().log.debug("")
        if RideInvitation.RIDE_INVITATION_STATUS_RECEIVED == rideInvitation!.invitationStatus{
            InvitationStatusIcon.image = UIImage(named: "delivered_icon")
            InvitationStatusTitle.text = Strings.invitation_delivered
            invitationStatusSubTitle.text = Strings.invitation_delivered_hint
        }else if RideInvitation.RIDE_INVITATION_STATUS_NEW == rideInvitation!.invitationStatus{
            InvitationStatusIcon.image = UIImage(named: "sent_icon")
            InvitationStatusTitle.text = Strings.invitation_sent
            invitationStatusSubTitle.text = Strings.invitation_sent_hint
        }else if RideInvitation.RIDE_INVITATION_STATUS_READ == rideInvitation!.invitationStatus{
            let tintedImage = UIImage(named: "double_tick_green")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            InvitationStatusIcon.image = tintedImage
            InvitationStatusIcon.tintColor = Colors.mainButtonColor
            InvitationStatusTitle.text = Strings.invitation_seen
            invitationStatusSubTitle.text = Strings.invitation_delivered_hint
        }else{
            InvitationStatusIcon.image = UIImage(named: "error_icon")
            InvitationStatusTitle.text = Strings.invitation_failed
            invitationStatusSubTitle.isHidden = true
        }
    }
    func invitedUserDetailViews(){
        AppDelegate.getAppDelegate().log.debug("")
        gettingMatchedUser()
        viewUserDetails.isUserInteractionEnabled = true
        viewUserDetails.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InviteStatusDialogue.visitProfile(_:))))
        if invitedUser!.rating > 0{
            ratinglabel.text = (" \(StringUtils.getStringFromDouble(decimalNumber: invitedUser!.rating))")
            labelNoOfReview.text = "(" + "\(String(invitedUser!.noOfReviews))" + ")"
        }else{
            ratinglabel.text = Strings.NA
            labelNoOfReview.text = ""
        }
        userName.text = invitedUser!.name?.capitalizingFirstLetter()
        fromLocation.text = rideInvitation!.pickupAddress
        toLocation.text = rideInvitation!.dropAddress
        verifiedBadge.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: invitedUser!.profileVerificationData)
        companyName.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: invitedUser!.profileVerificationData, companyName: invitedUser!.companyName)
        
        if (invitedUser!.profileVerificationData != nil && invitedUser!.profileVerificationData!.profileVerified) || invitedUser!.verificationStatus{
            #if WERIDE
            #else
            companyName.textColor = UIColor(netHex: 0x24a647)
            #endif
        }else{
            #if WERIDE
            #else
            companyName.textColor = UIColor(netHex :0x525252)
            #endif
            
        }
    }
    func gettingMatchedUser()
    {
        var rideType: String?
        var rideId : Double?
        var userId : Double?
        if currentUserRide!.rideType == Ride.RIDER_RIDE{
            rideType = Ride.PASSENGER_RIDE
            rideId = rideInvitation?.passenegerRideId
            userId = rideInvitation?.passengerId
        }else{
            rideType = Ride.RIDER_RIDE
            rideId = rideInvitation?.rideId
            userId = rideInvitation?.riderId
        }
        self.userImage.contentMode = .scaleAspectFit
        self.userImage.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        
        if invitedUser?.imageURI == nil{
            ImageCache.getInstance().setImageToView(imageView: self.profileImageForOldUser, imageUrl: nil, gender: invitedUser!.gender!,imageSize: ImageCache.DIMENTION_SMALL)
        }
        else{
            ImageCache.getInstance().setImageToView(imageView: self.userImage, imageUrl: nil, gender: invitedUser!.gender!,imageSize: ImageCache.DIMENTION_SMALL)
        }
        
        UserDataCache.getInstance()?.getOtherUserCompleteProfile(userId: StringUtils.getStringFromDouble(decimalNumber: userId), targetViewController: self, completeProfileRetrievalCompletionHandler: { (otherUserInfo, error, responseObject) in
            if otherUserInfo != nil && otherUserInfo!.userProfile != nil{
                if otherUserInfo!.userProfile!.roundedImage || otherUserInfo!.userProfile!.imageURI == nil{
                    self.userImage.image = nil
                    ImageCache.getInstance().setImageToView(imageView: self.profileImageForOldUser, imageUrl: otherUserInfo!.userProfile!.imageURI, gender: otherUserInfo!.userProfile!.gender!,imageSize: ImageCache.DIMENTION_SMALL)
                }
                else{
                    self.profileImageForOldUser = nil
                    ImageCache.getInstance().setImageToView(imageView: self.userImage, imageUrl: otherUserInfo!.userProfile!.imageURI, gender: otherUserInfo!.userProfile!.gender!,imageSize: ImageCache.DIMENTION_SMALL)
                }
            }
        })
        if(rideId==0)
        {
            handleMatchedUsersDetailsViewHeight()
            return
        }
        let matchedUserRetrievalTask = MatchedUserRetrievalTask(userId: userId!,rideId: rideId!, rideType: rideType!,rideInvitation: rideInvitation, matchedUserReceiver: self)
        matchedUserRetrievalTask.getMatchedUser()
    }
    @objc func visitProfile(_ gesture : UITapGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("")
        self.view.removeFromSuperview()
        self.removeFromParent()
        if matchedUser == nil{
            let profileDisplayViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
            profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: invitedUser!.userId!),isRiderProfile: UserRole.None ,rideVehicle : nil, userSelectionDelegate: self, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
            ViewControllerUtils.displayViewController(currentViewController: liveRideViewController, viewControllerToBeDisplayed: profileDisplayViewController, animated: false)
            return
        }else{
            let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
            mainContentVC.initializeData(ride: currentUserRide!, matchedUserList: [matchedUser!], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, isFromJoinMyRide: false, selectedUserDelegate: nil)
            let drawerContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedViewController") as! RideDetailedViewController
            drawerContentVC.initializeData(ride: currentUserRide!, matchedUserList: [matchedUser!], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, isFromJoinMyRide: false, selectedUserDelegate: nil, matchedUserDataChangeDelagate: mainContentVC.self)
            ViewControllerUtils.addPulleyViewController(mainContentViewController: mainContentVC, drawerContentViewController: drawerContentVC, currentViewController: self)
        }
        
    }
    func receiveMatchedUser(matchedUser: MatchedUser?, responseError: ResponseError?, error: NSError?) {
        if matchedUser != nil
        { 
            initializeDataOfRiderOrRideTaker(matchedUser: matchedUser!)
            handleMatchedUsersDetailsViewHeight()
        }
        else if responseError != nil{
            if responseError!.errorCode == RideValidationUtils.PASSENGER_ALREADY_JOINED_THIS_RIDE{
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED)
                removeSuperView()
            } else if responseError!.errorCode == RideValidationUtils.PASSENGER_ENGAGED_IN_OTHER_RIDE || responseError!.errorCode == RideValidationUtils.INSUFFICIENT_SEATS_ERROR {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_REJECTED)
                removeSuperView()
            } else if responseError!.errorCode == RideValidationUtils.RIDE_ALREADY_COMPLETED || responseError!.errorCode == RideValidationUtils.RIDE_CLOSED_ERROR || responseError!.errorCode == RideValidationUtils.RIDER_ALREADY_CROSSED_PICK_UP_POINT_ERROR {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED)
                removeSuperView()
            } else {
                MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self, handler: nil)
                handleMatchedUsersDetailsViewHeight()
            }
        }else{
            ErrorProcessUtils.handleError(responseObject: nil, error: error, viewController: self, handler: nil)
            handleMatchedUsersDetailsViewHeight()
        }
    }
    func handleMatchedUsersDetailsViewHeight()
    {
        if self.matchedUser != nil
        {
            self.matchedUserDetailsView.isHidden = false
            self.matchedUserDetailsViewHeight.constant = 35
            self.viewUserDetailHeightConstraint.constant = 240
        }
        else
        {
            self.matchedUserDetailsView.isHidden = true
            self.matchedUserDetailsViewHeight.constant = 0
            self.viewUserDetailHeightConstraint.constant = 190
            if UserProfile.isCallSupportAlways(callSupport: invitedUser!.callSupport, enableChatAndCall: invitedUser!.enableChatAndCall) == CommunicationType.None{
                callUserButton.isHidden = true
            }
            else{
                callUserButton.isHidden = false
            }
        }
    }
    
    func removeInvitationAndRefreshData(status : String){
        rideInvitation?.invitationStatus = status
        let rideInvitationStatus = RideInviteStatus(rideInvitation: rideInvitation!)
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitationStatus.invitationId)
        RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
        if self.liveRideViewController != nil{
            self.liveRideViewController!.validateAndGetRideInvites()
        }
    }

    @objc func pickUpTimeViewTapped(_ gesture : UITapGestureRecognizer){
        if matchedUser == nil{
            return
        }
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let dateSelectionController:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        dateSelectionController.initializeDataBeforePresentingView(minDate: NSDate().timeIntervalSince1970, maxDate: nil, defaultDate: NSDate().timeIntervalSince1970, isDefaultDateToShow: false, delegate: nil, datePickerMode: UIDatePicker.Mode.time, datePickerTitle: nil) { (date) in
            let rideDuration = self.matchedUser!.dropTime! - self.matchedUser!.pickupTime!
            self.matchedUser!.pickupTime = date.getTimeStamp()
            self.matchedUser!.passengerReachTimeTopickup = date.getTimeStamp()
            self.matchedUser!.dropTime = NSDate(timeIntervalSince1970:   self.matchedUser!.pickupTime!/1000).getTimeStamp() + rideDuration
            self.matchedUser!.pickupTimeRecalculationRequired = false
            self.checkAndSetPickUpTimeText(matchedUser: self.matchedUser!)
        }
        dateSelectionController.modalPresentationStyle = .overCurrentContext
        self.present(dateSelectionController, animated: false, completion: nil)
    }
    func initializeDataOfRiderOrRideTaker(matchedUser: MatchedUser)
    {
        self.matchedUser = matchedUser
        checkAndSetPickUpTimeText(matchedUser: matchedUser)
        self.checkWhetherToDisplayCallOption()
        labelNoOfRidesCompleted.text = "\(StringUtils.getStringFromDouble(decimalNumber: matchedUser.noOfRidesShared)) Ride(s) Completed"
        verifiedBadge.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: matchedUser.profileVerificationData)
        if FareChangeUtils.isFareChangeApplicable(matchedUser: matchedUser){
            
            self.fareText.textColor = Colors.editRouteBtnColor
            self.matchedUserFare.textColor = Colors.editRouteBtnColor
            self.fareView.isUserInteractionEnabled = true
            self.fareView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InviteStatusDialogue.fareChangeViewTapped(_:))))
        }else{
            self.fareText.textColor = UIColor(netHex:0x7A7A7A)
            self.matchedUserFare.textColor = UIColor.black
        }
        checkAndSetMatchingPercentage(matchedUser: matchedUser,ride: currentUserRide!)
        matchedUserRideMatchPercentage.text = "\(matchedUser.matchPercentage!)%"
        checkAndSetPointsText(matchedUser: matchedUser)
        checkForRideStatusStartedAndSetStatusLabel(matchedUser: matchedUser)
    }
    func checkForRideStatusStartedAndSetStatusLabel(matchedUser : MatchedUser){
        AppDelegate.getAppDelegate().log.debug("checkForRideStatusStartedAndSetStatusLabel()")
        if MatchedUser.RIDER == matchedUser.userRole && Ride.RIDE_STATUS_STARTED == (matchedUser as! MatchedRider).rideStatus{
            rideStatusStartedLbl.isHidden = false
        }else{
            rideStatusStartedLbl.isHidden = true
        }
    }
    func setTitleForContactBtn(){
        self.callUserButton.titleLabel?.textAlignment = .center
        let isRidePartner = UserDataCache.getInstance()?.checkIsRidePartner(userId: invitedUser!.userId!)
        if CommunicationUtils.checkAndEnableCallOption(callSupport: invitedUser!.callSupport, isRidePartner: isRidePartner!) == true{
            self.callUserButton.setTitle(Strings.CONTACT_CAPS, for: .normal)
        }else{
            self.callUserButton.setTitle(Strings.CHAT_CAPS, for: .normal)
        }
    }
    
    func checkAndSetPickUpTimeText(matchedUser : MatchedUser){
        if matchedUser.passengerReachTimeTopickup != nil && matchedUser.passengerReachTimeTopickup != 0{
            matchedUserPickupTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.passengerReachTimeTopickup!, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }else{
            matchedUserPickupTime.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.pickupTime!, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }
    }
    func checkAndSetMatchingPercentage(matchedUser : MatchedUser, ride : Ride) {
        if (matchedUser.matchPercentage!) <= 0 && (ride.distance!) > 0{
            matchedUser.matchPercentage = Int((matchedUser.distance!/ride.distance!)*100)
            if matchedUser.matchPercentage! > 100
            {
                matchedUser.matchPercentage = 100
            }
        }
    }
    func checkAndSetPointsText(matchedUser: MatchedUser)
    {
        if  matchedUser.newFare != -1{
            matchedUserFare.attributedText = FareChangeUtils.getFareDetails(newFare: StringUtils.getStringFromDouble(decimalNumber: matchedUser.newFare), actualFare: StringUtils.getStringFromDouble(decimalNumber: matchedUser.points!), textColor: matchedUserFare.textColor)
        }else{
            matchedUserFare.text = StringUtils.getStringFromDouble(decimalNumber: matchedUser.points!)
        }
    }
    func userNotSelected() {
        displayView()
    }
    
    @objc func fareChangeViewTapped(_ gesture : UITapGestureRecognizer){
        if matchedUser == nil{
            return
        }
        let fareChangeViewController = UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "FareChangeViewController") as! FareChangeViewController
        var noOfSeats = 1
        var rideFarePerKm = 0.0
        if currentUserRide!.isKind(of: PassengerRide.classForCoder()){
            noOfSeats = (currentUserRide as! PassengerRide).noOfSeats
            rideFarePerKm = (matchedUser as! MatchedRider).fare ?? 0.0
        }else if matchedUser!.isKind(of: MatchedPassenger.classForCoder()){
            noOfSeats = (matchedUser as! MatchedPassenger).requiredSeats
            rideFarePerKm = (currentUserRide as! RiderRide).farePerKm
        }
        fareChangeViewController.initializeDataBeforePresenting(rideType: currentUserRide!.rideType!,actualFare : matchedUser!.points!,distance: matchedUser!.distance!,selectedSeats: noOfSeats, farePerKm: rideFarePerKm) { (actualFare, requestedFare) in
            self.matchedUser!.newFare = requestedFare
            self.matchedUser!.fareChange = true
            self.checkAndSetPointsText(matchedUser: self.matchedUser!)
        }
        ViewControllerUtils.getCenterViewController().view.addSubview(fareChangeViewController.view)
        ViewControllerUtils.getCenterViewController().addChild(fareChangeViewController)
        
    }
    
    @IBAction func callUserButtonClicked(_ sender: Any) {
        
        var isRideStarted = false
        if matchedUser != nil && matchedUser!.isKind(of: MatchedRider.self) && (matchedUser as! MatchedRider).rideStatus == Ride.RIDE_STATUS_STARTED && matchedUser!.callSupport == UserProfile.SUPPORT_CALL_ALWAYS{
            isRideStarted = true
        }
        CommunicationUtils(userBasicInfo : invitedUser!, isRideStarted: isRideStarted,viewController : self, delegate: self).checkAndNavigateToContactViewController()
        removeSuperView()
    }
    func removeSuperView(){
        self.inviteStatusDialogueActionHandler!(nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func sendAgainButtonClicked(_ sender: Any)
    {
        AppDelegate.getAppDelegate().log.debug("")
        if matchedUser != nil{
            if matchedUser!.newFare != -1{
                rideInvitation!.newFare = matchedUser!.newFare
            }
            rideInvitation!.pickupTime = matchedUser!.pickupTime
            rideInvitation!.dropTime = matchedUser!.dropTime
            rideInvitation!.pickupTimeRecalculationRequired = matchedUser!.pickupTimeRecalculationRequired
        }
        let resendInvitationTask = ResendInvitationTask(rideInvitation: rideInvitation!, viewController: self, invitedUser: invitedUser!, inviteUserCallBack: self)
        resendInvitationTask.inviteUser()
        self.removeSuperView()
    }
    
    @IBAction func cancelInvitationClicked(_ sender: Any) {
        AppDelegate.getAppDelegate().log.debug("")
        QuickRideProgressSpinner.startSpinner()
        
        RideMatcherServiceClient.updateRideInvitationStatus(invitationId: rideInvitation!.rideInvitationId!, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED, viewController: self) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                self.removeSuperView()
                UIApplication.shared.keyWindow?.makeToast(message: Strings.invite_cancelled_toast, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
                
                self.removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED)
            }
        }
    }
    
    func inviteSuccess()
    {
        UIApplication.shared.keyWindow?.makeToast(message: Strings.invite_sent_to+" "+userName.text!+", "+Strings.we_will_notify, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
    }
    func userSelected(){
        
    }
    func notSelected(){
        displayView()
    }
    @IBAction func rideNotesTapped(_ sender: Any) {
        if matchedUser == nil || matchedUser!.rideNotes == nil {
            return
        }
        MessageDisplay.displayInfoDialogue(title: Strings.ride_notes, message: self.matchedUser!.rideNotes!, viewController: nil)
    }
    
    @objc func viewAutoInviteHeadingTapped(_ gesture: UITapGestureRecognizer){
        self.alertView.isHidden = true
        var title: String?
        var message: String?
        if Ride.RIDER_RIDE == rideInvitation!.rideType{
            title = Strings.ride_auto_invited
            message = Strings.invite_sent_by_auto_confirm
        }else{
            title = Strings.ride_auto_requested
            message = Strings.request_sent_by_auto_confirm
        }
        let infoView = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InfoViewWithBackAction") as! InfoViewWithBackAction
        infoView.initialiseView(heading: title!, message: message!,handler: {
            self.alertView.isHidden = false
        })
        self.view.addSubview(infoView.view)
        self.addChild(infoView)
        infoView.view.layoutIfNeeded()
        
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        removeSuperView()
    }
    
}
