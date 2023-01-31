//
//  UserDetailForRiderAndPassengerCardTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 18/05/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import Lottie
import MessageUI
import CoreLocation
import ObjectMapper
import FTPopOverMenu_Swift

class UserDetailForRiderAndPassengerCardTableViewCell: UITableViewCell {

    //MARK: Outlets
    //MARK: User detail View
    @IBOutlet weak var matchingOptionsLoadingAnimationView: AnimatedControl!
    @IBOutlet weak var passengersCollectionViewForRider: UICollectionView!
    @IBOutlet weak var noOfMatchesAvailable: UIButton!
    @IBOutlet weak var labelInviteMatchedUsers: UILabel!
    @IBOutlet weak var labelFindMatchedUser: UILabel!
    @IBOutlet weak var inviteMatchedUsersView: UIView!
    @IBOutlet weak var inviteMatchedUsersViewWidth: NSLayoutConstraint!
    @IBOutlet weak var imageViewFindMatchedUser: UIImageView!

    //MARK: Auto match view
    @IBOutlet weak var autoMatchLabel: UILabel!
    @IBOutlet weak var autoMatchProgressLabel: MarqueeLabel!
    @IBOutlet weak var autoMatchView: UIView!
    @IBOutlet weak var autoMatchSwitch: UISwitch!
    @IBOutlet weak var autoMatchIcon: UIImageView!
    @IBOutlet weak var autoMatchViewHeighConstraint: NSLayoutConstraint!

    //    MARK: Passenger Eta Info
    @IBOutlet weak var passengerDetailViewForRider: UIView!
    @IBOutlet weak var passengerDetailViewForRiderHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonMore: UIButton!
    @IBOutlet weak var buttonContactPassenger: UIButton!

    @IBOutlet weak var pickupNoteOrVehicleDetailsLabel: MarqueeLabel!
    @IBOutlet weak var labelNextPickupOrRideStatus: UILabel!
    @IBOutlet weak var labelRideTakerDistanceToPickupPointOrRiderName: UILabel!
    @IBOutlet weak var pickupButton: UIButton!

    @IBOutlet weak var rideMatchesLabel: UILabel!

    @IBOutlet weak var rideMatchesLabelHeight: NSLayoutConstraint!

    @IBOutlet weak var selectedPickupNotch: UIImageView!

    @IBOutlet weak var selectedPickupNotchLeadingConstraint: NSLayoutConstraint!

    @IBOutlet weak var verifyOrgEmailView: UIView!
    @IBOutlet weak var rideMatchesLabelTopHeigntConstraint: NSLayoutConstraint!

    private var viewModel = UserDetailForRiderAndPassengerCardViewModel()

    func initiateData(currentUserRide: Ride, isFromRideCreation: Bool) {
        viewModel = UserDetailForRiderAndPassengerCardViewModel(currentUserRide: currentUserRide, isFromRideCreation: isFromRideCreation)
        setUpUI()
    }

    //MARK: Methods
    private func setUpUI() {
        initializeRideMatchesUI()
        addObserverForTaxiPool()
        self.updateAutoMatchStatus(matchesCount: 0)
        initialzeAvaialbelRideMatchesAndCountUI()
        handleVisibilityForFreezeIcon()
        handleEtaShowingToRider()
        if let profileVerificationData = UserDataCache.getInstance()?.userProfile?.profileVerificationData, (profileVerificationData.emailVerifiedAtleastOnce || profileVerificationData.emailVerificationStatus == EndorsableUser.STATUS_VERIFIED_CAPS){
            verifyOrgEmailView.isHidden = true
        }else{
            verifyOrgEmailView.isHidden = false
        }
    }

