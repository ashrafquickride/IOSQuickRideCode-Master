//
//  InviteDialogue.swift
//  Quickride
//
//  Created by QuickRideMac on 15/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import UIKit
import ObjectMapper

typealias DialogDismissCompletionHandler = ()->Void

class InviteDialogue:ModelViewController,RideInvitationActionCompletionListener,UserSelectedDelegate,MatchedUserReceiver, CommunicationUtilsListener  {
    
    @IBOutlet weak var inviteHeading: UILabel!
    
    @IBOutlet weak var nameOfThePerson: UILabel!
    
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var viewUserDetails: UIView!
    
    @IBOutlet weak var verifiedBadge: UIImageView!
    
    @IBOutlet weak var companyName: UILabel!
    
    @IBOutlet weak var fromLocation: UILabel!
    
    @IBOutlet weak var toLocation: UILabel!
    
    @IBOutlet weak var ratingLabel: UILabel!
    
    @IBOutlet weak var rejectButton: UIButton!
    
    @IBOutlet weak var ratingIcon: UIImageView!
    
    @IBOutlet weak var callButton: UIButton!
    
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet var backGroundView: UIView!
    
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var matchedUserPickupTime: UILabel!
    
    @IBOutlet weak var matchedUserRideMatchPercentage: UILabel!
    
    @IBOutlet weak var matchedUserFare: UILabel!
    
    @IBOutlet weak var fareLabel: UILabel!
    
    @IBOutlet weak var fareView: UIView!
    
    @IBOutlet weak var pickUpLabelText: UILabel!
    
    @IBOutlet weak var pickUpTimeView: UIView!
    
    @IBOutlet weak var rideStartedStatusLbl: UILabel!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var profileImageForOldUser: UIImageView!
    
    @IBOutlet weak var labelNoOfRidesCompleted: UILabel!
    
    @IBOutlet weak var labelNoOfReview: UILabel!
    
    @IBOutlet weak var viewAutoInviteHeading: UIView!
    
    @IBOutlet weak var labelAutoInviteText: UILabel!
    
    @IBOutlet weak var autoInviteInfoIcon: UIImageView!
    
    var rideInvitation : RideInvitation?
    var currentUserRide : Ride?
    var isModerator = false
    var matchedUser : MatchedUser?
    var dismissHandler : DialogDismissCompletionHandler?
    var liveRideViewController : BaseLiveRideMapViewController?
    
