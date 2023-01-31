//
//  InstantRideMatchedUserCollectionViewCell.swift
//  Quickride
//
//  Created by Rajesab on 15/06/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation
import FloatingPanel
import Lottie

class InstantRideMatchedUserCollectionViewCell: UICollectionViewCell {
    
    //MARK: OUTLETS
    //MARK: cardView
    
    @IBOutlet weak var backGroundView: QuickRideCardView!
    //MARK: First Time bouns
    @IBOutlet weak var firstTimeBounsView: UIView!
    @IBOutlet weak var firstTimeBounsViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var firstTimeBounsDetailsLabel: UILabel!
    //MARK: TopView
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var requestImageView: UIImageView!
    @IBOutlet weak var requestMessageLabel: UILabel!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var rideStatusLabel: UILabel!
    @IBOutlet weak var inviteStatusImageView: UIImageView!
    //MARK: Profile
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileVerificationImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var ratingShowingLabel: UILabel!
    @IBOutlet weak var ratingShowingLabelHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var cellWidth: NSLayoutConstraint!
    
    @IBOutlet weak var matchingPercentageORPriceShowingLabel: UILabel!
    @IBOutlet weak var routeMatchOrPointsShowingLabel: UILabel!
    @IBOutlet weak var rideTimeImageView: UIImageView!
    @IBOutlet weak var rideTimeShowingLabel: UILabel!
    @IBOutlet weak var favoriteIconShowingImageView: UIImageView!
    @IBOutlet weak var requestNumberOfSeatView: UIView!
    @IBOutlet weak var numberOfSeatsLabel: UILabel!
    @IBOutlet weak var numberOfSeatsForPassengerWidthConstrasaints: NSLayoutConstraint!
    //MARK:Ride Taker PickUpDataShowingView
    @IBOutlet weak var rideTakerPickUpDataView: UIView!
    @IBOutlet weak var walkPathViewForPickUp: UIView!
    @IBOutlet weak var walkPathAfterTravelView: UIView!
    @IBOutlet weak var rideDistanceShowingView: UIView!
    @IBOutlet weak var walkPathdistanceShowingLabel: UILabel!
    @IBOutlet weak var afterRideWalkingDistanceShowingLabel: UILabel!
    @IBOutlet weak var carOrImageForWalkPathImageView: UIImageView!
    //MARK: Ride Giver PickUpDataShowingView
    @IBOutlet weak var rideGiverPickUpDataView: UIView!
    @IBOutlet weak var rideGiverPickUpDistanceLabel: UILabel!
    @IBOutlet weak var carOrBikeImageView: UIImageView!
    @IBOutlet weak var travellingDistanceShowingLabel: UILabel!
    //MARK: RideTakerORGiver Points Details
    @IBOutlet weak var rideTimeShowingView: UIView!
    @IBOutlet weak var rideTypeImageView: UIImageView!
    @IBOutlet weak var pointsShowingView: UIView!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var passengerShowingStackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var firstSeatImageView: UIImageView!
    @IBOutlet weak var secondSeatImageView: UIImageView!
    @IBOutlet weak var thirdSeatImageView: UIImageView!
    @IBOutlet weak var fouthSeatImageView: UIImageView!
    @IBOutlet weak var fifthSeatImageView: UIImageView!
    @IBOutlet weak var sixthSeatImageView: UIImageView!
    @IBOutlet weak var dotSeparatorView: UIView!
    @IBOutlet weak var pointsOrPercentageRideMatchShowingLabel: UILabel!
    @IBOutlet weak var ridetypeimageWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var fareChangeButton: UIButton!
    //MARK: Contact Options
    @IBOutlet weak var contactOptionShowingView: UIView!
    @IBOutlet weak var callOptionBtn: UIButton!
    @IBOutlet weak var chatOptionBtn: UIButton!
    @IBOutlet weak var callToInviteOptionButton: UIButton!
    //MARK: ActionButton
    @IBOutlet weak var rideActionAndMatchedUserDetailView: UIView!
    @IBOutlet weak var rideActionAndMatchedUserHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var seperateView: UIView!
    @IBOutlet weak var riderIsOfflineView: UIView!
    @IBOutlet weak var rideConfirmActionView: UIView!
    @IBOutlet weak var rideConfirmActionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var declineRideButton: UIButton!
    @IBOutlet weak var declineButtonWidthConstaint: NSLayoutConstraint!
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var changePlanButton: UIButton!
    @IBOutlet weak var rideMatchDetailsStackView: UIStackView!
    @IBOutlet weak var poolShowingLabel: UILabel!
    @IBOutlet weak var poolTypeView: UIView!
    //MARK: Invite
    @IBOutlet weak var inviteOrOfferRideShowingView: UIView!
    @IBOutlet weak var inviteProgressImageView: UIImageView!
    @IBOutlet weak var inviteOrOfferRideBtn: UIButton!
    @IBOutlet weak var routeMatchAndPointsContainingStackView: UIStackView!
    @IBOutlet weak var fullMatchAnimationContainerView: UIView!
    @IBOutlet weak var fullMatchAnimationview: AnimatedControl!
    
    //MARK: ReadyToGoAction
    @IBOutlet weak var readyToGoActionView: UIView!
    @IBOutlet weak var joinProgressImageView: UIImageView!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var callToInviteButton: UIButton!
    @IBOutlet weak var readyToGoFareChangeButton: UIButton!
    @IBOutlet weak var noteButton: UIButton!
    