    private func addObserverForTaxiPool() {
        if viewModel.currentUserRide is PassengerRide {
            NotificationCenter.default.addObserver(self, selector: #selector(taxiInvitationReceived), name: .taxiInvitationReceived, object: nil)
        }
    }

    @objc func taxiInvitationReceived(_ notification: Notification){
        viewModel.getTaxiPoolInvitation()
        showPassengerAndInviteCollectionView()
    }

    private func initializeRideMatchesUI(){
        passengersCollectionViewForRider.register(UINib(nibName: "RiderAndPassengerCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "RiderAndPassengerCollectionViewCell")
        passengersCollectionViewForRider.register(UINib(nibName: "EmptyPassengerTaxiPoolCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "EmptyPassengerTaxiPoolCollectionViewCell")
        showPassengerAndInviteCollectionView()
        NotificationCenter.default.addObserver(forName: .rideMatchesUpdated, object: viewModel, queue: nil) { (notification) in
            self.showPassengerAndInviteCollectionView()
        }
    }
    fileprivate func showPassengerAndInviteCollectionView() {
        if viewModel.isRideMatchesAvaiable() {
            labelFindMatchedUser.isHidden = true
            passengersCollectionViewForRider.isHidden = false
            passengersCollectionViewForRider.dataSource = self
            passengersCollectionViewForRider.delegate = self
            passengersCollectionViewForRider.reloadData()
        } else {
            passengersCollectionViewForRider.isHidden = true

        }
    }

    private func initialzeAvaialbelRideMatchesAndCountUI(){

        if viewModel.isModerator {
            self.inviteMatchedUsersView.isHidden = true
            inviteMatchedUsersViewWidth.constant = 0
            return
        }
        if !viewModel.isPassengerAdditionAllowed() && !viewModel.isRideJoinAllowed(){
            self.inviteMatchedUsersView.isHidden = true
            inviteMatchedUsersViewWidth.constant = 0
            return
        }
        if viewModel.currentUserRide.rideType == Ride.RIDER_RIDE, let riderRide = viewModel.currentUserRide as? RiderRide, riderRide.freezeRide{
            return
        }

        ViewCustomizationUtils.addBorderToView(view: noOfMatchesAvailable, borderWidth: 2.0, color: UIColor.white)
        ViewCustomizationUtils.addCornerRadiusToView(view: noOfMatchesAvailable, cornerRadius: 10)
        imageViewFindMatchedUser.isUserInteractionEnabled = true
        imageViewFindMatchedUser.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(movetoInviteViewController(_:))))

        if viewModel.currentUserRide.rideType == Ride.RIDER_RIDE{
            imageViewFindMatchedUser.image = UIImage(named: "find_matched_ridetakers_gray")
            labelInviteMatchedUsers.text = Strings.invite
        }
        else{
            imageViewFindMatchedUser.image = UIImage(named: "find_matched_riders_gray")
            labelInviteMatchedUsers.text = Strings.find_rider
        }
        NotificationCenter.default.addObserver(forName: .matchedUsersToInviteResult, object: viewModel, queue: nil) { (notification) in
            self.matchingOptionsLoadingAnimationView.isHidden = true
            self.matchingOptionsLoadingAnimationView.animationView.stop()
            guard let userInfo = notification.userInfo else {
                return
            }
            if userInfo[UserDetailForRiderAndPassengerCardViewModel.SERVER_ERROR] != nil || userInfo[UserDetailForRiderAndPassengerCardViewModel.NS_ERROR] != nil{
                self.failedToFindRideMatchesToJoin()
                self.updateAutoMatchStatus(matchesCount: 0)
            }else {
                let matchedUsersCount = userInfo[UserDetailForRiderAndPassengerCardViewModel.RIDE_MATCHES_COUNT]
                let currentMatchBucket = userInfo[UserDetailForRiderAndPassengerCardViewModel.RIDE_MATCHES_BUCKET]

                self.showMatchedUsersOnResult(matchedUsersCount: matchedUsersCount as? Int ?? 0, currentMatchBucket: currentMatchBucket as? Int ?? 0)
                self.updateAutoMatchStatus(matchesCount: matchedUsersCount as! Int)
            }
        }
        showMatchedUsersRetrieveInProgressView()
        viewModel.findRideMatchesToInvite()
    }
    private func showMatchedUsersRetrieveInProgressView(){
        matchingOptionsLoadingAnimationView.isHidden = false
        matchingOptionsLoadingAnimationView.animationView.animation = Animation.named("loader")
        matchingOptionsLoadingAnimationView.animationView.play()
        matchingOptionsLoadingAnimationView.animationView.loopMode = .loop
        noOfMatchesAvailable.isHidden = true
        if viewModel.isRideMatchesAvaiable() {
            labelFindMatchedUser.isHidden = true
        }else {
            labelFindMatchedUser.isHidden = false
            if viewModel.currentUserRide.rideType == Ride.PASSENGER_RIDE {
                labelFindMatchedUser.text = "Finding riders in your route..."
            } else {
                labelFindMatchedUser.text = "Finding carpool takers in your route..."
            }
        }

    }

    private func failedToFindRideMatchesToJoin() {
        noOfMatchesAvailable.isHidden = true
        if viewModel.isRideMatchesAvaiable(){
            labelFindMatchedUser.isHidden = true
            return
        }
        labelFindMatchedUser.isHidden = false
        let message = Strings.matching_options_retrieval_failure
        let attributedString = NSMutableAttributedString(string: message)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.4
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x2196F3), textSize: 14), range: (message as NSString).range(of: Strings.invite_by_contacts))
        labelFindMatchedUser.attributedText = attributedString
        labelFindMatchedUser.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToInviteByContact(_:))))

    }


    private func showMatchedUsersOnResult(matchedUsersCount : Int, currentMatchBucket : Int){

        updateAutoMatchStatus(matchesCount: matchedUsersCount)
        if matchedUsersCount == 0 {
            displayNoMatchingOptions()
        }else{
            displayMatchingOptionsAvaialble(matchedUsersCount : matchedUsersCount, currentMatchBucket : currentMatchBucket)
        }

    }
    private func displayNoMatchingOptions(){
        AppDelegate.getAppDelegate().log.debug("")
            noOfMatchesAvailable.setTitle(nil, for: .normal)
        noOfMatchesAvailable.isHidden = true
        if viewModel.isRideMatchesAvaiable() {
            labelFindMatchedUser.isHidden = true
            return
        }
        labelFindMatchedUser.isHidden = false
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2
        paragraphStyle.lineHeightMultiple = 1.4
        var message : String
        if viewModel.currentUserRide.rideType == Ride.RIDER_RIDE {
            message = Strings.zero_matching_options_for_rider
        }else {
            message = Strings.zero_matching_options_for_ridetaker
        }
        let attributedString = NSMutableAttributedString(string: message)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        attributedString.addAttributes(ViewCustomizationUtils.createNSAtrribute(textColor: UIColor(netHex:0x2196F3), textSize: 14), range: (message as NSString).range(of: Strings.invite_by_contacts))
        labelFindMatchedUser.attributedText = attributedString
        labelFindMatchedUser.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(moveToInviteByContact(_:))))

    }

    func displayMatchingOptionsAvaialble(matchedUsersCount : Int, currentMatchBucket : Int) {
        noOfMatchesAvailable.isHidden = false
        if currentMatchBucket != MatchedRidersResultHolder.CURRENT_MATCH_BUCKET_ALL_MATCH {
            noOfMatchesAvailable.setTitle(String(matchedUsersCount) + "+", for: .normal)
        }else{
            noOfMatchesAvailable.setTitle(String(matchedUsersCount), for: .normal)
        }
        if viewModel.isRideMatchesAvaiable() {
            labelFindMatchedUser.isHidden = true
            return
        }
        labelFindMatchedUser.isHidden = false
        if viewModel.currentUserRide.rideType == Ride.PASSENGER_RIDE {
            labelFindMatchedUser.text = "Yay! \nFound \(matchedUsersCount) riders to join your ride."
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            paragraphStyle.lineHeightMultiple = 1.4
            let attributedString = NSMutableAttributedString(string: labelFindMatchedUser.text!)
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            labelFindMatchedUser.attributedText = attributedString
        } else {
            labelFindMatchedUser.text = "Yay! \nFound \(matchedUsersCount) ride takers to join your ride"
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 2
            paragraphStyle.lineHeightMultiple = 1.4
            let attributedString = NSMutableAttributedString(string: labelFindMatchedUser.text!)
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
            labelFindMatchedUser.attributedText = attributedString
        }
    }

    @objc func moveToInviteByContact(_ gesture :UITapGestureRecognizer){
        let inviteContactsAndGroupViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "InviteContactsAndGroupViewController") as! InviteContactsAndGroupViewController
        inviteContactsAndGroupViewController.initailizeView(ride: viewModel.currentUserRide,taxiRide: nil)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: inviteContactsAndGroupViewController, animated: false)
    }

    @objc func movetoInviteViewController(_ gesture :UITapGestureRecognizer){
        moveToInvite(isFromContacts: false)
    }


    //MARK: Actions
    @IBAction func passengerDetailsMoreButtonTapped(_ sender: UIButton) {
        if let rideParticipant = viewModel.getPassengerRideParticipant(participantId: viewModel.selectedPassengerId){
            contactSelectedPassenger(rideParticipant: rideParticipant, view: sender)
        }
    }

    @IBAction func pickupButtonTapped(_ sender: UIButton) {
        if let passengerInfo = viewModel.getPassengerRideParticipant(participantId :  viewModel.selectedPassengerId) {
            updatePassengerStatusByRider(rideParticipant: passengerInfo, status: Ride.RIDE_STATUS_STARTED, riderRideId: viewModel.getRiderRideId())
        }
    }

    @IBAction func contactToPassengerButtonTapped(_ sender: UIButton) {
        guard let passengerInfo = viewModel.getPassengerRideParticipant(participantId :  viewModel.selectedPassengerId),let contactName = passengerInfo.name else {
            return
        }
        if passengerInfo.isCallOptionEnabled() {
        AppUtilConnect.callNumber(receiverId:  StringUtils.getStringFromDouble(decimalNumber: passengerInfo.userId),refId: viewModel.currentUserRide.rideType!+StringUtils.getStringFromDouble(decimalNumber: viewModel.currentUserRide.rideId), name: contactName, targetViewController: parentViewController!)
        } else{
            let appDelegate : AppDelegate = UIApplication.shared.delegate as! AppDelegate
            MessageDisplay.displayAlert(messageString: Strings.call_Option_Disabled_Message, viewController: appDelegate.window?.rootViewController, handler: nil)
        }

    }



    func passengerSelected(rideParticipant: RideParticipant, view : UIView) {
        viewModel.selectedPassengerId = rideParticipant.userId
        if viewModel.isModerator || viewModel.currentUserRide.status == Ride.RIDE_STATUS_STARTED {
            viewModel.selectedPassengerId = rideParticipant.userId
            if rideParticipant.status == Ride.RIDE_STATUS_SCHEDULED || rideParticipant.status == Ride.RIDE_STATUS_DELAYED{
                handleEtaShowingToRider()
            }else{
                hidePassengerPickupInfoView()
            }

            if passengerDetailViewForRider.isHidden{
                contactSelectedPassenger(rideParticipant: rideParticipant,view : view)
            }
        }else{
            contactSelectedPassenger(rideParticipant: rideParticipant,view : view)
        }
    }
    func contactSelectedPassenger(rideParticipant : RideParticipant, view : UIView){
        let actions = viewModel.getApplicableActionOnPassengerSelection(rideParticipant: rideParticipant)

        let configuration = FTConfiguration.shared
        configuration.backgoundTintColor = UIColor.black
        configuration.menuSeparatorColor = UIColor.white
        configuration.menuSeparatorInset = UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: 0)
        FTPopOverMenu.showForSender(sender: view,with: actions, done: { (selectedIndex) -> () in
            self.handleRideParticiapantAction(selectedType: actions[selectedIndex], rideParticipant: rideParticipant)
        }, cancel: {

        })

    }
    func handleRideParticiapantAction(selectedType: String,rideParticipant: RideParticipant){

        guard let viewController = parentViewController else {
            return
        }
        switch selectedType {
        case Strings.droppedOff:
            self.updatePassengerStatusByRider(rideParticipant: rideParticipant, status: Ride.RIDE_STATUS_COMPLETED, riderRideId: viewModel.getRiderRideId())
        case Strings.contact:
            LiveRideViewControllerUtils.showContactOptionView(ride: viewModel.currentUserRide, rideParticipant: rideParticipant, viewController: viewController)
        case Strings.smsLabel:
            UserDataCache.getInstance()?.getContactNo(userId: StringUtils.getStringFromDouble(decimalNumber: rideParticipant.userId), handler: { (contactNo) in
                LiveRideViewControllerUtils.sendSMS(phoneNumber: contactNo, message: "", viewController: viewController)
            })
        case Strings.profile:
            LiveRideViewControllerUtils.displayConnectedUserProfile(rideParticipant: rideParticipant, riderRide: viewModel.rideDetailInfo?.riderRide, viewController: viewController)
        case Strings.unjoin, Strings.unjoin+" " + (rideParticipant.name ?? ""):
            unjoinPassengerFromRide(rideParticipant: rideParticipant)
        case Strings.route:
            moveToSelectedUserRouteView(rideParticipant: rideParticipant)
        case Strings.ride_notes:
            MessageDisplay.displayInfoDialogue(title: Strings.ride_notes, message: rideParticipant.rideNote, viewController: nil)
        case String(format: Strings.rate_user, arguments: [rideParticipant.name ?? ""]):
            let systemFeedbackViewController = UIStoryboard(name: "SystemFeedback", bundle: nil).instantiateViewController(withIdentifier: "DirectUserFeedbackViewController") as! DirectUserFeedbackViewController
            systemFeedbackViewController.initializeDataAndPresent(name: rideParticipant.name ?? "",imageURI: rideParticipant.imageURI,gender: rideParticipant.gender ?? "U",userId: rideParticipant.userId, rideId: rideParticipant.riderRideId)
            ViewControllerUtils.addSubView(viewControllerToDisplay: systemFeedbackViewController)
        default:
            break
        }
    }

    func updatePassengerStatusByRider(rideParticipant: RideParticipant, status: String, riderRideId: Double){
        if status == Ride.RIDE_STATUS_STARTED && RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: rideParticipant, ride: viewModel.currentUserRide, riderProfile: UserDataCache.getInstance()?.getLoggedInUserProfile()) {
            let otpToPickupViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "OTPToPickupViewController") as! OTPToPickupViewController
            otpToPickupViewController.initializeData(rideParticipant: rideParticipant, riderRideId: riderRideId, isFromMultiPickup: false, passengerPickupDelegate: nil)
            ViewControllerUtils.addSubView(viewControllerToDisplay: otpToPickupViewController)
        } else {
            QuickRideProgressSpinner.startSpinner()
            viewModel.updatePassengerRideStatus(rideParticipant: rideParticipant, status: status) { (responseError, error) in
                QuickRideProgressSpinner.stopSpinner()
                if let responseError = responseError, responseError.errorCode == RideValidationUtils.RIDER_PICKED_UP_ERROR{
                    MessageDisplay.displayInfoViewAlert(title: "", titleColor: nil, message: String(format: Strings.rider_picked_up_error, arguments: [rideParticipant.name!,rideParticipant.name!]), infoImage: nil, imageColor: nil, isLinkBtnRequired: false, linkTxt: nil, linkImage: nil, buttonTitle: Strings.got_it_caps) {
                    }
                } else if responseError != nil || error != nil {
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self.parentViewController)
                }
            }
        }
    }



    private func moveToSelectedUserRouteView(rideParticipant : RideParticipant){

        let rideRouteDisplayViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RidePathDisplayViewController") as! RidePathDisplayViewController
        rideRouteDisplayViewController.initializeDataBeforePresenting(currentUserRidePath: viewModel.currentUserRide.routePathPolyline, joinedUserRidePath: nil, currentUserRideType: viewModel.currentUserRide.rideType!, currentUserRideId: viewModel.currentUserRide.rideId, joinedUserRideId: rideParticipant.rideId, pickUp: CLLocationCoordinate2D(latitude: rideParticipant.startPoint!.latitude, longitude: rideParticipant.startPoint!.longitude),drop: CLLocationCoordinate2D(latitude: rideParticipant.endPoint!.latitude, longitude: rideParticipant.endPoint!.longitude), points: rideParticipant.points!)
        parentViewController?.present(rideRouteDisplayViewController, animated: false, completion: nil)
    }
    private func unjoinPassengerFromRide(rideParticipant : RideParticipant){
        let rideCancellationAndUnJoinViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RideCancellationAndUnJoinViewController") as! RideCancellationAndUnJoinViewController

        rideCancellationAndUnJoinViewController.initializeDataForUnjoin(rideParticipants: viewModel.passengersInfo, rideType: viewModel.currentUserRide.rideType, ride: viewModel.currentUserRide, riderRideId: viewModel.getRiderRideId(), unjoiningUserRideId: rideParticipant.rideId, unjoiningUserId: rideParticipant.userId, unjoiningUserRideType: Ride.RIDER_RIDE) {
                }
                ViewControllerUtils.addSubView(viewControllerToDisplay: rideCancellationAndUnJoinViewController)
    }

    func incomingInvitationSelected(rideInvitation: RideInvitation) {
        QuickRideProgressSpinner.startSpinner()
        
        RideInviteCache.getInstance().getRideInviteFromServer(id: rideInvitation.rideInvitationId) { (invite,responseError, error) in
            
            if responseError != nil || error != nil {
                QuickRideProgressSpinner.stopSpinner()
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self.parentViewController)
                return
            }
            guard let invite = invite else {
                QuickRideProgressSpinner.stopSpinner()
                return
            }
            self.viewModel.getMatchedUserForInvite(rideInvitation: invite) { (matchedUser, responseError, error) in
                QuickRideProgressSpinner.stopSpinner()
                guard let matchedUserObj = matchedUser else {
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self.parentViewController)
                    return
                }
                var matchedUserList = [MatchedUser]()
                matchedUserList.append(matchedUserObj)
                if rideInvitation.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED_AND_PAYMENT_PENDING {
                    self.moveToRideDetailView(matchedUser: matchedUserList,viewType : .PaymentPendingView, inviteId: rideInvitation.rideInvitationId)
                }else {
                    self.viewModel.updateRideInvitationStatusAsSeen(rideInvitation: rideInvitation)
                    self.moveToRideDetailView(matchedUser: matchedUserList,viewType : .RideInviteView, inviteId: rideInvitation.rideInvitationId)
                }
            }
        }
    }
    func moveToRideDetailView(matchedUser: [MatchedUser],viewType: DetailViewType,inviteId : Double) {
           let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
        mainContentVC.initializeData(ride: viewModel.currentUserRide, matchedUserList: matchedUser, viewType: viewType, selectedIndex: 0, startAndEndChangeRequired: false, selectedUserDelegate: nil,rideInviteId: inviteId)
        ViewControllerUtils.displayViewController(currentViewController: self.parentViewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
       }

    func outGoingInvitationSelected(rideInvitation: RideInvitation) {


        QuickRideProgressSpinner.startSpinner()
        RideInviteCache.getInstance().getRideInviteFromServer(id: rideInvitation.rideInvitationId) { (invite,responseError, error) in
            
            if responseError != nil || error != nil{
                QuickRideProgressSpinner.stopSpinner()
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self.parentViewController)
                return
            }
            guard let invite = invite else {
                QuickRideProgressSpinner.stopSpinner()
                return
            }
            self.viewModel.getMatchedUserForInvite(rideInvitation: invite) { (matchedUser, responseError, error) in
                QuickRideProgressSpinner.stopSpinner()
                guard let matchedUserObj = matchedUser else {
                    ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self.parentViewController)
                    return
                }
                var matchedUserList = [MatchedUser]()
                matchedUserList.append(matchedUserObj)
                if rideInvitation.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED_AND_PAYMENT_PENDING {
                    self.moveToPayToConfirmRideView(rideInvitation: rideInvitation)
                }else {
                    self.moveToRideDetailView(matchedUser: matchedUserList,viewType: .RideDetailView, inviteId: rideInvitation.rideInvitationId)
                }
            }

        }

    }
    
    private func moveToPayToConfirmRideView(rideInvitation: RideInvitation){
        let payToConfirmRideViewController = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "PayToConfirmRideViewController") as! PayToConfirmRideViewController
        payToConfirmRideViewController.initialiseData(rideInvitation: rideInvitation) 
        payToConfirmRideViewController.modalPresentationStyle = .overFullScreen
        ViewControllerUtils.addSubView(viewControllerToDisplay: payToConfirmRideViewController)
    }

    func moveToInvite(isFromContacts: Bool) {

        guard let viewController = parentViewController else {
            return
        }
        if let riderRide = viewModel.currentUserRide as? RiderRide, riderRide.freezeRide {
            UIApplication.shared.keyWindow?.makeToast("Ride is frozen", point: CGPoint(x: viewController.view.frame.size.width/2, y: viewController.view.frame.size.height-180), title: nil, image: nil, completion: nil)
            return

        }
        if QRReachability.isConnectedToNetwork() == false{
            UIApplication.shared.keyWindow?.makeToast(Strings.DATA_CONNECTION_NOT_AVAILABLE, point: CGPoint(x: viewController.view.frame.size.width/2, y: viewController.view.frame.size.height-180), title: nil, image: nil, completion: nil)
            return
        }

        let sendInviteBaseViewController = UIStoryboard(name: StoryBoardIdentifiers.liveRide_storyboard, bundle: nil).instantiateViewController(withIdentifier: "SendInviteBaseViewController") as! SendInviteBaseViewController
        sendInviteBaseViewController.initializeDataBeforePresenting(scheduleRide: viewModel.currentUserRide, isFromCanceRide: false, isFromRideCreation: viewModel.isFromRideCreation)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: sendInviteBaseViewController, animated: false)
    }

    @IBAction func verifyEmailButtonTapped(_ sender: Any) {
        let verifyProfileViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "VerifyProfileViewController") as! VerifyProfileViewController
       verifyProfileViewController.intialData(isFromSignUpFlow: false)
        self.parentViewController?.navigationController?.pushViewController(verifyProfileViewController, animated: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
//MARK: Passenger info and Eta Showing For Started Ride
extension UserDetailForRiderAndPassengerCardTableViewCell {
    fileprivate func getTitleForNexPickupPosition( nextPickupIndex : Int) -> String {
        if viewModel.passengersInfo.count == 1{
            return "NEXT PICKUP"
        }
        var index = nextPickupIndex
        if viewModel.isModerator {
            index = nextPickupIndex - 1
        }
        switch index {
        case 0:
            return "FIRST PICKUP"
        case 1:
            return "SECOND PICKUP"
        case 2:
            return "THIRD PICKUP"
        case 3:
            return "FOURTH PICKUP"
        case 4:
            return "FIFTH PICKUP"
        case 6:
            return "SIXTH PICKUP"
        default:
            return "OTHER PICKUP"
        }
    }

    func handleEtaShowingToRider() {

        guard let riderCurrentLocation = RideViewUtils.getRideParticipantLocationFromRideParticipantLocationObjects(participantId: viewModel.getRiderId(), rideParticipantLocations: viewModel.rideDetailInfo?.rideParticipantLocations) else {
            hidePassengerPickupInfoView()
            return
        }
        if !viewModel.isETAvaialbleForNextPickup(riderCurrentLocation : riderCurrentLocation){
            hidePassengerPickupInfoView()
            return
        }

        let nextPassengerIdToPickup = viewModel.getNextPassengerIdToPickup(riderCurrentLocation: riderCurrentLocation)
        if nextPassengerIdToPickup.0 == 0 {
            hidePassengerPickupInfoView()
            return
        }
        guard let rideParticipant = viewModel.getPassengerRideParticipant(participantId: nextPassengerIdToPickup.0) else {
            hidePassengerPickupInfoView()
            return
        }
        if let nextPickupParticipantETAInfo = viewModel.getParticipantETAInfoFor(passengerId: nextPassengerIdToPickup.0, riderCurrentLocation: riderCurrentLocation) {
            displayNextPassengerETA(nextPassengerIdToPickup: nextPassengerIdToPickup, rideParticipant: rideParticipant, nextPickupParticipantETAInfo: nextPickupParticipantETAInfo,riderCurrentLocation: riderCurrentLocation)
        } else {
            viewModel.getNextPassengerETAFromServer(participantId: nextPassengerIdToPickup.0, startLat: riderCurrentLocation.latitude!, startLng: riderCurrentLocation.longitude!, endLat: rideParticipant.startPoint!.latitude, endLng: rideParticipant.startPoint!.longitude) { etaInfo in
                self.displayNextPassengerETA(nextPassengerIdToPickup: nextPassengerIdToPickup, rideParticipant: rideParticipant, nextPickupParticipantETAInfo: etaInfo,riderCurrentLocation: riderCurrentLocation)
            }

        }


    }

    func displayNextPassengerETA(nextPassengerIdToPickup: (Double, Int),rideParticipant: RideParticipant,nextPickupParticipantETAInfo: ParticipantETAInfo, riderCurrentLocation: RideParticipantLocation) {
        guard let _ = passengersCollectionViewForRider.cellForItem(at: IndexPath(item: nextPassengerIdToPickup.1, section: 1)) as? RiderAndPassengerCollectionViewCell else {
            hidePassengerPickupInfoView()
            return
        }
        rideMatchesLabel.isHidden = true
        rideMatchesLabelHeight.constant = 0
        passengerDetailViewForRider.isHidden = false
        pickupButton.isHidden  = false
        passengersCollectionViewForRider.scrollToItem(at: IndexPath(item: nextPassengerIdToPickup.1, section: 1), at: .right, animated: false)
        setSelectedAnchorForNextPickup(selectedPassengerIndex: nextPassengerIdToPickup.1)
        let otpRequired = RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: rideParticipant, ride: viewModel.currentUserRide, riderProfile: UserDataCache.getInstance()?.getLoggedInUserProfile())
        labelNextPickupOrRideStatus.text = getTitleForNexPickupPosition(nextPickupIndex: nextPassengerIdToPickup.1)
        if otpRequired {
            labelNextPickupOrRideStatus.text?.append(" - OTP REQUIRED")
        }
        if rideParticipant.pickupNote != nil {
            passengerDetailViewForRiderHeightConstraint.constant = 60
            rideMatchesLabelTopHeigntConstraint.constant = 0
            pickupNoteOrVehicleDetailsLabel.isHidden = false
            pickupNoteOrVehicleDetailsLabel.textColor = UIColor.black
            pickupNoteOrVehicleDetailsLabel.text = rideParticipant.pickupNote
            pickupNoteOrVehicleDetailsLabel.type = .continuous
            pickupNoteOrVehicleDetailsLabel.speed = .duration(13)
        } else {
            passengerDetailViewForRiderHeightConstraint.constant = 50
            rideMatchesLabelTopHeigntConstraint.constant = 0
            pickupNoteOrVehicleDetailsLabel.isHidden = true
        }
        if let error = nextPickupParticipantETAInfo.error, error.errorCode == ETACalculator.ETA_RIDER_CROSSED_PICKUP_ERROR {
            labelNextPickupOrRideStatus.textColor = UIColor.black
            pickupNoteOrVehicleDetailsLabel.isUserInteractionEnabled = false
            self.labelRideTakerDistanceToPickupPointOrRiderName.text = Strings.pickup_point_crossed
            selectedPickupNotch.image = selectedPickupNotch.image?.withRenderingMode(.alwaysTemplate)
            selectedPickupNotch.tintColor = UIColor(netHex: 0xF9A825)
            self.passengerDetailViewForRider.backgroundColor = UIColor(netHex: 0xF9A825)
            pickupNoteOrVehicleDetailsLabel.textColor = UIColor.black
        } else {
            selectedPickupNotch.image = selectedPickupNotch.image?.withRenderingMode(.alwaysTemplate)
            selectedPickupNotch.tintColor = UIColor(netHex: 0xeedb5c)
            self.passengerDetailViewForRider.backgroundColor = UIColor(netHex: 0xeedb5c)
            pickupNoteOrVehicleDetailsLabel.textColor = UIColor.black
            if nextPickupParticipantETAInfo.routeDistance < 5 {
                self.labelRideTakerDistanceToPickupPointOrRiderName.text = "Reached to Pickup"
            }else{
                self.labelRideTakerDistanceToPickupPointOrRiderName.text = viewModel.getDistanceToReachPickup(etaInfo: nextPickupParticipantETAInfo, creationTime: riderCurrentLocation.lastUpdateTime!)
                let timeTakesToPickup = viewModel.getTimeTakesToReachPickup(etaInfo: nextPickupParticipantETAInfo, creationTime: riderCurrentLocation.lastUpdateTime!)
                    self.labelRideTakerDistanceToPickupPointOrRiderName.text?.append(", "+timeTakesToPickup)

            }

        }
    }

    private func hidePassengerPickupInfoView() {
        passengerDetailViewForRiderHeightConstraint.constant = 0
        rideMatchesLabelTopHeigntConstraint.constant = 20
        passengerDetailViewForRider.isHidden = true
        rideMatchesLabel.isHidden = false
        rideMatchesLabelHeight.constant = 20
    }

}
// MARK: - Collection view delegate and data source
extension UserDetailForRiderAndPassengerCardTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 4
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        var count = 0
        if section == 0{
            count = viewModel.incomingRideInvites.count
        }else if section == 1 {
            count = viewModel.passengersInfo.count
        }else if section == 2 {
            count = viewModel.outGoingRideInvites.count
        }else if section == 3 {
            count = viewModel.taxiPoolInvites.count
        }else {
            count = 0
        }
        if count != 0 {
            labelFindMatchedUser.isHidden = true
        }
        return count
    }

    func initializeIncomingAndOutGoingInvites(indexPath: IndexPath, cell: RiderAndPassengerCollectionViewCell, rideInvitation: RideInvitation, isIncomingInvite: Bool) {
        cell.participantStatusImage.isHidden = false
        cell.otpRequiredStartView.isHidden = true
        if viewModel.currentUserRide.rideType == Ride.PASSENGER_RIDE && !viewModel.isModerator {
            cell.userId = rideInvitation.riderId
            cell.imgProfilePic.image = nil
            cell.lblName.text = nil
            cell.noSeatsLabel.isHidden = true
            if let userBasicInfo = UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvitation.riderId){
                self.setInvitedUserImage(invitedUser: userBasicInfo, rideInvitation: rideInvitation,isIncomingInvite: isIncomingInvite, cell: cell)
            }else {
                UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvitation.riderId, handler: { (userBasicInfo, responseError, error) in
                    if let _ = userBasicInfo {
                        self.passengersCollectionViewForRider.reloadData()
                    }
                })
            }
        }else{
            cell.userId = rideInvitation.passengerId
            cell.imgProfilePic.image = nil
            cell.lblName.text = nil
            cell.noSeatsLabel.isHidden = true
            if let userBasicInfo = UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvitation.passengerId){
                self.setInvitedUserImage(invitedUser: userBasicInfo, rideInvitation: rideInvitation,isIncomingInvite: isIncomingInvite, cell: cell)
                if rideInvitation.noOfSeats > 1{
                    cell.noSeatsLabel.isHidden = false
                    cell.noSeatsLabel.text = "+\(String(rideInvitation.noOfSeats-1))"
                }else{
                    cell.noSeatsLabel.isHidden = true
                }
            }else{
                UserDataCache.getInstance()?.getUserBasicInfo(userId: rideInvitation.passengerId, handler: { (userBasicInfo, responseError, error) in
                    if let _ = userBasicInfo {
                        self.passengersCollectionViewForRider.reloadData()
                    }
                })
            }

        }
    }
    
    func setUserImage(imageURI: String?, gender: String?,imageView: UIImageView){
        if let userImageURI = imageURI, !userImageURI.isEmpty  {
            ImageCache.getInstance().getImageFromCache(imageUrl: userImageURI, imageSize: ImageCache.DIMENTION_SMALL, handler:  {(image, imageURI) in
                if let image = image , imageURI == userImageURI{
                    ImageCache.getInstance().checkAndSetCircularImage(imageView: imageView, image: image)
                }else{
                    ImageCache.getInstance().getImageFromCache(imageUrl: userImageURI, imageSize: ImageCache.DIMENTION_TINY, handler : {(image, imageURI) in
                        if let image = image , imageURI == userImageURI {
                            ImageCache.getInstance().checkAndSetCircularImage(imageView: imageView, image: image)
                        }else{
                            imageView.image = ImageCache.getInstance().getDefaultUserImage(gender: gender ?? "U")
                        }
                    })
                }
            })
        }else {
            imageView.image = ImageCache.getInstance().getDefaultUserImage(gender: gender ?? "U")
        }
    }

    private func setInvitedUserImage(invitedUser : UserBasicInfo, rideInvitation : RideInvitation,isIncomingInvite : Bool,cell: RiderAndPassengerCollectionViewCell){
        AppDelegate.getAppDelegate().log.debug(rideInvitation.toJSONString())
        RideViewUtils.setBorderToUserImageBasedOnStatus(image: cell.imgProfilePic, status: Ride.RIDE_STATUS_REQUESTED)
        setUserImage(imageURI: invitedUser.imageURI, gender: invitedUser.gender, imageView: cell.imgProfilePic)
        ViewCustomizationUtils.addCornerRadiusToView(view: cell.participantStatusImage, cornerRadius: 10)
        if  isIncomingInvite {
            if rideInvitation.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED_AND_PAYMENT_PENDING {
                cell.participantStatusImage.image = UIImage(named:"Red_Exclamation_Dot")
            }else {
                cell.participantStatusImage.image = UIImage(named:"invite_icon")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
                cell.participantStatusImage.tintColor = UIColor.black
            }
            
        }else{
            setImageViewBasedOnInvitationStatus(imageView: cell.participantStatusImage, status :rideInvitation.invitationStatus!)
        }

        cell.lblName.text = invitedUser.name?.capitalizingFirstLetter()
    }

    private func setImageViewBasedOnInvitationStatus( imageView : UIImageView, status : String){
        AppDelegate.getAppDelegate().log.debug(status)
        switch status {
        case RideInvitation.RIDE_INVITATION_STATUS_RECEIVED:
            imageView.image = UIImage(named:"delivered_icon")
        case RideInvitation.RIDE_INVITATION_STATUS_NEW:
            imageView.image = UIImage(named:"sent_icon")
        case RideInvitation.RIDE_INVITATION_STATUS_READ:
            imageView.image = UIImage(named:"double_tick_green")
        case RideInvitation.RIDE_INVITATION_STATUS_ACCEPTED_AND_PAYMENT_PENDING:
            imageView.image = UIImage(named:"Red_Exclamation_Dot")
        default:
            imageView.image = UIImage(named:"sent_icon")
            break
        }
    }

    private func initializeRideParticipantProfile(indexPath: IndexPath, cell: RiderAndPassengerCollectionViewCell, rideParticipant: RideParticipant) {
        cell.userId = rideParticipant.userId
        cell.status = rideParticipant.status
        cell.lblName.text = rideParticipant.name?.capitalizingFirstLetter()
        if RideViewUtils.isOTPRequiredToPickupPassenger(rideParticipant: rideParticipant, ride: viewModel.currentUserRide, riderProfile: UserDataCache.getInstance()?.getLoggedInUserProfile()) {
            cell.otpRequiredStartView.isHidden = false
        } else {
            cell.otpRequiredStartView.isHidden = true
        }
        if !rideParticipant.rider, rideParticipant.noOfSeats > 1{
            cell.noSeatsLabel.isHidden = false
            cell.noSeatsLabel.text = "+\(String(rideParticipant.noOfSeats-1))"
        } else {
            cell.noSeatsLabel.isHidden = true
        }
        
        setUserImage(imageURI: rideParticipant.imageURI, gender: rideParticipant.gender, imageView: cell.imgProfilePic)
        
        if rideParticipant.rideModerationEnabled, rideParticipant.status == Ride.RIDE_STATUS_STARTED, !rideParticipant.rider, let ridePreference = UserDataCache.getInstance()?.getLoggedInUserRidePreferences(), ridePreference.rideModerationEnabled {
            cell.participantStatusImage.isHidden = false
            cell.participantStatusImage.image = UIImage(named: "icon_ride_anchor_enable")
        }else {
            cell.participantStatusImage.isHidden = true
        }

        cell.awakeFromNib()
    }
    
    func setSelectedAnchorForNextPickup(selectedPassengerIndex : Int){
        let attributes = passengersCollectionViewForRider.layoutAttributesForItem(at: IndexPath(item: selectedPassengerIndex, section: 1))
        let cellRect = attributes?.frame
        let cellFrameInSuperview = passengersCollectionViewForRider.convert(cellRect ?? CGRect.zero, to: passengersCollectionViewForRider.superview)

        if cellFrameInSuperview.origin.x == 0.0{
            selectedPickupNotchLeadingConstraint.constant = 30
        }
        else{
            selectedPickupNotchLeadingConstraint.constant = cellFrameInSuperview.origin.x + 30
        }
        if passengersCollectionViewForRider.contentSize.width != 0 && selectedPickupNotchLeadingConstraint.constant + 50 >= passengersCollectionViewForRider.contentSize.width{
            passengersCollectionViewForRider.scrollToItem(at: IndexPath(item: selectedPassengerIndex, section: 1), at: .right, animated: false)
        }
    }

    private func taxiRideInviteTapped(indexPath : Int) {
        let invitation = viewModel.taxiPoolInvites[indexPath]
        QuickRideProgressSpinner.startSpinner()
        viewModel.getTaxipoolDetails(taxiInvite: invitation) {[weak self](responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                if var matchedTaxiRideGroup = Mapper<MatchedTaxiRideGroup>().map(JSONObject: responseObject!["resultData"]){
                    matchedTaxiRideGroup.pickupAddress = self?.viewModel.currentUserRide.startAddress
                    matchedTaxiRideGroup.dropAddress = self?.viewModel.currentUserRide.endAddress
                    matchedTaxiRideGroup.minPoints = invitation.minFare
                    matchedTaxiRideGroup.maxPoints = invitation.maxFare
                    let taxipoolInviteDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.taxiSharing_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TaxipoolInviteDetailsViewController") as! TaxipoolInviteDetailsViewController
                    taxipoolInviteDetailsViewController.showReceivedTaxipoolInvite(taxipoolInvite: invitation, matchedTaxiRideGroup: matchedTaxiRideGroup,isFromJoinMyRide: false)
                    ViewControllerUtils.displayViewController(currentViewController: self?.parentViewController, viewControllerToBeDisplayed: taxipoolInviteDetailsViewController, animated: false)
                }
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self?.parentViewController, handler: nil)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RiderAndPassengerCollectionViewCell", for: indexPath) as! RiderAndPassengerCollectionViewCell

        if indexPath.section == 1 {
            cell.contentView.layer.opacity = 1
            if viewModel.passengersInfo.endIndex <= indexPath.row{
                return cell
            }
            initializeRideParticipantProfile(indexPath: indexPath, cell: cell, rideParticipant: viewModel.passengersInfo[indexPath.row])
        } else if indexPath.section == 3{
            let taxiPoolInvitecell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmptyPassengerTaxiPoolCollectionViewCell", for: indexPath) as! EmptyPassengerTaxiPoolCollectionViewCell
            taxiPoolInvitecell.inviteStatusImage.isHidden = false
            taxiPoolInvitecell.inviteNameLabel.isHidden = false
            taxiPoolInvitecell.inviteNameLabel.text = viewModel.taxiPoolInvites[indexPath.row].invitingUserName
            taxiPoolInvitecell.inviteStatusImage.image = UIImage(named: "taxi_invite_received")
            taxiPoolInvitecell.passengerImageView.layer.opacity = 0.6
             return taxiPoolInvitecell
        }else {
            cell.imgProfilePic.layer.opacity = 0.6
            if indexPath.section == 0 {
                if viewModel.incomingRideInvites.endIndex <= indexPath.row{
                    return cell
                }
                let rideInvitation = viewModel.incomingRideInvites[indexPath.item]
                initializeIncomingAndOutGoingInvites(indexPath: indexPath, cell: cell, rideInvitation: rideInvitation, isIncomingInvite: true)
            }else{
                if viewModel.outGoingRideInvites.endIndex <= indexPath.row{
                    return cell
                }
                let rideInvitation = viewModel.outGoingRideInvites[indexPath.item]
                initializeIncomingAndOutGoingInvites(indexPath: indexPath, cell: cell, rideInvitation: rideInvitation, isIncomingInvite: false)
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        if indexPath.section == 1 {
            
            
            if viewModel.passengersInfo.count <= indexPath.item {return}
            guard let cell = collectionView.cellForItem(at: indexPath) as? RiderAndPassengerCollectionViewCell else {
                return
            }
            let rideParticipant = viewModel.passengersInfo[indexPath.item]
            passengerSelected(rideParticipant: rideParticipant, view: cell.imgProfilePic)
        } else if indexPath.section == 0 {
            if viewModel.incomingRideInvites.count <= indexPath.item{
                return
            }
            let rideInvitation = viewModel.incomingRideInvites[indexPath.item]
            incomingInvitationSelected(rideInvitation: rideInvitation)
        } else if indexPath.section == 2 {
            if viewModel.outGoingRideInvites.count <= indexPath.item {
                return
            }
            let rideInvitation = viewModel.outGoingRideInvites[indexPath.item]
            outGoingInvitationSelected(rideInvitation: rideInvitation)
        }else if indexPath.section == 3 {
            taxiRideInviteTapped(indexPath: indexPath.item)
        }
    }
}
//MARK: Auto confirm view
extension UserDetailForRiderAndPassengerCardTableViewCell {
    private func updateAutoMatchStatus(matchesCount : Int){

        guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() else {
            autoMatchView.isHidden = true
            autoMatchViewHeighConstraint.constant = 0
            return
        }
        autoMatchView.isHidden = false
        autoMatchViewHeighConstraint.constant = 70

        autoMatchView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(autoConfirmStripTapped(_:))))

        autoConfirmOnStateStrip(matchesCount: matchesCount)
        if !ridePreferences.autoConfirmEnabled {
            return
        }
        viewModel.getAutoConfirmSentInvitesAndRequests { (autoSentInvites) in
            if !autoSentInvites.isEmpty{
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    let showedNamesList = SharedPreferenceHelper.getShownAutoInviteUserId(rideId: autoSentInvites[0].rideId)
                    if showedNamesList.isEmpty{
                        self.showEachAutoInvitedNames(outGoingInvites: autoSentInvites, totalInviteCount: autoSentInvites.count)
                    }else{
                        var newAutoInviteList = [RideInvitation]()
                        for newAutoInvite in autoSentInvites{
                            if !showedNamesList.contains(newAutoInvite.rideInvitationId){
                                newAutoInviteList.append(newAutoInvite)
                            }
                        }
                        if newAutoInviteList.isEmpty{
                            self.showAutoInvitedCount(totalAutoInvite: autoSentInvites.count)
                        }else{
                            self.showEachAutoInvitedNames(outGoingInvites: newAutoInviteList, totalInviteCount: autoSentInvites.count)
                        }
                    }
                }
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    self.autoMatchProgressLabel.text = "No Matches meet your preferences yet. Meanwhile, please invite suitable Riders directly. "
                }
            }
        }
    }

    private func autoConfirmOnStateStrip(matchesCount : Int) {
        if let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences(),ridePreferences.autoConfirmEnabled  {
            autoMatchSwitch.setOn(true, animated: false)
            autoMatchLabel.text = Strings.automatch_is_on
            autoMatchIcon.image = UIImage(named: "auto_match_green")
            autoMatchLabel.textColor = UIColor(netHex : 0x00B557)
            if matchesCount == 0 {
                autoMatchProgressLabel.text = "No Matches at present. Will keep looking.."
            }else{
                autoMatchProgressLabel.text = "Checking Matching Riders as per your preferences..."
            }
        }else {
            autoMatchSwitch.setOn(false, animated: false)
            autoMatchLabel.text = Strings.automatch_is_off
            autoMatchIcon.image = UIImage(named: "auto_match_grey")
            autoMatchLabel.textColor = UIColor(netHex : 0x000000)
            autoMatchProgressLabel.text = Strings.enable_auto_match_subtitle
        }

    }

    private func showEachAutoInvitedNames(outGoingInvites: [RideInvitation],totalInviteCount: Int){
        var timer: DispatchSourceTimer?
        var index = outGoingInvites.startIndex
        var showedNamesList = SharedPreferenceHelper.getShownAutoInviteUserId(rideId: viewModel.currentUserRide.rideId)
        timer = DispatchSource.makeTimerSource(queue: .main)
        timer?.schedule(deadline: .now(), repeating: .seconds(3))
        timer?.setEventHandler { [weak self] in
            var userId = outGoingInvites[index].riderId
            if self?.viewModel.currentUserRide.rideType == Ride.RIDER_RIDE{
                userId = outGoingInvites[index].passengerId
            }
                UserDataCache.getInstance()?.getUserBasicInfo(userId: userId, handler: { (userBasicInfo, responseError, error) in
                    if let userBasicInfo = userBasicInfo {
                        self?.autoMatchProgressLabel.text = String(format: Strings.invited_user_name, arguments: [(userBasicInfo.name ?? "")])
                    }
                })
            showedNamesList.append(outGoingInvites[index].rideInvitationId )
            index = index.advanced(by: 1)
            if index == outGoingInvites.endIndex {
                timer?.cancel()
                SharedPreferenceHelper.storeShownAutoInviteUserId(rideId: (self?.viewModel.currentUserRide.rideId)!, list: showedNamesList)
                if outGoingInvites.count == 1 || index == outGoingInvites.count{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self?.showAutoInvitedCount(totalAutoInvite: totalInviteCount)
                    }
                }else{
                    self?.showAutoInvitedCount(totalAutoInvite: totalInviteCount)
                }
            }
        }
        timer?.resume()
    }

    private func showAutoInvitedCount(totalAutoInvite: Int){
        if viewModel.currentUserRide.rideType == Ride.RIDER_RIDE {
            autoMatchProgressLabel.text = String(format: Strings.invited_users, arguments: [String(totalAutoInvite)])
        }else{
            autoMatchProgressLabel.text = String(format: Strings.requested_users, arguments: [String(totalAutoInvite)])
        }
    }
    private func showAutoConfirmPopDetailsVC() {
        let autoMatchDetailsPopVC = UIStoryboard(name: StoryBoardIdentifiers.settings_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AutoMatchDetailsViewController") as! AutoMatchDetailsViewController
        autoMatchDetailsPopVC.initializeData(rideType: viewModel.currentUserRide.rideType ?? Ride.PASSENGER_RIDE, autoMatchStatusChanged: { (changed) in
            if changed {
                self.initialzeAvaialbelRideMatchesAndCountUI()
            }
        })
        ViewControllerUtils.addSubView(viewControllerToDisplay: autoMatchDetailsPopVC)
    }

    @objc func autoConfirmStripTapped(_ sender: UITapGestureRecognizer){
        showAutoConfirmPopDetailsVC()
    }

    @IBAction func autoConfirmSwitchTapped(_ sender: UISwitch) {
        guard let ridePreferences = UserDataCache.getInstance()?.getLoggedInUserRidePreferences() else { return }
        ridePreferences.autoConfirmEnabled = sender.isOn
        QuickRideProgressSpinner.startSpinner()
        SaveRidePreferencesTask(ridePreferences: ridePreferences, viewController: parentViewController, receiver: self).saveRidePreferences()
    }

}