    func initializeDataAndPresent(rideInvitation : RideInvitation,currentUserRide : Ride,liveRideViewController : BaseLiveRideMapViewController, isModerator: Bool, dismissHandler : DialogDismissCompletionHandler?){
        AppDelegate.getAppDelegate().log.debug("initializeDataAndPresent : \(rideInvitation), \(currentUserRide)")
        self.rideInvitation = rideInvitation
        self.currentUserRide = currentUserRide
        self.isModerator = isModerator
        self.dismissHandler = dismissHandler
        self.liveRideViewController = liveRideViewController
    }
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        viewAutoInviteHeading.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InviteDialogue.viewAutoInviteHeadingTapped(_:))))
        initializeViews()
        initializeDialogHeading()
        AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.RIDE_INVITE_VIEWED, params: ["userId" : QRSessionManager.getInstance()?.getUserId() ?? "" ,"requestedUserId" : String(self.rideInvitation?.invitingUserId ?? 0.0) ,"match percentage for rider" : self.rideInvitation?.matchPercentageOnRiderRoute,"match percentage for passenger": self.rideInvitation?.matchPercentageOnPassengerRoute,"from" : self.rideInvitation?.fromLoc ?? "","to" : self.rideInvitation?.toLoc ?? ""], uniqueField: User.FLD_USER_ID)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        CustomExtensionUtility.changeBtnColor(sender: self.acceptButton, color1: UIColor(netHex:0x00b557), color2: UIColor(netHex:0x008a41))
        CustomExtensionUtility.changeBtnColor(sender: self.callButton, color1: UIColor(netHex:0xF3F3F3), color2: UIColor(netHex:0xF3F3F3))
        CustomExtensionUtility.changeBtnColor(sender: self.rejectButton, color1: UIColor.white, color2: UIColor.white)
        rejectButton.addShadow()
        callButton.addShadow()
    }
    
    func checkWhetherToDisplayCallOption(){
        if matchedUser == nil || matchedUser!.enableChatAndCall == false{
            callButton.isHidden = true
            
        }else if (matchedUser!.userRole == MatchedUser.RIDER || matchedUser!.userRole == MatchedUser.REGULAR_RIDER)  && !RideManagementUtils.getUserQualifiedToDisplayContact(){
                callButton.isHidden = true
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
        }else{
            callButton.isHidden = false
        }
    }
    func gettingMatchedUser()
    {
        var rideType: String?
        var rideId : Double?
        var userId : Double?
        if currentUserRide!.rideType == Ride.RIDER_RIDE || isModerator {
            rideType = Ride.PASSENGER_RIDE
            rideId = rideInvitation?.passenegerRideId
            userId = rideInvitation?.passengerId
        }else{
            rideType = Ride.RIDER_RIDE
            rideId = rideInvitation?.rideId
            userId = rideInvitation?.riderId
        }
        self.userImage.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleBottomMargin, .flexibleRightMargin, .flexibleLeftMargin, .flexibleTopMargin]
        self.userImage.contentMode = .scaleAspectFill
        if rideInvitation!.senderImgUri == nil{
            ImageCache.getInstance().setImageToView(imageView: self.profileImageForOldUser, imageUrl: nil, gender: rideInvitation!.invitingUserGender!,imageSize: ImageCache.DIMENTION_SMALL)
        }
        else{
            ImageCache.getInstance().setImageToView(imageView: self.userImage, imageUrl: rideInvitation!.senderImgUri, gender: rideInvitation!.invitingUserGender!,imageSize: ImageCache.DIMENTION_SMALL)
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
        
        let matchedUserRetrievalTask = MatchedUserRetrievalTask(userId: userId!,rideId: rideId!, rideType: rideType!,rideInvitation: rideInvitation, matchedUserReceiver: self)
        matchedUserRetrievalTask.getMatchedUser()
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
    
    
    func initializeDataOfRiderOrRideTaker(matchedUser: MatchedUser)
    {
        self.matchedUser = matchedUser
        if matchedUser.userRole == MatchedUser.RIDER{
            if matchedUser.matchPercentage != nil{
                self.rideInvitation?.matchPercentageOnPassengerRoute = matchedUser.matchPercentage!
            }
            
        }else if matchedUser.userRole == MatchedUser.PASSENGER{
            self.rideInvitation?.matchPercentageOnPassengerRoute = matchedUser.matchPercentageOnMatchingUserRoute
        }
        
        invitedUserBasicDetailViews()
        invitingUserDetailViews()
        setTitleForContactBtn()
        
        checkAndSetPickupTimeText(matchedUser: matchedUser)
        checkWhetherToDisplayCallOption()
        var riderRideObj = currentUserRide
        if isModerator {
            riderRideObj = MyActiveRidesCache.singleCacheInstance?.getRiderRideFromRideDetailInfo(rideId: rideInvitation!.rideId!)
            if riderRideObj == nil {
                riderRideObj = currentUserRide
            }
        }
        checkAndSetMatchingPercentage(matchedUser: matchedUser,ride: riderRideObj!)
        matchedUserRideMatchPercentage.text = "\(matchedUser.matchPercentage!)%"
        checkAndSetPointsText(matchedUser: matchedUser)
        checkForRideStatusStartedAndSetStatusLabel(matchedUser: matchedUser)
        
        
    }
    
    func checkForRideStatusStartedAndSetStatusLabel(matchedUser : MatchedUser){
        AppDelegate.getAppDelegate().log.debug("checkForRideStatusStartedAndSetStatusLabel()")
        if MatchedUser.RIDER == matchedUser.userRole && Ride.RIDE_STATUS_STARTED == (matchedUser as! MatchedRider).rideStatus{
            rideStartedStatusLbl.isHidden = false
        }else{
            rideStartedStatusLbl.isHidden = true
        }
    }
    
    func checkAndSetPickupTimeText(matchedUser: MatchedUser){
        var pickupTimeString = String()
        if(matchedUser.userRole == MatchedUser.PASSENGER && matchedUser.passengerReachTimeTopickup != nil && matchedUser.passengerReachTimeTopickup != 0){
            pickupTimeString =
                DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.passengerReachTimeTopickup!, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            
        }else{
            pickupTimeString = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.pickupTime!, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }
        matchedUserPickupTime.text = pickupTimeString
    }
    func checkAndSetPointsText(matchedUser: MatchedUser)
    {
        if  matchedUser.newFare != -1{
            matchedUserFare.attributedText = FareChangeUtils.getFareDetails(newFare: StringUtils.getStringFromDouble(decimalNumber: matchedUser.newFare), actualFare: StringUtils.getStringFromDouble(decimalNumber: matchedUser.points!), textColor: matchedUserFare.textColor)
        }else{
            matchedUserFare.text = StringUtils.getStringFromDouble(decimalNumber: matchedUser.points!)
        }
    }
    
    func displayView(){
        ViewControllerUtils.addSubView(viewControllerToDisplay: self)
    }
    func updateStatus(){
        if rideInvitation?.invitationStatus != RideInvitation.RIDE_INVITATION_STATUS_READ{
            RideMatcherServiceClient.updateRideInvitationStatus(invitationId: rideInvitation!.rideInvitationId!, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_READ, viewController: nil, completionHandler: { (responseObject, error) in
            })
        }
    }
    func initializeViews(){
        gettingMatchedUser()
        backGroundView.isUserInteractionEnabled = true
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InviteDialogue.backGroundViewTapped(_:))))
        if AppConfiguration.APP_NAME != "MyRide" && currentUserRide?.rideType == Ride.RIDER_RIDE{
            self.matchedUserPickupTime.textColor = Colors.editRouteBtnColor
            self.pickUpLabelText.textColor = Colors.editRouteBtnColor
            self.pickUpTimeView.isUserInteractionEnabled = true
            self.pickUpTimeView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InviteDialogue.pickUpTimeViewTapped(_:))))
        }else{
            self.matchedUserPickupTime.textColor = UIColor.black
            self.pickUpLabelText.textColor = UIColor(netHex: 0x7A7A7A)
        }
    }
    
    @objc func pickUpTimeViewTapped(_ gesture : UITapGestureRecognizer){
        if matchedUser == nil{
            return
        }
        let storyboard = UIStoryboard(name: "Common", bundle: nil)
        let dateSelectionController:ScheduleRideViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleRideViewController") as! ScheduleRideViewController
        dateSelectionController.initializeDataBeforePresentingView(minDate: NSDate().timeIntervalSince1970, maxDate: nil, defaultDate: NSDate().timeIntervalSince1970, isDefaultDateToShow: false, delegate: nil, datePickerMode: UIDatePicker.Mode.time, datePickerTitle: nil) { (date) in
            self.matchedUser!.pickupTime = date.getTimeStamp()
            self.matchedUser!.passengerReachTimeTopickup = date.getTimeStamp()
            let rideDuration = self.matchedUser!.dropTime! - self.matchedUser!.pickupTime!
            self.matchedUser!.dropTime = NSDate(timeIntervalSince1970:   self.matchedUser!.pickupTime!/1000).getTimeStamp() + rideDuration
            self.matchedUser!.pickupTimeRecalculationRequired = false
            self.checkAndSetPickupTimeText(matchedUser: self.matchedUser!)
        }
        dateSelectionController.modalPresentationStyle = .overCurrentContext
        self.present(dateSelectionController, animated: false, completion: nil)
    }
    
    func setTitleForContactBtn(){
        self.callButton.titleLabel?.textAlignment = .center
        let isRidePartner = UserDataCache.getInstance()?.checkIsRidePartner(userId: matchedUser!.userid!)
        if CommunicationUtils.checkAndEnableCallOption(callSupport: matchedUser!.callSupport, isRidePartner: isRidePartner!) == true{
            self.callButton.setTitle(Strings.CONTACT_CAPS, for: .normal)
        }else{
            self.callButton.setTitle(Strings.CHAT_CAPS, for: .normal)
        }
    }
    @objc func backGroundViewTapped(_ gesture :UITapGestureRecognizer){
        removeSuperView()
    }
    
    func invitedUserBasicDetailViews(){
        if Int(matchedUser!.rating!) > 0{
            ratingLabel.text = String("\(matchedUser!.rating!)")
            labelNoOfReview.text = "(" + String(matchedUser!.noOfReviews) + ")"
        }else{
            ratingLabel.text = Strings.NA
            labelNoOfReview.text = ""
        }
        labelNoOfRidesCompleted.text = "\(StringUtils.getStringFromDouble(decimalNumber: matchedUser!.noOfRidesShared)) Ride(s) Completed"
        verifiedBadge.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: matchedUser!.profileVerificationData)
        companyName.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: matchedUser!.profileVerificationData, companyName: matchedUser!.companyName)
        if (matchedUser!.profileVerificationData != nil && matchedUser!.profileVerificationData!.profileVerified) || matchedUser!.verificationStatus{
            #if WERIDE
            #else
            companyName.textColor = UIColor(netHex: 0x24a647)
            #endif
            
        }else{
            #if WERIDE
            #else
            companyName.textColor = UIColor(netHex:0x968B8B)
            #endif
            
        }
    }
    
    func initializeDialogHeading(){
        if Ride.RIDER_RIDE == rideInvitation!.rideType{
            nameOfThePerson.text = rideInvitation!.invitingUserName!.capitalizingFirstLetter()
        }else{
            nameOfThePerson.text = rideInvitation!.invitingUserName!.capitalizingFirstLetter()
        }
        if rideInvitation!.autoInvite{
            autoInviteInfoIcon.image = autoInviteInfoIcon.image!.withRenderingMode(.alwaysTemplate)
            autoInviteInfoIcon.tintColor = UIColor.lightGray
            viewAutoInviteHeading.isHidden = false
            inviteHeading.isHidden = true
            if Ride.RIDER_RIDE == rideInvitation!.rideType{
                labelAutoInviteText.text = Strings.ride_auto_invited
            }else{
                labelAutoInviteText.text = Strings.ride_auto_requested
            }
        }
        else{
            viewAutoInviteHeading.isHidden = true
            inviteHeading.isHidden = false
            if Ride.RIDER_RIDE == rideInvitation!.rideType{
                inviteHeading.text = Strings.ride_invited
            }else{
                inviteHeading.text = Strings.ride_requested
            }
        }
        
    }
    
    func invitingUserDetailViews()
    {
        fromLocation.text = rideInvitation!.pickupAddress
        toLocation.text = rideInvitation!.dropAddress
        viewUserDetails.isUserInteractionEnabled = true
        viewUserDetails.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(InviteDialogue.visitProfile(_:))))
    }
    
    @objc func visitProfile(_ gesture : UITapGestureRecognizer){
        AppDelegate.getAppDelegate().log.debug("visitProfile")
        if matchedUser == nil{
            return
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
        var riderRideObj = currentUserRide
        if isModerator {
            riderRideObj = MyActiveRidesCache.singleCacheInstance?.getRiderRideFromRideDetailInfo(rideId: rideInvitation!.rideId!)
            if riderRideObj == nil {
                riderRideObj = currentUserRide
            }
        }
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController

        mainContentVC.initializeData(ride: currentUserRide!, matchedUserList: [matchedUser!], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, isFromJoinMyRide: false, selectedUserDelegate: nil)
        let drawerContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedViewController") as! RideDetailedViewController
        drawerContentVC.initializeData(ride: currentUserRide!, matchedUserList: [matchedUser!], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, isFromJoinMyRide: false, selectedUserDelegate: nil, matchedUserDataChangeDelagate: mainContentVC.self)
        ViewControllerUtils.addPulleyViewController(mainContentViewController: mainContentVC, drawerContentViewController: drawerContentVC, currentViewController: self)
    }
    func receiveMatchedUser(matchedUser: MatchedUser?, responseError: ResponseError?, error: NSError?) {
        if matchedUser != nil
        {
            initializeDataOfRiderOrRideTaker(matchedUser: matchedUser!)
        }
        else if responseError != nil {
            if responseError!.errorCode == RideValidationUtils.PASSENGER_ALREADY_JOINED_THIS_RIDE{
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                removeSuperView()
                removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED)
            } else if responseError!.errorCode == RideValidationUtils.PASSENGER_ENGAGED_IN_OTHER_RIDE || responseError!.errorCode == RideValidationUtils.INSUFFICIENT_SEATS_ERROR {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                removeSuperView()
                removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_REJECTED)
            } else if responseError!.errorCode == RideValidationUtils.RIDE_ALREADY_COMPLETED || responseError!.errorCode == RideValidationUtils.RIDE_CLOSED_ERROR || responseError!.errorCode == RideValidationUtils.RIDER_ALREADY_CROSSED_PICK_UP_POINT_ERROR {
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self)
                removeSuperView()
                removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED)
            } else if responseError!.errorCode == RideValidationUtils.RIDER_ALREADY_CROSSED_PICK_UP_POINT_ERROR{
                MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired: true, message1: Strings.crossed_pick_up_error, message2: nil, positiveActnTitle: Strings.yes_caps, negativeActionTitle: Strings.no_caps, linkButtonText: nil, viewController: self) { (actionText) in
                    if actionText == Strings.yes_caps{
                         self.continueJoining(pickupTimeRecalculationRequired: self.rideInvitation!.pickupTimeRecalculationRequired, riderHasHelmet: self.rideInvitation!.riderHasHelmet, displayPointsConfirmation: false)
                    }
                }
            }else{
                MessageDisplay.displayErrorAlert(responseError: responseError!, targetViewController: self, handler: nil)
            }
        }else{
            ErrorProcessUtils.handleError(responseObject: nil, error: error, viewController: self, handler: nil)
        }
    }
    
    func selectedUser(selectedUser: MatchedUser) {
        removeSuperView()
        if selectedUser.userRole! == MatchedUser.RIDER {
            
            if selectedUser.matchPercentage != nil{
                self.rideInvitation?.matchPercentageOnPassengerRoute = selectedUser.matchPercentage!
                self.rideInvitation?.matchPercentageOnRiderRoute =  selectedUser.matchPercentageOnMatchingUserRoute
            }
            if rideInvitation!.fareChange
            {
                if selectedUser.newFare < rideInvitation!.newFare{
                    inviteRider(selectedUser: selectedUser)
                }
                else{
                    joinedTheRide(selectedUser: selectedUser)
                }
            }
            else if (selectedUser.newFare != -1) && (selectedUser.newFare < selectedUser.points!)
            {
                inviteRider(selectedUser: selectedUser)
            }
            else{
                joinedTheRide(selectedUser: selectedUser)
            }
        }
        else if selectedUser.userRole! == MatchedUser.PASSENGER
        {
            self.rideInvitation?.matchPercentageOnPassengerRoute = selectedUser.matchPercentageOnMatchingUserRoute
            self.rideInvitation?.matchPercentageOnRiderRoute = selectedUser.matchPercentage!
            
            if (rideInvitation!.fareChange)
            {
                if (selectedUser.newFare > rideInvitation!.newFare){
                    invitePassenger(selectedUser: selectedUser)
                }
                else{
                    joinedTheRide(selectedUser: selectedUser)
                }
            }
            else if (selectedUser.newFare != -1) && (selectedUser.newFare > selectedUser.points!)
            {
                invitePassenger(selectedUser: selectedUser)
            }
            else{
                joinedTheRide(selectedUser: selectedUser)
            }
        }
    }
    func joinedTheRide(selectedUser : MatchedUser) {
        rideInvitation?.pickupTime = selectedUser.pickupTime
        rideInvitation?.dropTime = selectedUser.dropTime
        rideInvitation?.pickupLatitude = selectedUser.pickupLocationLatitude
        rideInvitation?.pickupLongitude = selectedUser.pickupLocationLongitude
        rideInvitation?.pickupAddress = selectedUser.pickupLocationAddress
        rideInvitation?.dropLatitude = selectedUser.dropLocationLatitude
        rideInvitation?.dropLongitude = selectedUser.dropLocationLongitude
        rideInvitation?.dropAddress = selectedUser.dropLocationAddress
        rideInvitation?.newFare = selectedUser.newFare
        rideInvitation?.points = selectedUser.points
        joinRide(displayPointsConfirmation : true)
    }
    func inviteRider(selectedUser : MatchedUser)
    {
        let ride = MyActiveRidesCache.singleCacheInstance?.getPassengerRide(passengerRideId: rideInvitation!.passenegerRideId!)
        if ride == nil{
            return
        }
        var selectedRiders = [MatchedRider]()
        selectedRiders.append(selectedUser as! MatchedRider)
        InviteRiderHandler(passengerRide: ride! , selectedRiders: selectedRiders, displaySpinner: true, selectedIndex: nil, viewController: self).inviteSelectedRiders(inviteHandler: { (result,error) in
        })
    }
    func invitePassenger(selectedUser : MatchedUser)
    {
        let ride = MyActiveRidesCache.singleCacheInstance?.getRiderRide(rideId: rideInvitation!.rideId!)
        if ride == nil{
            return
        }
        var selectedPassengers = [MatchedPassenger]()
        selectedPassengers.append(selectedUser as! MatchedPassenger)
        InviteSelectedPassengersAsyncTask(riderRide: ride!, selectedUsers: selectedPassengers, viewController: self, displaySpinner: true, selectedIndex: nil, invitePassengersCompletionHandler: { (error,nserror) in
        }).invitePassengersFromMatches()
    }
    func notSelected() {
        displayView()
    }
    func removeInvitationAndRefreshData( status : String){
        rideInvitation?.invitationStatus = status
        let rideInvitationStatus = RideInviteStatus(rideInvitation: rideInvitation!)
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitationStatus.invitationId)
        RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
        if self.liveRideViewController != nil{
            self.liveRideViewController!.validateAndGetRideInvites()
        }
    }
    @IBAction func callUserButtonClicked(_ sender: Any) {
        if matchedUser == nil{
            return
        }
        var isRideStarted = false
        if matchedUser!.isKind(of: MatchedRider.self) && (matchedUser as! MatchedRider).rideStatus == Ride.RIDE_STATUS_STARTED && matchedUser!.callSupport == UserProfile.SUPPORT_CALL_ALWAYS{
            isRideStarted = true
        }
        let userBasic = UserBasicInfo(userId : matchedUser!.userid!, gender : matchedUser!.gender!,userName : matchedUser!.name!, imageUri: matchedUser!.imageURI, callSupport : matchedUser!.callSupport, contactNo: Double(matchedUser!.contactNo!))
        CommunicationUtils(userBasicInfo : userBasic, isRideStarted: isRideStarted,viewController : self, delegate: self).checkAndNavigateToContactViewController()
        removeSuperView()
    }
    
    func removeSuperView() {
        if self.dismissHandler != nil
        {
            self.dismissHandler!()
        }
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    @IBAction func acceptButtonClicked(_ sender: UIButton) {
        if matchedUser == nil{
            return
        }
        if matchedUser!.userRole! == MatchedUser.RIDER {
            
            if matchedUser!.matchPercentage != nil{
                self.rideInvitation?.matchPercentageOnPassengerRoute = matchedUser!.matchPercentage!
                self.rideInvitation?.matchPercentageOnRiderRoute =  matchedUser!.matchPercentageOnMatchingUserRoute
            }
            
        }
        else if matchedUser!.userRole! == MatchedUser.PASSENGER
        {
            self.rideInvitation?.matchPercentageOnPassengerRoute = matchedUser!.matchPercentageOnMatchingUserRoute
            self.rideInvitation?.matchPercentageOnRiderRoute = matchedUser!.matchPercentage!
        }
        joinRide(displayPointsConfirmation : true)
    }
    func joinRide(displayPointsConfirmation : Bool)
    {
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil{
            clientConfiguration = ClientConfigurtion()
        }
        if matchedUser?.verificationStatus == false && matchedUser != nil && Int(matchedUser!.noOfRidesShared) <= clientConfiguration!.minNoOfRidesReqNotToShowJoiningUnverifiedDialog  && SharedPreferenceHelper.getCurrentUserGender() == User.USER_GENDER_FEMALE && SharedPreferenceHelper.getJoinWithUnverifiedUsersStatus() == false{
            let alertControllerWithCheckBox = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard,bundle: nil).instantiateViewController(withIdentifier: "AlertControllerWithCheckBox") as! AlertControllerWithCheckBox
            
            alertControllerWithCheckBox.initializeDataBeforePresenting(alertTitle: Strings.dont_show_again_title, checkBoxText: Strings.dont_show_again_checkBox_text, handler: { (result,dontShow) in
                SharedPreferenceHelper.setJoinWithUnverifiedUsersStatus(status: dontShow)
                
                
                if Strings.yes_caps == result{
                    self.continueJoin(displayPointsConfirmation: displayPointsConfirmation)
                }
                
            })

            ViewControllerUtils.addSubView(viewControllerToDisplay: alertControllerWithCheckBox)
            
        }else{
            self.continueJoin(displayPointsConfirmation: displayPointsConfirmation)
        }
    }
    func continueJoin(displayPointsConfirmation : Bool){
        var riderHasHelmet = false
        if matchedUser?.userRole == MatchedUser.RIDER || matchedUser?.userRole == MatchedUser.REGULAR_RIDER
        {
            if matchedUser?.userRole == MatchedUser.RIDER{
                riderHasHelmet = (matchedUser as! MatchedRider).riderHasHelmet
            }else{
                riderHasHelmet = (matchedUser as! MatchedRegularRider).riderHasHelmet
            }
        }
        rideInvitation!.pickupTime = matchedUser!.pickupTime
        continueJoining(pickupTimeRecalculationRequired: self.matchedUser!.pickupTimeRecalculationRequired, riderHasHelmet: riderHasHelmet, displayPointsConfirmation: displayPointsConfirmation)

    }
    
    func continueJoining(pickupTimeRecalculationRequired : Bool,riderHasHelmet : Bool,displayPointsConfirmation : Bool){
        let joinPassengerToRideHandler = JoinPassengerToRideHandler(viewController: self, riderRideId: rideInvitation!.rideId!, riderId: rideInvitation!.riderId!, passengerRideId: rideInvitation!.passenegerRideId!, passengerId: rideInvitation!.passengerId!, rideType: rideInvitation!.rideType, pickupAddress: rideInvitation!.pickupAddress, pickupLatitude: rideInvitation!.pickupLatitude!, pickupLongitude: rideInvitation!.pickupLongitude!, pickupTime: rideInvitation!.pickupTime!, dropAddress: rideInvitation!.dropAddress, dropLatitude: rideInvitation!.dropLatitude!, dropLongitude: rideInvitation!.dropLongitude!, dropTime: rideInvitation!.dropTime!, matchingDistance: rideInvitation!.matchedDistance!, points: rideInvitation!.points!,newFare: (rideInvitation?.newFare)!, noOfSeats: rideInvitation!.noOfSeats!, rideInvitationId: rideInvitation!.rideInvitationId!,invitingUserName: rideInvitation!.invitingUserName! ,invitingUserId :rideInvitation!.invitingUserId!,displayPointsConfirmationAlert: displayPointsConfirmation, riderHasHelmet: riderHasHelmet, pickupTimeRecalculationRequired: pickupTimeRecalculationRequired, passengerRouteMatchPercentage: rideInvitation!.matchPercentageOnPassengerRoute, riderRouteMatchPercentage: rideInvitation!.matchPercentageOnRiderRoute, moderatorId: isModerator ? QRSessionManager.getInstance()?.getUserId() : nil , listener :self)
        
        joinPassengerToRideHandler.joinPassengerToRide()
    }
    @IBAction func rejectButtonClicked(_ sender: UIButton) {
        rejectRideInvite()
    }
    func rejectRideInvite()
    {
        var rideType :  String?
        if rideInvitation!.rideType == Ride.RIDER_RIDE
        {
            rideType = Ride.PASSENGER_RIDE
        }
        else
        {
            rideType = Ride.RIDER_RIDE
        }
        let rejectReasonAlertController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "RejectCustomAlertController")as! RejectCustomAlertController
        rejectReasonAlertController.initializeDataBeforePresentingView(title: Strings.do_u_have_reason, positiveBtnTitle: Strings.confirm_caps, negativeBtnTitle: Strings.skip_caps, viewController: ViewControllerUtils.getCenterViewController(), rideType: rideType) { (text, result) in
            
            if result == Strings.confirm_caps{
                self.completeRejectAction(rejectReason: text)
            }
        }
    }
    func rejectUser(selectedUser: MatchedUser) {
        rejectRideInvite()
    }
    
    func completeRejectAction(rejectReason : String?){
        if Ride.RIDER_RIDE == self.currentUserRide!.rideType || isModerator {
            let riderRejectPassengerInvitationTask = RiderRejectPassengerInvitationTask(rideInvitation: rideInvitation!, moderatorId: isModerator ? QRSessionManager.getInstance()?.getUserId() : nil, viewController: self, rideRejectReason: rejectReason, rideInvitationActionCompletionListener: self)
            riderRejectPassengerInvitationTask.rejectPassengerInvitation()
        } else {
            let passengerRejectRiderInvitationTask = PassengerRejectRiderInvitationTask(rideInvitation: rideInvitation!, viewController: self, rideRejectReason: rejectReason, rideInvitationActionCompletionListener: self)
            passengerRejectRiderInvitationTask.rejectRiderInvitation()
        }
    }
    
    func rideInviteAcceptCompleted(rideInvitationId : Double) {
        QuickRideProgressSpinner.stopSpinner()
        removeSuperView()
        removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED)
    }
    func rideInviteRejectCompleted(rideInvitation : RideInvitation) {
        UIApplication.shared.keyWindow?.makeToast(message: Strings.ride_invite_rejected, duration: 3.0, position: CGPoint(x: self.view.frame.size.width/2, y: self.view.frame.size.height-200))
        removeSuperView()
        removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_REJECTED)
    }
    
    
    func rideInviteActionFailed(responseError: ResponseError?, error: NSError?, isNotificationRemovable : Bool) {
        QuickRideProgressSpinner.stopSpinner()
        removeSuperView()
        if responseError != nil{
            if responseError!.errorCode == RideValidationUtils.PASSENGER_ALREADY_JOINED_THIS_RIDE{
                self.removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED)
            } else if responseError!.errorCode == RideValidationUtils.PASSENGER_ENGAGED_IN_OTHER_RIDE || responseError!.errorCode == RideValidationUtils.INSUFFICIENT_SEATS_ERROR {
                self.removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_REJECTED)
            } else if responseError!.errorCode == RideValidationUtils.RIDE_ALREADY_COMPLETED || responseError!.errorCode == RideValidationUtils.RIDER_ALREADY_CROSSED_PICK_UP_POINT_ERROR || responseError!.errorCode == RideValidationUtils.RIDE_CLOSED_ERROR {
                self.removeInvitationAndRefreshData(status: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED)
            }
        }
    }
    
    func rideInviteActionCancelled() { }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return false
    }
    func userSelected() {
        joinRide(displayPointsConfirmation: true)
    }
    func textField(_ textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let threshold = 250
        
        let currentCharacterCount = textField.text?.count ?? 0
        if (range.length + range.location > currentCharacterCount){
            return false
        }
        let newLength = currentCharacterCount + string.count - range.length
        return newLength <= threshold
    }
    @IBAction func rideNotesTapped(_ sender: Any) {
        if matchedUser == nil || matchedUser!.rideNotes == nil{
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