    //MARK: Ride Note view
    @IBOutlet weak var rideNoteView: UIView!
    @IBOutlet weak var rideNoteHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var noteShowingLabel: UILabel!
    @IBOutlet weak var safeKeeperButton: UIButton!
    
    
    //MARK: Variables
    private var numberOfSeatsImageArray = [UIImageView]()
    weak var viewController : UIViewController?
    private var rideDetailViewCellViewModel = InstantRideMatchedUserViewModel()
    private var userSelectionDelegate: RideDetailTableViewCellUserSelectionDelegate?
    private var drawerState = FloatingPanelPosition.half
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberOfSeatsImageArray = [firstSeatImageView,secondSeatImageView,thirdSeatImageView,fouthSeatImageView,fifthSeatImageView,sixthSeatImageView]
    }
    
    func initialiseUIWithData(ride: Ride?, matchedUser: MatchedUser, viewController : UIViewController, viewType: DetailViewType, selectedIndex: Int, drawerState: FloatingPanelPosition?, routeMetrics: RouteMetrics?, rideInviteActionCompletionListener: RideInvitationActionCompletionListener?, userSelectionDelegate: RideDetailTableViewCellUserSelectionDelegate?, selectedUserDelegate: SelectedUserDelegate?) {
        rideDetailViewCellViewModel.initialiseUIWithData(ride: ride, matchedUser: matchedUser, viewType: viewType, selectedIndex: selectedIndex, routeMetrics: routeMetrics, rideActionCompletionDelegate: self, rideInviteActionCompletionListener : rideInviteActionCompletionListener, selectedUserDelegate: selectedUserDelegate)
        self.drawerState = drawerState ?? FloatingPanelPosition.half
        self.viewController = viewController
        self.userSelectionDelegate = userSelectionDelegate
        setUpUI()
        checkAndSetInvitedLabel()
        handleFareChangeView()
        setFirstTimeBonusViewToNewUser()
        getSetInviteStatusView()
        NotificationCenter.default.addObserver(self, selector: #selector(receivedRidePresentLocation(_:)), name: .receivedRidePresentLocation, object: nil)
    }
    @objc func receivedRidePresentLocation(_ notification: Notification) {
        QuickRideProgressSpinner.stopSpinner()
        updateRideStatus()
    }
    
    private func setUpUI() {
        backGroundView.isUserInteractionEnabled = true
        rideActionAndMatchedUserHeightConstraint.constant = 40
        if rideDetailViewCellViewModel.matchedUser!.isReadyToGo {
            rideActionAndMatchedUserDetailView.isHidden = true
            readyToGoActionView.isHidden = false
            seperateView.isHidden = true
        } else {
            rideActionAndMatchedUserDetailView.isHidden = false
            readyToGoActionView.isHidden = true
            seperateView.isHidden = false
        }
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        ImageCache.getInstance().setImageToView(imageView: profileImageView, imageUrl: rideDetailViewCellViewModel.matchedUser?.imageURI ?? "", gender: rideDetailViewCellViewModel.matchedUser?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        nameLabel.text = rideDetailViewCellViewModel.matchedUser?.name?.capitalized
        if rideDetailViewCellViewModel.viewType == DetailViewType.RideConfirmView || rideDetailViewCellViewModel.viewType == DetailViewType.RideInviteView {
            nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
            companyNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        }
        favoriteIconShowingImageView.isHidden = rideDetailViewCellViewModel.isFavouritePartner()
        if let _ = rideDetailViewCellViewModel.matchedUser?.rating, let _ = rideDetailViewCellViewModel.matchedUser?.noOfReviews, let _ = rideDetailViewCellViewModel.matchedUser?.profileVerificationData {
            setUserOfficialAndVerificationData()
        } else {
            starImageView.isHidden = true
            ratingShowingLabel.isHidden = true
            ratingShowingLabelHeightConstraints.constant = 0
            profileVerificationImageView.isHidden = true
        }
        if let verificationData = rideDetailViewCellViewModel.matchedUser?.profileVerificationData {
            profileVerificationImageView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: verificationData)
        } else {
            let userId = StringUtils.getStringFromDouble(decimalNumber: rideDetailViewCellViewModel.matchedUser?.userid)
             UserDataCache.getInstance()?.getOtherUserCompleteProfile(userId: userId, completeProfileRetrievalCompletionHandler: { (otherUserInfo, error, responseObject) -> Void in
                if otherUserInfo != nil {
                    self.rideDetailViewCellViewModel.matchedUser?.profileVerificationData = otherUserInfo?.userProfile?.profileVerificationData
                    self.rideDetailViewCellViewModel.matchedUser?.companyName = otherUserInfo?.userProfile?.companyName
                    self.rideDetailViewCellViewModel.matchedUser?.rating = otherUserInfo?.userProfile?.rating
                    self.rideDetailViewCellViewModel.matchedUser?.noOfReviews = otherUserInfo?.userProfile?.noOfReviews ?? 0
                    self.setUserOfficialAndVerificationData()
                }
            })
        }
        if rideDetailViewCellViewModel.viewType == DetailViewType.MatchedUserView {
            if let rideNotes = rideDetailViewCellViewModel.matchedUser?.rideNotes, !rideNotes.isEmpty, rideDetailViewCellViewModel.viewType == DetailViewType.MatchedUserView {
                noteButton.isHidden = false
            } else {
                noteButton.isHidden = true
            }
            rideNoteView.isHidden = true
            rideNoteHeightConstraints.constant = 0
        }
        setDataForRiderOrPasenger(matchedUser: rideDetailViewCellViewModel.matchedUser!)
        handleRideMatchDetailView()
        handleSafeKeeperBadge()
    }
    
    private func handleSafeKeeperBadge() {
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil {
            clientConfiguration = ClientConfigurtion()
        }
        if clientConfiguration!.showCovid19SelfAssessment ?? false && rideDetailViewCellViewModel.matchedUser!.hasSafeKeeperBadge {
            safeKeeperButton.isHidden = false
        } else {
            safeKeeperButton.isHidden = true
        }
    }
    
    private func setFirstTimeBonusViewToNewUser() {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if let matchedUser = rideDetailViewCellViewModel.matchedUser, UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus != 0 && clientConfiguration.enableFirstRideBonusPointsOffer  && ((matchedUser.androidAppVersionName != nil && matchedUser.androidAppVersionName! >= MatchedUser.SUPPORTED_ANDROID_APP_VERSION) || (matchedUser.iosAppVersionName != nil && matchedUser.iosAppVersionName! >= MatchedUser.SUPPORTED_IOS_APP_VERSION)) {
            if matchedUser.verificationStatus && matchedUser.totalNoOfRideShared == 0{
                firstTimeBounsView.isHidden = false
                firstTimeBounsViewHeightConstraints.constant = 40
                firstTimeBounsDetailsLabel.text = String(format: Strings.first_time_bouns, StringUtils.getStringFromDouble(decimalNumber: clientConfiguration.firstRideBonusPoints))
                firstTimeBounsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(showGiftDetails(_:))))
            } else {
                firstTimeBounsView.isHidden = true
                firstTimeBounsViewHeightConstraints.constant = 10
            }
        } else {
            firstTimeBounsView.isHidden = true
            firstTimeBounsViewHeightConstraints.constant = 10
        }
    }
    
    @objc private func showGiftDetails(_ gesture: UITapGestureRecognizer){
        MessageDisplay.displayErrorAlertWithAction(title: Strings.dollar_sym_info, isDismissViewRequired: true, message1: rideDetailViewCellViewModel.getFirstTimeOfferDetails(), message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: nil) { (result) in
        }
    }
    
    private func getSetInviteStatusView() {
        if rideDetailViewCellViewModel.ride?.rideType == nil || rideDetailViewCellViewModel.ride?.rideType?.isEmpty == true{
            return
        }
        let invite = rideDetailViewCellViewModel.getOutGoingInviteForRide()
        if invite != nil && invite?.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_NEW {
            setInviteStatus(status: 1)
            startedLabelSet()
        } else if invite != nil && invite?.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_RECEIVED {
            setInviteStatus(status: 2)
            startedLabelSet()
        } else if invite != nil && invite?.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_READ {
            setInviteStatus(status: 3)
            startedLabelSet()
        } else if invite == nil && rideDetailViewCellViewModel.checkForRideStatusStartedAndSetStatus() && (drawerState == .full || rideDetailViewCellViewModel.viewType == DetailViewType.MatchedUserView) {
            inviteStatusImageView.isHidden = true
            topViewHeightConstraint.constant = 30
            topView.isHidden = false
            rideStatusLabel.text = Strings.rider_ride_started_matchingList
            rideStatusLabel.textColor = UIColor(netHex: 0x00B557)
            rideStatusLabel.isHidden = false
            topSeparatorView.isHidden = true
            requestImageView.isHidden = true
            requestMessageLabel.isHidden = true
        } else {
            topView.isHidden = true
            inviteStatusImageView.isHidden = true
            topViewHeightConstraint.constant = 0
            rideStatusLabel.isHidden = true
            requestImageView.isHidden = true
            requestMessageLabel.isHidden = true
            topSeparatorView.isHidden = true
        }
        updateRideStatus()
        self.topView.layoutIfNeeded()
    }
    
    private func updateRideStatus(){
        if let routeMetrics = rideDetailViewCellViewModel.routeMetrics {
            setEta(routeMetrics: routeMetrics)
        } else if let matchedUser = rideDetailViewCellViewModel.matchedUser, matchedUser.userRole == MatchedUser.RIDER || matchedUser.userRole == MatchedUser.REGULAR_RIDER, matchedUser.isReadyToGo, rideDetailViewCellViewModel.viewType == DetailViewType.MatchedUserView, drawerState != .full {
            var pickupText: String?
            if let time = matchedUser.pkTime {
                pickupText =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            } else if let pickupTime = matchedUser.pickupTime {
                pickupText = DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            } else {
                pickupText = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.startDate, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            }
            handleSeperatorViewShowing()
            rideStatusLabel.text = "PICK-UP: \(pickupText!)"
            rideStatusLabel.isHidden = false
            rideStatusLabel.textColor = UIColor(netHex: 0x00B557)
            topViewHeightConstraint.constant = 30
            topView.isHidden = false
        }
    }
    
    private func handleSeperatorViewShowing() {
        if requestMessageLabel.isHidden {
            topSeparatorView.isHidden = true
        } else {
            topSeparatorView.isHidden = false
        }
    }
    
    private func setInviteStatus(status: Int) {
        if (drawerState == .full || rideDetailViewCellViewModel.viewType == DetailViewType.MatchedUserView) {
            topView.isHidden = false
            topViewHeightConstraint.constant = 30
            requestImageView.isHidden = false
            requestMessageLabel.isHidden = false
            inviteStatusImageView.isHidden = true
            switch status {
            case 1 :
                setRequestMessageLabelText(status: status)
                requestImageView.image = UIImage(named: "request_sent")
            case 2 :
                setRequestMessageLabelText(status: status)
                requestImageView.image = UIImage(named: "request_sent_actual")
            default :
                setRequestMessageLabelText(status: status)
                requestImageView.image = UIImage(named: "request_seen")
            }
        } else {
            topView.isHidden = true
            topViewHeightConstraint.constant = 0
            rideStatusLabel.isHidden = true
            requestImageView.isHidden = true
            requestMessageLabel.isHidden = true
            topSeparatorView.isHidden = true
            inviteStatusImageView.isHidden = false
            switch status {
            case 1 :
                inviteStatusImageView.image = UIImage(named: "request_sent")
            case 2 :
                inviteStatusImageView.image = UIImage(named: "request_sent_actual")
            default :
                inviteStatusImageView.image = UIImage(named: "request_seen")
            }
        }
    }
    
    private func setRequestMessageLabelText(status: Int) {
        switch status {
        case 3:
            requestMessageLabel.textColor = UIColor(netHex: 0x19AC4A)
            if rideDetailViewCellViewModel.matchedUser?.userRole == MatchedUser.RIDER {
                requestMessageLabel.text = Strings.request_seen
            } else {
                requestMessageLabel.text = Strings.invite_seen
            }
        default:
            requestMessageLabel.textColor = UIColor(netHex: 0x9BA3B1)
            if rideDetailViewCellViewModel.matchedUser?.userRole == MatchedUser.RIDER {
                requestMessageLabel.text = Strings.request_sent
            } else {
                requestMessageLabel.text = Strings.invite_sent_machinglist
            }
        }
    }
    
    private func startedLabelSet() {
        if (drawerState == .full || rideDetailViewCellViewModel.viewType == DetailViewType.MatchedUserView) && rideDetailViewCellViewModel.checkForRideStatusStartedAndSetStatus() {
            rideStatusLabel.text = Strings.rider_ride_started_matchingList
            rideStatusLabel.isHidden = false
            topSeparatorView.isHidden = false
            rideStatusLabel.textColor = UIColor(netHex: 0x00B557)
        }else{
            rideStatusLabel.text = ""
            rideStatusLabel.isHidden = true
            topSeparatorView.isHidden = true
        }
    }
    
    private func setEta(routeMetrics: RouteMetrics) {
        handleSeperatorViewShowing()
        let etaText = ParticipantETAInfoCalculator().getEtaTextBasedOnRouteMetrics(routeMetrics: routeMetrics)
        if etaText == Strings.rider_crossed_pickup {
            rideStatusLabel.textColor = UIColor.red
            rideStatusLabel.text = etaText
            return
        }
        rideStatusLabel.textColor = UIColor(netHex: 0x00B557)
        rideStatusLabel.text = etaText
    }
    
    private func setUserOfficialAndVerificationData() {
        profileVerificationImageView.isHidden = false
        ratingShowingLabel.isHidden = false
        profileVerificationImageView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: self.rideDetailViewCellViewModel.matchedUser?.profileVerificationData)
        companyNameLabel.text = rideDetailViewCellViewModel.getCompanyName()
        if companyNameLabel.text == Strings.not_verified {
            companyNameLabel.textColor = UIColor.black
        }else{
            companyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        if rideDetailViewCellViewModel.matchedUser!.rating! > 0.0 {
            ratingShowingLabelHeightConstraints.constant = 20.0
            ratingShowingLabel.font = UIFont.systemFont(ofSize: 13.0)
            starImageView.isHidden = false
            ratingShowingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingShowingLabel.text = String(rideDetailViewCellViewModel.matchedUser!.rating!) + "(\(String(rideDetailViewCellViewModel.matchedUser!.noOfReviews)))"
            ratingShowingLabel.backgroundColor = .clear
            ratingShowingLabel.layer.cornerRadius = 0.0
        }else{
            ratingShowingLabelHeightConstraints.constant = 15.0
            ratingShowingLabel.font = UIFont.boldSystemFont(ofSize: 10.0)
            starImageView.isHidden = true
            ratingShowingLabel.textColor = .white
            ViewCustomizationUtils.addCornerRadiusToView(view: ratingShowingLabel, cornerRadius: 10)
            ratingShowingLabel.text = Strings.new_user_matching_list
            ratingShowingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            ratingShowingLabel.layer.cornerRadius = 8.0
            ratingShowingLabel.layer.masksToBounds = true
        }
    }
    
    private func setDataForRiderOrPasenger(matchedUser: MatchedUser) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if matchedUser.userRole == MatchedUser.RIDER || matchedUser.userRole == MatchedUser.REGULAR_RIDER { //MARK: Ride giver
            //MARK: For Time
            if let time = matchedUser.pkTime {
                self.rideTimeShowingLabel.text =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            } else if let pickupTime = matchedUser.pickupTime, pickupTime != 0 {
                self.rideTimeShowingLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            } else {
                self.rideTimeShowingLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.startDate, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            }
            rideTakerPickUpDataView.isHidden = false
            rideGiverPickUpDataView.isHidden = true
            if rideDetailViewCellViewModel.matchedUser!.isReadyToGo {
                pointsShowingView.isHidden = false
                rideTimeShowingView.isHidden = true
                if rideDetailViewCellViewModel.matchedUser?.newFare != -1 {
                    let attributePoints = FareChangeUtils.getFareDetails(newFare:  matchedUser.newFare,actualFare: matchedUser.points!, rideType: Ride.PASSENGER_RIDE,textColor: pointsLabel.textColor)
                    let ponits = NSAttributedString(string: " \(Strings.points_new)")
                    let combination = NSMutableAttributedString()
                    combination.append(attributePoints)
                    combination.append(ponits)
                    pointsLabel.attributedText = combination
                } else {
                    pointsLabel.text = StringUtils.getStringFromDouble(decimalNumber: matchedUser.points) + " \(Strings.points_new)"
                }
            } else {
                pointsShowingView.isHidden = true
                rideTimeShowingView.isHidden = false
            }
            requestNumberOfSeatView.isHidden = true
            if rideDetailViewCellViewModel.matchedUser?.newFare != -1 {
                let attributePoints = FareChangeUtils.getFareDetails(newFare:  matchedUser.newFare,actualFare:  matchedUser.points!, rideType:  Ride.PASSENGER_RIDE, textColor: pointsOrPercentageRideMatchShowingLabel.textColor)
                let ponits = NSAttributedString(string: " \(Strings.points_new)")
                let combination = NSMutableAttributedString()
                combination.append(attributePoints)
                combination.append(ponits)
                pointsOrPercentageRideMatchShowingLabel.attributedText = combination
            } else {
                pointsOrPercentageRideMatchShowingLabel.text = StringUtils.getStringFromDouble(decimalNumber: ceil(matchedUser.points ?? 0)) + " \(Strings.points_new)"
            }
            ridetypeimageWidthConstraints.constant = 15
            dotSeparatorView.isHidden = false
            poolTypeView.isHidden = false
            if (matchedUser.userRole == MatchedUser.RIDER && (matchedUser as! MatchedRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE) || (matchedUser.userRole == MatchedUser.REGULAR_RIDER && (matchedUser as! MatchedRegularRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE) {
                rideTypeImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
                rideTypeImageView.tintColor = .lightGray
                carOrImageForWalkPathImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
                carOrImageForWalkPathImageView.tintColor = .lightGray
                passengerShowingStackViewWidth.constant = 0
                poolShowingLabel.isHidden = false
            } else {
                rideTypeImageView.image = UIImage(named: "car_solid")
                carOrImageForWalkPathImageView.image = UIImage(named: "car_solid")
                var capacity: Int?
                var availableSeats: Int?
                if let matchedUserAsRider = matchedUser as? MatchedRider {
                    capacity = matchedUserAsRider.capacity
                    availableSeats = matchedUserAsRider.availableSeats
                } else if let matchedUserAsRegularRider = matchedUser as? MatchedRegularRider {
                    capacity = matchedUserAsRegularRider.capacity
                    availableSeats = matchedUserAsRegularRider.capacity
                }
                passengerShowingStackViewWidth.constant = CGFloat((capacity ?? 1)*17)
                poolShowingLabel.isHidden = true
                setOccupiedSeats(availableSeats: (availableSeats ?? 1), capacity: capacity ?? 1)
            }
            let startLocation = CLLocation(latitude:rideDetailViewCellViewModel.ride!.startLatitude,longitude: rideDetailViewCellViewModel.ride!.startLongitude)
            let pickUpLoaction = CLLocation(latitude: matchedUser.pickupLocationLatitude!,longitude: matchedUser.pickupLocationLongitude!)
            let startToPickupWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: startLocation, point2: pickUpLoaction, polyline:rideDetailViewCellViewModel.ride!.routePathPolyline)
            walkPathdistanceShowingLabel.text = rideDetailViewCellViewModel.getDistanceString(distance: startToPickupWalkDistance)
            
            let endLocation =  CLLocation(latitude: rideDetailViewCellViewModel.ride!.endLatitude!, longitude: rideDetailViewCellViewModel.ride!.endLongitude!)
            let dropToEndWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: CLLocation(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!), point2: endLocation , polyline: rideDetailViewCellViewModel.ride!.routePathPolyline)
            afterRideWalkingDistanceShowingLabel.text = rideDetailViewCellViewModel.getDistanceString(distance: dropToEndWalkDistance)
            if (startToPickupWalkDistance + dropToEndWalkDistance) < Double(clientConfiguration.maximumWalkDistanceForFullMatch ?? 0){
                handleVisibilityOfFullMatchAnimation(isRequiredToShow: true)
            }else {
                handleVisibilityOfFullMatchAnimation(isRequiredToShow: false)
                if let matchPercentage = matchedUser.matchPercentage {
                    matchingPercentageORPriceShowingLabel.isHidden = false
                    routeMatchOrPointsShowingLabel.isHidden = false
                    matchingPercentageORPriceShowingLabel.text = "\(matchPercentage)" + Strings.percentage_symbol
                    routeMatchOrPointsShowingLabel.text = Strings.route_match
                } else {
                    matchingPercentageORPriceShowingLabel.isHidden = true
                    routeMatchOrPointsShowingLabel.isHidden = true
                }
            }
        } else { //MARK: Ride taker
            rideTakerPickUpDataView.isHidden = true
            rideGiverPickUpDataView.isHidden = false
            if let time = matchedUser.psgReachToPk {
                self.rideTimeShowingLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            }else {
                self.rideTimeShowingLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.passengerReachTimeTopickup, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            }
            ridetypeimageWidthConstraints.constant = 0
            routeMatchOrPointsShowingLabel.text = Strings.points_new
            pointsShowingView.isHidden = true
            rideTimeShowingView.isHidden = false
            dotSeparatorView.isHidden = true
            poolTypeView.isHidden = true
            if rideDetailViewCellViewModel.matchedUser?.newFare != -1 && (rideDetailViewCellViewModel.matchedUser as? MatchedPassenger)?.passengerTaxiRideId != 0{
                matchingPercentageORPriceShowingLabel.attributedText = FareChangeUtils.getFareDetails(newFare:  matchedUser.newFare, actualFare:  matchedUser.points!, rideType: Ride.RIDER_RIDE,textColor: matchingPercentageORPriceShowingLabel.textColor)
            }else{
                matchingPercentageORPriceShowingLabel.text = StringUtils.getStringFromDouble(decimalNumber: floor(matchedUser.points ?? 0 ))
            }
            var numberOfSeatRequired = 1
            if let noOfSeats = (rideDetailViewCellViewModel.matchedUser as? MatchedPassenger)?.requiredSeats {
                numberOfSeatRequired = noOfSeats
            } else if let noOfSeats = (rideDetailViewCellViewModel.matchedUser as? MatchedRegularPassenger)?.noOfSeats {
                numberOfSeatRequired = noOfSeats
            }
            if numberOfSeatRequired > 1 {
                numberOfSeatsForPassengerWidthConstrasaints.constant = 40
                requestNumberOfSeatView.isHidden = false
                numberOfSeatsLabel.text = "+ \(String(describing: numberOfSeatRequired))"
            }else{
                numberOfSeatsForPassengerWidthConstrasaints.constant = 0
                requestNumberOfSeatView.isHidden = true
            }
            if matchedUser.userRole == MatchedUser.RIDER && (matchedUser as! MatchedRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                carOrBikeImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
                carOrBikeImageView.tintColor = .lightGray
            } else {
                carOrBikeImageView.image = UIImage(named: "car_solid")
            }
            
            let startLocation = CLLocation(latitude:rideDetailViewCellViewModel.ride!.startLatitude,longitude: rideDetailViewCellViewModel.ride!.startLongitude)
            let pickUpLoaction = CLLocation(latitude: matchedUser.pickupLocationLatitude!,longitude: matchedUser.pickupLocationLongitude!)
            let distance = GoogleMapUtils.getWalkPathForMatchedUser(point1: startLocation, point2: pickUpLoaction , polyline: rideDetailViewCellViewModel.ride!.routePathPolyline)
            rideGiverPickUpDistanceLabel.text = rideDetailViewCellViewModel.getDistanceString(distance: distance)
            travellingDistanceShowingLabel.text = "\(matchedUser.distance?.roundToPlaces(places: 2) ?? 0.0) \(Strings.KM)"
        }
    }
    
    private func handleVisibilityOfFullMatchAnimation(isRequiredToShow: Bool) {
        if isRequiredToShow {
            routeMatchAndPointsContainingStackView.isHidden = true
            fullMatchAnimationContainerView.isHidden = false
            fullMatchAnimationview.animationView.animation = Animation.named("full_match_lottie")
            fullMatchAnimationview.animationView.play()
            fullMatchAnimationview.animationView.loopMode = .loop
        }else {
            routeMatchAndPointsContainingStackView.isHidden = false
            fullMatchAnimationContainerView.isHidden = true
        }
    }
    
    private func setOccupiedSeats(availableSeats: Int, capacity: Int) {
        for (index, imageView) in numberOfSeatsImageArray.enumerated() {
            imageView.isHidden = !(index < capacity)
            imageView.image = index < capacity - availableSeats ? UIImage(named: "seat_occupied") : UIImage(named: "seats_not_occupied")
        }
    }
    
    private func handleRideMatchDetailView() {
        if rideDetailViewCellViewModel.matchedUser?.matchingSortingStatus == MatchedUser.ENABLE_CALL_OPTION_TO_INACTIVE_USER {
            riderIsOfflineView.isHidden = false
            rideMatchDetailsStackView.isHidden = true
        } else{
            riderIsOfflineView.isHidden = true
            rideMatchDetailsStackView.isHidden = false
        }
    }
    
    @IBAction func showNotePopUpButtonPressed(_ sender: UIButton) {
        guard let rideNotes = rideDetailViewCellViewModel.matchedUser?.rideNotes, !rideNotes.isEmpty else {return}
        MessageDisplay.displayInfoDialogue(title: Strings.ride_notes, message: rideNotes, viewController: viewController)
    }
    
    @IBAction func gotItButtonTapped(_ sender: UIButton) {
        userSelectionDelegate?.gotItAction()
    }
    
    @IBAction func changePlanButtonTapped(_ sender: UIButton) {
        userSelectionDelegate?.changePlanAction()
    }
    
    @IBAction func joinButtonTapped(_ sender: UIButton) {
        if callToInviteButton.backgroundColor == UIColor(netHex: 0xcad2de) {
            joinProgressImageView.isHidden = false
            joinProgressImageView.startAnimating()
            rideDetailViewCellViewModel.inviteClicked(matchedUser: rideDetailViewCellViewModel.matchedUser, viewController: viewController!.navigationController!.topViewController!)
        } else {
            showCallToJoinDetailsVC()
        }
    }
    
    private func showCallToJoinDetailsVC() {
        if let matchedRider = rideDetailViewCellViewModel.matchedUser as? MatchedRider {
            if matchedRider.rideStatus == Ride.RIDE_STATUS_STARTED {
                let callToJoinPopVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CallToJoinConfirmationViewController") as! CallToJoinConfirmationViewController
                callToJoinPopVC.initializeViews(rideStatus: matchedRider.rideStatus) { (action) in
                    if action == Strings.call_to_join {
                        self.joinProgressImageView.isHidden = false
                        self.joinProgressImageView.startAnimating()
                        self.rideDetailViewCellViewModel.inviteClicked(matchedUser: self.rideDetailViewCellViewModel.matchedUser, viewController: self.viewController!.navigationController!.topViewController!)
                        self.performCallAction(isCallDisabled: false)
                    } else if action == Strings.continue_to_invite {
                        self.joinProgressImageView.isHidden = false
                        self.joinProgressImageView.startAnimating()
                        self.rideDetailViewCellViewModel.inviteClicked(matchedUser: self.rideDetailViewCellViewModel.matchedUser, viewController: self.viewController!.navigationController!.topViewController!)
                    }
                }
                ViewControllerUtils.addSubView(viewControllerToDisplay: callToJoinPopVC)
            } else {
                joinProgressImageView.isHidden = false
                joinProgressImageView.startAnimating()
                rideDetailViewCellViewModel.inviteClicked(matchedUser: rideDetailViewCellViewModel.matchedUser, viewController: self.viewController!.navigationController!.topViewController!)
            }
        }
    }
    
    @IBAction func callToJoinButtonTapped(_ sender: UIButton) {
        var isCallDisabled = false
        if sender.backgroundColor == UIColor(netHex: 0xcad2de) {
            isCallDisabled = true
        } else {
            rideDetailViewCellViewModel.inviteClicked(matchedUser: rideDetailViewCellViewModel.matchedUser, viewController: viewController!.navigationController!.topViewController!)
        }
        performCallAction(isCallDisabled: isCallDisabled)
    }
    
    @IBAction func inviteOrJoinClickedTapped(_ sender: UIButton) {
        if rideDetailViewCellViewModel.selectedUserDelegate != nil {
            userSelectionDelegate?.selectedUserDelegate()
        } else {
            inviteClicked(matchedUser: rideDetailViewCellViewModel.matchedUser!, position: rideDetailViewCellViewModel.selectedIndex)
        }
    }
    
    @IBAction func declineInviteButtontapped(_ sender: UIButton) {
        userSelectionDelegate?.declineInviteAction(rideInvitation: rideDetailViewCellViewModel.rideInvitation)
    }
    
    @IBAction func callBtnPressed(_ sender: UIButton) {
        var isCallDisabled = false
        if sender.backgroundColor == UIColor(netHex: 0xcad2de) {
            isCallDisabled = true
        }
        performCallAction(isCallDisabled: isCallDisabled)
    }
    
    private func performCallAction(isCallDisabled: Bool) {
        if isCallDisabled {
            UIApplication.shared.keyWindow?.makeToast( Strings.call_disable_msg)
            return
        }
        guard let ride = rideDetailViewCellViewModel.ride, let rideType = rideDetailViewCellViewModel.ride?.rideType else { return }
        let refID = rideType+StringUtils.getStringFromDouble(decimalNumber: ride.rideId)
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: rideDetailViewCellViewModel.matchedUser!.userid), refId: refID, name: rideDetailViewCellViewModel.matchedUser?.name ?? "", targetViewController: viewController!.navigationController!.topViewController!)
    }
    @IBAction func chatOptionPressed(_ sender: UIButton) {
        guard let userId = rideDetailViewCellViewModel.matchedUser?.userid else { return }
        let chatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatViewController.initializeDataBeforePresentingView(ride: rideDetailViewCellViewModel.ride, userId: userId, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: chatViewController, animated: false)
    }
    
    @IBAction func moreOptionPressed(_ sender: UIButton) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.remind, style: .default) { action -> Void in
            self.inviteClicked(matchedUser: self.rideDetailViewCellViewModel.matchedUser!, position: self.rideDetailViewCellViewModel.selectedIndex)
        }
        let secondAction: UIAlertAction = UIAlertAction(title: Strings.cancel_invite, style: .default) { action -> Void in
            let getTheInvitation = self.rideDetailViewCellViewModel.getOutGoingInviteForRide()
            if let invitation = getTheInvitation {
                self.userSelectionDelegate?.cancelSelectedUserPressed(invitation: invitation, status: 0)
            } else {
                return
            }
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        viewController?.present(actionSheetController, animated: true)
    }
    
    
    @objc private func tapped(_ sender:UITapGestureRecognizer) {
        if rideDetailViewCellViewModel.matchedUser == nil{
            return
        }
        let profile:ProfileDisplayViewController = (UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController)
        let profileData = rideDetailViewCellViewModel.prepareDataForProfileView()
        profile.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: rideDetailViewCellViewModel.matchedUser!.userid!),isRiderProfile: profileData.userRole! , rideVehicle: profileData.vehicle,userSelectionDelegate: self,displayAction: true, isFromRideDetailView : false, rideNotes: rideDetailViewCellViewModel.matchedUser?.rideNotes, matchedRiderOnTimeCompliance: rideDetailViewCellViewModel.matchedUser!.userOnTimeComplianceRating, noOfSeats: (rideDetailViewCellViewModel.matchedUser as? MatchedPassenger)?.requiredSeats, isSafeKeeper: rideDetailViewCellViewModel.matchedUser!.hasSafeKeeperBadge)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: profile, animated: false)
    }
    
    @IBAction func readyToGoFareChangeBtnPressed(_ sender: UIButton) {
        showFareChangeView()
    }
    
    @IBAction func fareChangeBtnPressed(_ sender: UIButton) {
        showFareChangeView()
    }
}
//MARK: Farechange
extension InstantRideMatchedUserCollectionViewCell {
    private func handleFareChangeView() {
        if FareChangeUtils.isFareChangeApplicable(matchedUser: rideDetailViewCellViewModel.matchedUser!) {
            if rideDetailViewCellViewModel.matchedUser!.isReadyToGo && rideActionAndMatchedUserDetailView.isHidden {
                fareChangeButton.isUserInteractionEnabled = false
                readyToGoFareChangeButton.isUserInteractionEnabled = true
                pointsOrPercentageRideMatchShowingLabel.isUserInteractionEnabled = false
            } else if rideDetailViewCellViewModel.matchedUser!.userRole == MatchedUser.PASSENGER {
                pointsOrPercentageRideMatchShowingLabel.isUserInteractionEnabled = false
                readyToGoFareChangeButton.isUserInteractionEnabled = false
                fareChangeButton.isUserInteractionEnabled = true
                matchingPercentageORPriceShowingLabel.textColor = UIColor(netHex: 0x2196F3)
            } else if rideDetailViewCellViewModel.matchedUser!.userRole == MatchedUser.RIDER {
                fareChangeButton.isUserInteractionEnabled = false
                readyToGoFareChangeButton.isUserInteractionEnabled = false
                pointsOrPercentageRideMatchShowingLabel.isUserInteractionEnabled = true
                pointsOrPercentageRideMatchShowingLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fareChangeTapped(_:))))
                pointsOrPercentageRideMatchShowingLabel.textColor = UIColor(netHex: 0x2196F3)
                
            }else{
                readyToGoFareChangeButton.isUserInteractionEnabled = false
                pointsOrPercentageRideMatchShowingLabel.isUserInteractionEnabled = false
                fareChangeButton.isUserInteractionEnabled = false
                pointsOrPercentageRideMatchShowingLabel.textColor = UIColor(netHex: 0x26AA4F)
                matchingPercentageORPriceShowingLabel.textColor = UIColor(netHex: 0x26AA4F)
            }
        } else {
            readyToGoFareChangeButton.isUserInteractionEnabled = false
            pointsOrPercentageRideMatchShowingLabel.isUserInteractionEnabled = false
            fareChangeButton.isUserInteractionEnabled = false
            pointsOrPercentageRideMatchShowingLabel.textColor = UIColor(netHex: 0x26AA4F)
            matchingPercentageORPriceShowingLabel.textColor = UIColor(netHex: 0x26AA4F)
        }
    }
    
    @objc private func fareChangeTapped(_ gesture: UITapGestureRecognizer) {
        showFareChangeView()
    }
    
    private func showFareChangeView() {
        var noOfSeats = 1
        var rideFarePerKm = 0.0
        if rideDetailViewCellViewModel.ride!.isKind(of:PassengerRide.classForCoder()){
            noOfSeats = (rideDetailViewCellViewModel.ride as! PassengerRide).noOfSeats
            rideFarePerKm = (rideDetailViewCellViewModel.matchedUser as! MatchedRider).fare ?? 0.0
        }else if rideDetailViewCellViewModel.matchedUser!.isKind(of: MatchedPassenger.classForCoder()){
            noOfSeats = (rideDetailViewCellViewModel.matchedUser as! MatchedPassenger).requiredSeats
            rideFarePerKm = (rideDetailViewCellViewModel.ride as! RiderRide).farePerKm
        }
        let fareChangeViewController = UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "FareChangeViewController") as! FareChangeViewController
        fareChangeViewController.initializeDataBeforePresenting(rideType: rideDetailViewCellViewModel.ride!.rideType!,actualFare: rideDetailViewCellViewModel.matchedUser!.points!,distance: rideDetailViewCellViewModel.matchedUser!.distance!,selectedSeats: noOfSeats, farePerKm: rideFarePerKm) { (actualFare, requestedFare) in
            self.rideDetailViewCellViewModel.matchedUser?.newFare = requestedFare
            self.rideDetailViewCellViewModel.matchedUser?.fareChange = true
            self.updateNewFare(selectedUser: self.rideDetailViewCellViewModel.matchedUser!)
        }
        ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: fareChangeViewController, animated: false, completion: nil)
    }
    
    private func updateNewFare(selectedUser : MatchedUser) {
        if rideDetailViewCellViewModel.matchedUser!.rideid == selectedUser.rideid && rideDetailViewCellViewModel.matchedUser!.userRole == selectedUser.userRole{
            rideDetailViewCellViewModel.matchedUser!.newFare = selectedUser.newFare
            inviteClicked(matchedUser: selectedUser,position: -1)
            if viewController != nil{
                if viewController!.isKind(of: RideDetailedViewController.classForCoder()) {
                    let rideDetailedViewController = (viewController as! RideDetailedViewController)
                    rideDetailedViewController.userDetailTableView.reloadData()
                } else if viewController!.isKind(of: SendInviteBaseViewController.classForCoder()) {
                    let sendInviteBaseViewController = (viewController as! SendInviteBaseViewController)
                    sendInviteBaseViewController.iboTableView.reloadData()
                }
            }
        }
    }
}
//MARK: Invite
extension InstantRideMatchedUserCollectionViewCell {
    private func inviteClicked(matchedUser: MatchedUser,position : Int) {
        if position >= 0 {
            inviteProgressImageView.isHidden = false
            inviteProgressImageView.startAnimating()
        }
        rideDetailViewCellViewModel.inviteClicked(matchedUser: matchedUser, viewController: viewController!.navigationController!.topViewController!)
    }
    