//MARK: Freeze Ride View
extension UserDetailForRiderAndPassengerCardTableViewCell {

    @IBAction func freezeRideButtonTapped(_ sender: Any) {
        if let riderRide = viewModel.currentUserRide as? RiderRide,riderRide.freezeRide{
            updateFreezeRide(isRequiredToFreeze: false)
        } else {
            let freezeRideConfirmationViewController = UIStoryboard(name: "LiveRideView",bundle: nil).instantiateViewController(withIdentifier: "FreezeRideConfirmationViewController") as! FreezeRideConfirmationViewController
            freezeRideConfirmationViewController.initialiseFreezeRideConfirmation { (isConfirmed) in
                if isConfirmed{
                    self.updateFreezeRide(isRequiredToFreeze: true)
                }
            }
            ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: freezeRideConfirmationViewController, animated: false, completion: nil)
        }
    }

    private func updateFreezeRide(isRequiredToFreeze: Bool){
        QuickRideProgressSpinner.startSpinner()
        viewModel.updateFreezeRide(freezeRide: isRequiredToFreeze) { (responseError, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseError != nil || error != nil{
                ErrorProcessUtils.handleResponseError(responseError: responseError, error: error, viewController: self.parentViewController)
            }else {
                self.handleVisibilityForFreezeIcon()
                NotificationCenter.default.post(name: .freezeRideUpdated, object: nil)
            }
        }
    }

    private func handleVisibilityForFreezeIcon() {
        if let riderRide = viewModel.currentUserRide as? RiderRide{
            if riderRide.freezeRide {
                showUnfreezeRideView()
            } else  {
                showFreezeRideView()
            }
        }
    }
    private func showFreezeRideView() {
        initialzeAvaialbelRideMatchesAndCountUI()
        labelInviteMatchedUsers.isHidden = false
    }

    private func showUnfreezeRideView() {
        imageViewFindMatchedUser.image = UIImage(named: "freeze_lock")
        labelInviteMatchedUsers.isHidden = true
    }

}
extension UserDetailForRiderAndPassengerCardTableViewCell : RideActionComplete {
    func rideActionCompleted(status: String) {
        if status == Ride.RIDE_STATUS_STARTED{
            NotificationCenter.default.post(name: .passengerPickedUpRideStartedStatus, object: nil)
        }else if status == Ride.RIDE_STATUS_COMPLETED{
            let myActiveRidesCache : MyActiveRidesCache? =  MyActiveRidesCache.singleCacheInstance
            if myActiveRidesCache != nil{
                myActiveRidesCache!.removeRideUpdateListener(key: MyActiveRidesCache.LiveRideMapViewController_key)
            }
            NotificationStore.getInstance().removeListener(key: LiveRideMapViewController.liveRideMapViewControllerKey)
            NotificationCenter.default.post(name: .passengerPickedUp, object: nil)
        }
    }

    func rideActionFailed(status: String, error: ResponseError?) {
        ErrorProcessUtils.handleResponseError(responseError: error, error: nil, viewController: parentViewController)
    }


}
extension UserDetailForRiderAndPassengerCardTableViewCell : PassengerPickupDelegate {
    func passengerPickedUp(riderRideId: Double) {
        viewModel.selectedPassengerId = 0
        initializeRideMatchesUI()
        handleEtaShowingToRider()
        RideManagementUtils.completeRiderRide(riderRideId: riderRideId, targetViewController: parentViewController,rideActionCompletionDelegate: self)
    }
}
extension UserDetailForRiderAndPassengerCardTableViewCell : SaveRidePreferencesReceiver {
    func ridePreferencesSaved() {
        QuickRideProgressSpinner.stopSpinner()
        initialzeAvaialbelRideMatchesAndCountUI()
    }

    func ridePreferencesSavingFailed() {
        QuickRideProgressSpinner.stopSpinner()
    }


}
extension UITableViewCell {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