    private func handleCustomizationToInviteView(){
        inviteProgressImageView.animationImages
            = [UIImage(named: "match_option_invite_progress_1"),UIImage(named: "match_option_invite_progress_2")] as? [UIImage]
        inviteProgressImageView.isHidden = true
        inviteProgressImageView.animationDuration = 0.3
        joinProgressImageView.animationImages
            = [UIImage(named: "match_option_invite_progress_1"),UIImage(named: "match_option_invite_progress_2")] as? [UIImage]
        joinProgressImageView.isHidden = true
        joinProgressImageView.animationDuration = 0.3
    }
}
//MARK: inviteButton Title show hide
extension InstantRideMatchedUserCollectionViewCell {
    private func checkAndSetInvitedLabel() {
        if drawerState == .full {
            readyToGoActionView.isHidden = true
            if rideDetailViewCellViewModel.matchedUser!.isReadyToGo {
                seperateView.isHidden = true
                rideActionAndMatchedUserDetailView.isHidden = true
                rideActionAndMatchedUserHeightConstraint.constant = 0
            } else {
                seperateView.isHidden = false
                rideActionAndMatchedUserDetailView.isHidden = false
                rideActionAndMatchedUserHeightConstraint.constant = 40
            }
            rideConfirmActionView.isHidden = true
            rideConfirmActionHeightConstraint.constant = 0
            declineRideButton.isHidden = true
            declineButtonWidthConstaint.constant = 0
            inviteProgressImageView.isHidden =  true
            inviteOrOfferRideShowingView.isHidden = true
            contactOptionShowingView.isHidden = true
        } else {
            if rideDetailViewCellViewModel.viewType == DetailViewType.RideConfirmView {
                rideConfirmActionView.isHidden = false
                rideConfirmActionHeightConstraint.constant = 35
                contactOptionShowingView.isHidden = true
            } else {
                rideConfirmActionView.isHidden = true
                rideConfirmActionHeightConstraint.constant = 0
                handleCustomizationToInviteView()
                setTitleToInviteBtn()
                if rideDetailViewCellViewModel.ride?.rideId == nil || rideDetailViewCellViewModel.ride?.rideId.isZero == true {
                    joinButton.isHidden = false
                    joinProgressImageView.isHidden = true
                    inviteOrOfferRideBtn.isHidden = false
                    declineRideButton.isHidden = true
                    declineButtonWidthConstaint.constant = 0
                    inviteProgressImageView.isHidden =  true
                    inviteOrOfferRideShowingView.isHidden = false
                    checkContactVisibility()
                    hideCallBtn()
                    return
                }
                if rideDetailViewCellViewModel.ride?.rideId == nil || rideDetailViewCellViewModel.ride?.rideId.isZero == true || rideDetailViewCellViewModel.ride?.rideType == nil || rideDetailViewCellViewModel.ride?.rideType!.isEmpty == true{
                    return
                }
                
                let invite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: rideDetailViewCellViewModel.ride!.rideId, rideType: rideDetailViewCellViewModel.ride!.rideType!, matchedUserRideId: rideDetailViewCellViewModel.matchedUser!.rideid!,matchedUserTaxiRideId: (rideDetailViewCellViewModel.matchedUser as? MatchedPassenger)?.passengerTaxiRideId)
                
                if invite != nil && rideDetailViewCellViewModel.matchedUser!.newFare == invite!.newFare {
                    rideDetailViewCellViewModel.rideInvitation = invite
                    inviteOrOfferRideBtn.setTitle( Strings.ACCEPT_CAPS, for: .normal)
                    joinButton.setTitle(Strings.ACCEPT_CAPS, for: .normal)
                    seperateView.isHidden = false
                    rideActionAndMatchedUserDetailView.isHidden = false
                    pointsShowingView.isHidden = true
                    rideTimeShowingView.isHidden = false
                    rideActionAndMatchedUserHeightConstraint.constant = 40
                    readyToGoActionView.isHidden = true
                    declineRideButton.isHidden = false
                    declineButtonWidthConstaint.constant = 30
                    inviteOrOfferRideBtn.isHidden = false
                    joinButton.isHidden = false
                    joinProgressImageView.isHidden = true
                    inviteProgressImageView.isHidden =  true
                    inviteOrOfferRideShowingView.isHidden = false
                    hideCallBtn()
                }else if Ride.RIDER_RIDE == rideDetailViewCellViewModel.ride?.rideType{
                    handleVisibilityOfInviteElementsBasedOnInvite(riderRideId: rideDetailViewCellViewModel.ride!.rideId, passengerRideId: rideDetailViewCellViewModel.matchedUser!.rideid!)
                }else{
                    handleVisibilityOfInviteElementsBasedOnInvite( riderRideId: rideDetailViewCellViewModel.matchedUser!.rideid!, passengerRideId: rideDetailViewCellViewModel.ride!.rideId)
                }
            }
        }
    }
    private func setTitleToInviteBtn() {
        if Ride.RIDER_RIDE == rideDetailViewCellViewModel.ride?.rideType{
            inviteOrOfferRideBtn.setTitle(Strings.OFFER_RIDE_CAPS, for: .normal)
            joinButton.setTitle( Strings.OFFER_RIDE_CAPS, for: .normal)
        }else{
            inviteOrOfferRideBtn.setTitle(Strings.JOIN_CAPS, for: .normal)
            joinButton.setTitle( Strings.JOIN_CAPS, for: .normal)
        }
    }
    
    private func handleVisibilityOfInviteElementsBasedOnInvite(riderRideId : Double,passengerRideId : Double){
        let invite =  RideInviteCache.getInstance().getOutGoingInvitationPresentBetweenRide(riderRideId: riderRideId, passengerRideId: passengerRideId, rideType: rideDetailViewCellViewModel.ride!.rideType!,userId: rideDetailViewCellViewModel.matchedUser!.userid!)
        if invite != nil{
            joinProgressImageView.isHidden = true
            inviteOrOfferRideBtn.isHidden = true
            declineRideButton.isHidden = true
            declineButtonWidthConstaint.constant = 0
            inviteProgressImageView.isHidden =  true
            inviteOrOfferRideShowingView.isHidden = true
            handleCallBtnVisibility()
        }else{
            joinButton.isHidden = false
            joinProgressImageView.isHidden = true
            inviteOrOfferRideBtn.isHidden = false
            declineRideButton.isHidden = true
            declineButtonWidthConstaint.constant = 0
            inviteProgressImageView.isHidden =  true
            inviteOrOfferRideShowingView.isHidden = false
            checkContactVisibility()
            hideCallBtn()
        }
    }
    
    private func hideCallBtn() {
        contactOptionShowingView.isHidden = true
        rideMatchDetailsStackView.isHidden = false
        riderIsOfflineView.isHidden = true
    }
    
    private func handleCallBtnVisibility() {
        contactOptionShowingView.isHidden = false
        rideActionAndMatchedUserDetailView.isHidden = false
        readyToGoActionView.isHidden = true
        if rideDetailViewCellViewModel.matchedUser!.isReadyToGo {
//            callToInviteOptionButton.isHidden = false
//            callOptionBtn.isHidden = true
//            chatOptionBtn.isHidden = true
            pointsShowingView.isHidden = true
            rideTimeShowingView.isHidden = false
        }
//        else {
//            callToInviteOptionButton.isHidden = true
//            callOptionBtn.isHidden = false
//            chatOptionBtn.isHidden = false
//        }
        checkContactVisibility()
    }
    
    private func checkContactVisibility() {
        if UserProfile.SUPPORT_CALL_ALWAYS == rideDetailViewCellViewModel.matchedUser!.callSupport && rideDetailViewCellViewModel.matchedUser!.enableChatAndCall {
            handleCallOptions()
        }else if rideDetailViewCellViewModel.matchedUser!.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED && rideDetailViewCellViewModel.matchedUser!.enableChatAndCall {
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: rideDetailViewCellViewModel.matchedUser?.userid))
            if contact != nil && contact!.contactType == Contact.RIDE_PARTNER{
                handleCallOptions()
            }else{
                riderIsOfflineView.isHidden = true
                rideMatchDetailsStackView.isHidden = false
                enableCallOption(status: false)
            }
        }else{
            riderIsOfflineView.isHidden = true
            rideMatchDetailsStackView.isHidden = false
            enableCallOption(status: false)
        }
    }
    
    private func handleCallOptions() {
        if rideDetailViewCellViewModel.matchedUser?.matchingSortingStatus == MatchedUser.ENABLE_CALL_OPTION_TO_INACTIVE_USER {
            riderIsOfflineView.isHidden = false
            rideMatchDetailsStackView.isHidden = true
            enableCallOption(status: true)
        } else {
            riderIsOfflineView.isHidden = true
            rideMatchDetailsStackView.isHidden = false
            enableCallOption(status: true)
        }
    }
    
    private func enableCallOption(status: Bool) {
        if status {
            callOptionBtn.backgroundColor = UIColor(netHex: 0x2196F3)
            callToInviteButton.backgroundColor = UIColor(netHex: 0xFCA126)
            callToInviteOptionButton.backgroundColor = UIColor(netHex: 0xFCA126)
        }else{
            callOptionBtn.backgroundColor = UIColor(netHex: 0xcad2de)
            callToInviteButton.backgroundColor = UIColor(netHex: 0xcad2de)
            callToInviteOptionButton.backgroundColor = UIColor(netHex: 0xcad2de)
        }
    }
}

extension InstantRideMatchedUserCollectionViewCell: RideActionCompletionDelegate {
    func stopAnimatingProgressView(matchedUser: MatchedUser?) {
        if matchedUser?.userid != rideDetailViewCellViewModel.matchedUser?.userid {
            return
        }
        inviteProgressImageView.stopAnimating()
        inviteProgressImageView.isHidden = true
        joinProgressImageView.stopAnimating()
        joinProgressImageView.isHidden = true
        if viewController != nil{
            if viewController!.isKind(of: RideDetailedViewController.classForCoder()) {
                let rideDetailedViewController = (viewController as! RideDetailedViewController)
                rideDetailedViewController.userDetailTableView.reloadData()
            } else if viewController!.isKind(of: SendInviteBaseViewController.classForCoder()) {
                let sendInviteBaseViewController = (viewController as! SendInviteBaseViewController)
                sendInviteBaseViewController.iboTableView.reloadData()
            }
        }
    }
    
    func displayAckForRideRequest(matchedUser: MatchedUser) {
        userSelectionDelegate?.displayAckForRideRequest(matchedUser: matchedUser)
    }
}


extension InstantRideMatchedUserCollectionViewCell: UserSelectedDelegate {
    func userSelected() {
        rideDetailViewCellViewModel.inviteClicked(matchedUser: rideDetailViewCellViewModel.matchedUser, viewController: viewController!.navigationController!.topViewController!)
    }
    
    func userNotSelected() { }
}
