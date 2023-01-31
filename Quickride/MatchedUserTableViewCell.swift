//
//  MatchedUserTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 10/02/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation
import Lottie

protocol MatchedUserTableViewCellUserSelectionDelegate : class{
    func userSelectedAtIndex(row :Int,matchedUser : MatchedUser)
    func userUnSelectedAtIndex(row : Int,matchedUser : MatchedUser)
    func cancelSelectedUserPressed(invitation: RideInvitation, status: Int)
}

protocol MatchedUserTableViewCellProfileVerificationViewDelegate: class {
    func hideProfileVerificationView()
}


class MatchedUserTableViewCell: UITableViewCell {
    //MARK: OUTLETS
    //MARK: First Time bouns
    @IBOutlet weak var firstTimeBounsView: UIView!
    @IBOutlet weak var firstTimeBounsViewHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var firstTimeBounsDetailsLabel: UILabel!
    //MARK: cardView
    @IBOutlet weak var backGroundView: QuickRideCardView!
    //MARK: lastRideCreated date and long Distance
    @IBOutlet weak var lastRideCreatedLabel: UILabel!
    @IBOutlet weak var longDistanceLabel: UILabel!

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var requestImageView: UIImageView!
    @IBOutlet weak var requestMessageLabel: UILabel!
    @IBOutlet weak var topSeparatorView: UIView!
    @IBOutlet weak var rideStatusLabel: UILabel!
    //MARK: Profile
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var safeKeeperButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var requestNumberOfSeatView: UIView!
    @IBOutlet weak var numberOfSeatsLabel: UILabel!
    @IBOutlet weak var numberOfSeatsForPassengerWidthConstrasaints: NSLayoutConstraint!

    @IBOutlet weak var profileVerificationImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var ratingShowingLabel: UILabel!
    @IBOutlet weak var ratingShowingLabelHeightConstraints: NSLayoutConstraint!

    @IBOutlet weak var matchingPercentageORPriceShowingLabel: UILabel!
    @IBOutlet weak var fareChangeButton: UIButton!
    @IBOutlet weak var routeMatchOrPointsShowingLabel: UILabel!
    @IBOutlet weak var rideTimeImageView: UIImageView!
    @IBOutlet weak var rideTimeShowingLabel: UILabel!
    @IBOutlet weak var favoriteIconShowingImageView: UIImageView!
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
    @IBOutlet weak var rideTypeImageView: UIImageView!
    @IBOutlet weak var passengerShowingStackViewWidth: NSLayoutConstraint!
    @IBOutlet weak var firstSeatImageView: UIImageView!
    @IBOutlet weak var secondSeatImageView: UIImageView!
    @IBOutlet weak var thirdSeatImageView: UIImageView!
    @IBOutlet weak var fouthSeatImageView: UIImageView!
    @IBOutlet weak var fifthSeatImageView: UIImageView!
    @IBOutlet weak var sixthSeatImageView: UIImageView!
    @IBOutlet weak var dotSeparatorView: UIView!
    @IBOutlet weak var poolShowingLabel: UILabel!
    @IBOutlet weak var poolTypeView: UIView!
    @IBOutlet weak var pointsOrPercentageRideMatchShowingLabel: UILabel!
    @IBOutlet weak var ridetypeimageWidthConstraints: NSLayoutConstraint!
    //MARK: Contact Options
    @IBOutlet weak var contactOptionShowingView: UIView!
    @IBOutlet weak var callOptionBtn: UIButton!
    @IBOutlet weak var chatOptionBtn: UIButton!
    @IBOutlet weak var moreOptionBtn: UIButton!
    //MARK: Invite
    @IBOutlet weak var inviteOrOfferRideShowingView: UIView!
    @IBOutlet weak var inviteProgressImageView: UIImageView!
    @IBOutlet weak var inviteOrOfferRideBtn: UIButton!
    //MARK: Ride Note view
    @IBOutlet weak var rideNoteView: UIView!
    @IBOutlet weak var noteShowingLabel: UILabel!
    @IBOutlet weak var riderIsOfflineView: UIView!
    @IBOutlet weak var rideMatchDetailsStackView: UIStackView!

    @IBOutlet weak var viewAllButtonExtendedView: UIView!
    @IBOutlet weak var sectionHeaderLabel: UILabel!
    @IBOutlet weak var routeMatchAndPointsContainingStackView: UIStackView!
    @IBOutlet weak var fullMatchAnimationContainerView: UIView!
    @IBOutlet weak var fullMatchAnimationview: AnimatedControl!
    

    //MARK: Variables
    private var numberOfSeatsImageArray = [UIImageView]()
    private var gradientLayer = CAGradientLayer()
    weak var viewController : UIViewController?
    private var matchedUserCellViewModel = MatchedUserCellViewModel()
    private var rideInviteActionCompletionListener : RideInvitationActionCompletionListener?
    weak var delegate : MatchedUserTableViewCellProfileVerificationViewDelegate?
    weak var matchedUserSelectionDelegate: MatchedUserTableViewCellUserSelectionDelegate?
    weak var userSelectionDelegate : UserSelectedDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        numberOfSeatsImageArray = [firstSeatImageView,secondSeatImageView,thirdSeatImageView,fouthSeatImageView,fifthSeatImageView,sixthSeatImageView]
    }
    override func prepareForReuse() {
        profileImageView.image = nil
    }

    func initialiseUIWithData(rideId : Double?, rideType : String?,matchUser:MatchedUser,isSelected : Bool?, matchedUserSelectionDelegate: MatchedUserTableViewCellUserSelectionDelegate,viewController : UIViewController, row: Int,ride : Ride?,rideInviteActionCompletionListener : RideInvitationActionCompletionListener?, userSelectionDelegate : UserSelectedDelegate?) {
        if let isSelected = isSelected {
            matchedUserCellViewModel.selectedUser = isSelected
        }else{
            matchedUserCellViewModel.selectedUser = false
        }
        self.matchedUserSelectionDelegate = matchedUserSelectionDelegate
        self.userSelectionDelegate = userSelectionDelegate
        matchedUserCellViewModel.matchedUser = matchUser
        matchedUserCellViewModel.rideId = rideId
        matchedUserCellViewModel.rideType = rideType
        matchedUserCellViewModel.ride = ride
        matchedUserCellViewModel.row = row
        self.rideInviteActionCompletionListener = rideInviteActionCompletionListener
        self.viewController = viewController
        setUpUI()
        checkAndDisplayRideLastCreatedTime()
        checkAndSetInvitedLabel()
        getSetInviteStatusView()
        handleFareChangeView()
    }

    private func setUpUI() {
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        self.profileImageView.image = nil
        if let userImageURI = matchedUserCellViewModel.matchedUser?.imageURI, !userImageURI.isEmpty{
            ImageCache.getInstance().getImageFromCache(imageUrl: userImageURI, imageSize: ImageCache.DIMENTION_SMALL, handler : {(image, imageURI) in
                if let image = image , imageURI == self.matchedUserCellViewModel.matchedUser!.imageURI{

                    ImageCache.getInstance().checkAndSetCircularImage(imageView: self.profileImageView, image: image)
                }else{
                    ImageCache.getInstance().getImageFromCache(imageUrl: userImageURI, imageSize: ImageCache.DIMENTION_SMALL, handler : {(image, imageURI) in
                        if let image = image , imageURI == self.matchedUserCellViewModel.matchedUser!.imageURI{

                            ImageCache.getInstance().checkAndSetCircularImage(imageView: self.profileImageView, image: image)
                        }else{
                            self.profileImageView.image = ImageCache.getInstance().getDefaultUserImage(gender: self.matchedUserCellViewModel.matchedUser?.gender ?? "U")
                        }
                    })
                }
            })
        }else{
            profileImageView.image = ImageCache.getInstance().getDefaultUserImage(gender: matchedUserCellViewModel.matchedUser?.gender ?? "U")
        }


//        ImageCache.getInstance().setImageToView(imageView: profileImageView, imageUrl: matchedUserCellViewModel.matchedUser?.imageURI ?? "", gender: matchedUserCellViewModel.matchedUser?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        nameLabel.text = matchedUserCellViewModel.matchedUser?.name?.capitalized
        companyNameLabel.text = matchedUserCellViewModel.getCompanyName()
        if companyNameLabel.text == Strings.not_verified {
            companyNameLabel.textColor = UIColor.black
        }else{
            companyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        setDollarSymbolToNewUser(matchedUser: matchedUserCellViewModel.matchedUser!)
        favoriteIconShowingImageView.isHidden = matchedUserCellViewModel.isFavouritePartner()
        if (matchedUserCellViewModel.matchedUser?.rating)! > 0.0{
            ratingShowingLabelHeightConstraints.constant = 20.0
            ratingShowingLabel.font = UIFont.systemFont(ofSize: 13.0)
            starImageView.isHidden = false
            ratingShowingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingShowingLabel.text = String(matchedUserCellViewModel.matchedUser!.rating!) + "(\(String(matchedUserCellViewModel.matchedUser!.noOfReviews)))"
            ratingShowingLabel.backgroundColor = .clear
            ratingShowingLabel.layer.cornerRadius = 0.0
        }else{
            ratingShowingLabelHeightConstraints.constant = 15.0
            ratingShowingLabel.font = UIFont.boldSystemFont(ofSize: 10.0)
            starImageView.isHidden = true
            ratingShowingLabel.textColor = .white
            ratingShowingLabel.text = Strings.new_user_matching_list
            ratingShowingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            ratingShowingLabel.layer.cornerRadius = 8.0
            ratingShowingLabel.layer.masksToBounds = true
        }
        profileVerificationImageView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: matchedUserCellViewModel.matchedUser?.profileVerificationData)
        if let rideNotes = matchedUserCellViewModel.matchedUser?.rideNotes, !rideNotes.isEmpty {
            noteShowingLabel.text = rideNotes
            rideNoteView.isHidden = false
        } else {
            noteShowingLabel.text = ""
            rideNoteView.isHidden = true
        }
        setDataForRiderOrPasenger(matchedUser: matchedUserCellViewModel.matchedUser!)
        handleSafeKeeperBadge()
    }

    private func handleSafeKeeperBadge() {
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil {
            clientConfiguration = ClientConfigurtion()
        }
        if clientConfiguration!.showCovid19SelfAssessment ?? false && matchedUserCellViewModel.matchedUser!.hasSafeKeeperBadge {
            safeKeeperButton.isHidden = false
        } else {
            safeKeeperButton.isHidden = true
        }
    }

    private func checkAndDisplayRideLastCreatedTime() {
        if matchedUserCellViewModel.matchedUser?.rideid == 0 {
            backGroundView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
            if matchedUserCellViewModel.matchedUser!.lastRideCreatedTime == nil {
                lastRideCreatedLabel.isHidden = true
            } else {
                lastRideCreatedLabel.isHidden = false
                lastRideCreatedLabel.text = matchedUserCellViewModel.getTextForLastRideCreated(lastRideCreatedTime: matchedUserCellViewModel.matchedUser!.lastRideCreatedTime!)
            }
        } else {
            backGroundView.backgroundColor = .white
            lastRideCreatedLabel.isHidden = true
        }
    }

    private func setDataForRiderOrPasenger(matchedUser: MatchedUser) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        let longDistance = clientConfiguration.longDistanceForUser
        setLongDistanceLabel(longDistance: longDistance)
        rideTakerPickUpDataView.isHidden = false
        rideGiverPickUpDataView.isHidden = true
        if matchedUser.userRole == MatchedUser.RIDER { //MARK: Ride giver
            if let time = matchedUser.pkTime {
                self.rideTimeShowingLabel.text = matchedUserCellViewModel.setRideTimeBasedOnLongDistance(matchedUser: matchedUser, longDistance: longDistance, time: time)
            }else {
                self.rideTimeShowingLabel.text = matchedUserCellViewModel.setRideTimeBasedOnLongDistance(matchedUser: matchedUser, longDistance: longDistance, time: matchedUser.pickupTime)
            }
            routeMatchOrPointsShowingLabel.text = Strings.route_match
            rideTypeImageView.isHidden = false
            if matchedUserCellViewModel.matchedUser?.newFare != -1 {
                let attributePoints = FareChangeUtils.getFareDetails(newFare:  matchedUser.newFare, actualFare: matchedUser.points ?? 0, rideType : Ride.PASSENGER_RIDE, textColor: pointsOrPercentageRideMatchShowingLabel.textColor)
                let ponits = NSAttributedString(string: " \(Strings.points_new)")
                let combination = NSMutableAttributedString()
                combination.append(attributePoints)
                combination.append(ponits)
                pointsOrPercentageRideMatchShowingLabel.attributedText = combination
            } else {
                let points = StringUtils.getStringFromDouble(decimalNumber: ceil(matchedUser.points ?? 0))
                pointsOrPercentageRideMatchShowingLabel.text = points + " \(Strings.points_new)"
            }
            numberOfSeatsForPassengerWidthConstrasaints.constant = 0
            requestNumberOfSeatView.isHidden = true
            ridetypeimageWidthConstraints.constant = 15
            dotSeparatorView.isHidden = false
            poolTypeView.isHidden = false
            if matchedUser.userRole == MatchedUser.RIDER && (matchedUser as! MatchedRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                rideTypeImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
                rideTypeImageView.tintColor = .lightGray
                carOrImageForWalkPathImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
                carOrImageForWalkPathImageView.tintColor = .lightGray
                passengerShowingStackViewWidth.constant = 0
                poolShowingLabel.isHidden = false
            } else {
                rideTypeImageView.image = UIImage(named: "car_solid")
                carOrImageForWalkPathImageView.image = UIImage(named: "car_solid")
                let matchedUserAsRider = matchedUser as! MatchedRider
                let capacity = matchedUserAsRider.capacity ?? 1
                passengerShowingStackViewWidth.constant = CGFloat(capacity*17)
                poolShowingLabel.isHidden = true
                setOccupiedSeats(availableSeats: (matchedUserAsRider.availableSeats ?? 1), capacity: capacity)
            }
            let startLocation = CLLocation(latitude:matchedUserCellViewModel.ride!.startLatitude,longitude: matchedUserCellViewModel.ride!.startLongitude)
            let pickUpLoaction = CLLocation(latitude: matchedUser.pickupLocationLatitude!,longitude: matchedUser.pickupLocationLongitude!)
            let startToPickupWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: startLocation, point2: pickUpLoaction, polyline: matchedUserCellViewModel.ride!.routePathPolyline)
            walkPathdistanceShowingLabel.text = matchedUserCellViewModel.getDistanceString(distance: startToPickupWalkDistance)

            let endLocation =  CLLocation(latitude: matchedUserCellViewModel.ride!.endLatitude!, longitude: matchedUserCellViewModel.ride!.endLongitude!)
            let dropToEndWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: CLLocation(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!), point2: endLocation , polyline: matchedUserCellViewModel.ride!.routePathPolyline)
            afterRideWalkingDistanceShowingLabel.text = matchedUserCellViewModel.getDistanceString(distance: dropToEndWalkDistance)
            if (startToPickupWalkDistance + dropToEndWalkDistance) < Double(clientConfiguration.maximumWalkDistanceForFullMatch ?? 0){
                handleVisibilityOfFullMatchAnimation(isRequiredToShow: true)
            }else {
                handleVisibilityOfFullMatchAnimation(isRequiredToShow: false)
                matchingPercentageORPriceShowingLabel.text = "\(matchedUser.matchPercentage ?? 0)" + Strings.percentage_symbol
            }

        } else { //MARK: Ride taker
            //MARK: For Time
            if let time = matchedUser.psgReachToPk {
                self.rideTimeShowingLabel.text =  matchedUserCellViewModel.setRideTimeBasedOnLongDistance(matchedUser: matchedUser, longDistance: longDistance, time: time)
            }else if let time = matchedUser.passengerReachTimeTopickup {
                self.rideTimeShowingLabel.text =  matchedUserCellViewModel.setRideTimeBasedOnLongDistance(matchedUser: matchedUser, longDistance: longDistance, time: time)
            } else {
                self.rideTimeShowingLabel.text =  matchedUserCellViewModel.setRideTimeBasedOnLongDistance(matchedUser: matchedUser, longDistance: longDistance, time: matchedUser.startDate)
            }
            let numberOfSeatRequired = (matchedUser as! MatchedPassenger).requiredSeats
            if numberOfSeatRequired > 1{
                numberOfSeatsForPassengerWidthConstrasaints.constant = 40
                requestNumberOfSeatView.isHidden = false
                numberOfSeatsLabel.text = "+ \(numberOfSeatRequired)"
            }else{
                numberOfSeatsForPassengerWidthConstrasaints.constant = 0
                requestNumberOfSeatView.isHidden = true
            }
            
            pointsOrPercentageRideMatchShowingLabel.text = String.init(format: Strings.percentage_ride_taker_match, "\(matchedUser.matchPercentage ?? 0)\(Strings.percentage_symbol)")
            ridetypeimageWidthConstraints.constant = 0
            routeMatchOrPointsShowingLabel.text = Strings.points_new
            rideTypeImageView.isHidden = true
            passengerShowingStackViewWidth.constant = 0
            dotSeparatorView.isHidden = true
            poolTypeView.isHidden = true
            if matchedUserCellViewModel.matchedUser?.newFare != -1{
                matchingPercentageORPriceShowingLabel.attributedText = FareChangeUtils.getFareDetails(newFare:  matchedUser.newFare,actualFare:  matchedUser.points!,rideType: Ride.RIDER_RIDE,textColor: matchingPercentageORPriceShowingLabel.textColor)
            }else{
                matchingPercentageORPriceShowingLabel.text = StringUtils.getStringFromDouble(decimalNumber: matchedUser.points)
            }
            if matchedUser.userRole == MatchedUser.RIDER && (matchedUser as! MatchedRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                carOrImageForWalkPathImageView.image = UIImage(named: "biking_solid")?.withRenderingMode(.alwaysTemplate)
                carOrImageForWalkPathImageView.tintColor = .lightGray
            } else {
                carOrImageForWalkPathImageView.image = UIImage(named: "car_solid")
            }
            let startLocation = CLLocation(latitude:matchedUserCellViewModel.matchedUser?.fromLocationLatitude ?? 0,longitude: matchedUserCellViewModel.matchedUser?.fromLocationLongitude ?? 0)
            let pickUpLoaction = CLLocation(latitude: matchedUser.pickupLocationLatitude!,longitude: matchedUser.pickupLocationLongitude!)
            let distance = GoogleMapUtils.getWalkPathForMatchedUser(point1: startLocation, point2: pickUpLoaction , polyline: matchedUserCellViewModel.matchedUser!.routePolyline ?? "")
            walkPathdistanceShowingLabel.text = matchedUserCellViewModel.getDistanceString(distance: distance)
            let dropLocation = CLLocation(latitude:matchedUserCellViewModel.matchedUser?.dropLocationLatitude ?? 0,longitude: matchedUserCellViewModel.matchedUser?.dropLocationLongitude ?? 0)
            let endLocation =
            CLLocation(latitude:matchedUserCellViewModel.matchedUser?.toLocationLatitude ?? 0,longitude: matchedUserCellViewModel.matchedUser?.toLocationLongitude ?? 0)
            let dropToEndLocationDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: dropLocation, point2: endLocation , polyline: matchedUserCellViewModel.matchedUser!.routePolyline ?? "")
            afterRideWalkingDistanceShowingLabel.text = matchedUserCellViewModel.getDistanceString(distance: dropToEndLocationDistance)
        }
    }

    private func setLongDistanceLabel(longDistance: Int) {
        if matchedUserCellViewModel.matchedUser?.distance ?? 0.0 >= Double(longDistance){
            if let pickUptime = matchedUserCellViewModel.matchedUser?.psgReachToPk {
                longDistanceLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickUptime, timeFormat: DateUtils.DATE_FORMAT_dd_MMM)
            }else {
                longDistanceLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUserCellViewModel.matchedUser?.passengerReachTimeTopickup, timeFormat: DateUtils.DATE_FORMAT_dd_MMM)
            }
        }else{
            longDistanceLabel.text = ""
        }
    }

    private func setDollarSymbolToNewUser(matchedUser : MatchedUser) {
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus != 0 && clientConfiguration.enableFirstRideBonusPointsOffer  && (matchedUser.androidAppVersionName! >= MatchedUser.SUPPORTED_ANDROID_APP_VERSION || matchedUser.iosAppVersionName! >= MatchedUser.SUPPORTED_IOS_APP_VERSION){
            if matchedUser.verificationStatus && matchedUser.totalNoOfRideShared == 0{
                firstTimeBounsView.isHidden = false
                firstTimeBounsViewHeightConstraints.constant = 40
                firstTimeBounsDetailsLabel.text = String(format: Strings.first_time_bouns, StringUtils.getStringFromDouble(decimalNumber: clientConfiguration.firstRideBonusPoints))
                firstTimeBounsView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(showGiftDetails(_:))))
            } else {
                firstTimeBounsView.isHidden = true
                firstTimeBounsViewHeightConstraints.constant = 0
            }
        } else {
            firstTimeBounsView.isHidden = true
            firstTimeBounsViewHeightConstraints.constant = 0
        }
    }

    @objc private func showGiftDetails(_ gesture: UITapGestureRecognizer){
        MessageDisplay.displayErrorAlertWithAction(title: Strings.dollar_sym_info, isDismissViewRequired: true, message1: matchedUserCellViewModel.getFirstTimeOfferDetails(), message2: nil, positiveActnTitle: Strings.ok_caps, negativeActionTitle: nil, linkButtonText: nil, viewController: viewController) { (result) in
        }
    }

    private func getSetInviteStatusView() {
        if inviteOrOfferRideBtn == nil || matchedUserCellViewModel.rideId == nil || matchedUserCellViewModel.rideId!.isZero == true || matchedUserCellViewModel.rideType == nil || matchedUserCellViewModel.rideType!.isEmpty == true{
            return
        }

        let invite = self.matchedUserCellViewModel.getOutGoingInviteForRide()
        if invite != nil && invite?.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_NEW {
            setInviteStatus(status: 1)
            startedLabelSet()
        } else if invite != nil && invite?.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_RECEIVED {
            setInviteStatus(status: 2)
            startedLabelSet()
        } else if invite != nil && invite?.invitationStatus == RideInvitation.RIDE_INVITATION_STATUS_READ {
            setInviteStatus(status: 3)
            startedLabelSet()
        } else if invite == nil && matchedUserCellViewModel.checkForRideStatusStartedAndSetStatus() {
            topViewHeightConstraint.constant = 30
            rideStatusLabel.text = Strings.rider_ride_started_matchingList
            rideStatusLabel.isHidden = false
            topSeparatorView.isHidden = true
            requestImageView.isHidden = true
            requestMessageLabel.isHidden = true
        } else {
            topViewHeightConstraint.constant = 0
            rideStatusLabel.isHidden = true
            requestImageView.isHidden = true
            requestMessageLabel.isHidden = true
            topSeparatorView.isHidden = true
        }
    }

    private func setInviteStatus(status: Int) {
        topViewHeightConstraint.constant = 30
        requestImageView.isHidden = false
        requestMessageLabel.isHidden = false
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
    }

    private func setRequestMessageLabelText(status: Int) {
        switch status {
        case 3:
            requestMessageLabel.textColor = UIColor(netHex: 0x19AC4A)
            if matchedUserCellViewModel.matchedUser?.userRole == MatchedUser.RIDER {
                requestMessageLabel.text = Strings.request_seen
            } else {
                requestMessageLabel.text = Strings.invite_seen
            }
        default:
            requestMessageLabel.textColor = UIColor(netHex: 0x9BA3B1)
            if matchedUserCellViewModel.matchedUser?.userRole == MatchedUser.RIDER {
                requestMessageLabel.text = Strings.request_sent
            } else {
                requestMessageLabel.text = Strings.invite_sent_machinglist
            }
        }
    }

    private func startedLabelSet() {
        if matchedUserCellViewModel.checkForRideStatusStartedAndSetStatus() {
            rideStatusLabel.text = Strings.rider_ride_started_matchingList
            rideStatusLabel.isHidden = false
            topSeparatorView.isHidden = false
        }else{
            rideStatusLabel.text = ""
            rideStatusLabel.isHidden = true
            topSeparatorView.isHidden = true
        }
    }

    private func handleCustomizationToInviteView(){
        inviteProgressImageView.animationImages
            = [UIImage(named: "match_option_invite_progress_1"),UIImage(named: "match_option_invite_progress_2")] as? [UIImage]
        inviteProgressImageView.isHidden = true
        inviteProgressImageView.animationDuration = 0.3
        inviteOrOfferRideBtn.tag = matchedUserCellViewModel.row!
    }

    private func setOccupiedSeats(availableSeats: Int, capacity: Int) {
        for (index, imageView) in numberOfSeatsImageArray.enumerated() {
            imageView.isHidden = !(index < capacity)
            imageView.image = index < capacity - availableSeats ? UIImage(named: "seat_occupied") : UIImage(named: "seats_not_occupied")
        }
    }

    @IBAction func showNotePopUpButtonPressed(_ sender: UIButton) {
        guard let rideNotes = matchedUserCellViewModel.matchedUser?.rideNotes, !rideNotes.isEmpty else {return}
        MessageDisplay.displayInfoDialogue(title: Strings.ride_notes, message: rideNotes, viewController: viewController)
    }

    @IBAction func fareChangeBtnPressed(_ sender: UIButton) {
        showFareChangeView()
    }

    @IBAction func inviteOrOfferRideBtnPressed(_ sender: UIButton) {
        if self.viewController != nil && self.viewController!.isKind(of: SendInviteBaseViewController.classForCoder()) {
            (self.viewController as! SendInviteBaseViewController).view.endEditing(true)
        }
//        if let userProfile = UserDataCache.getInstance()?.userProfile,let profileVerificationData = userProfile.profileVerificationData,!profileVerificationData.profileVerified{
//            if let displayStatus = UserDataCache.getInstance()?.getEntityDisplayStatus(key: UserDataCache.VERIFICATION_VIEW),!displayStatus,SharedPreferenceHelper.getCountForVerificationViewDisplay() < 3{
//                let profileVerificationVC = UIStoryboard(name: StoryBoardIdentifiers.main_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileVerificationViewController") as! ProfileVerificationViewController
//                profileVerificationVC.initializeViews(rideType: matchedUserCellViewModel.ride?.rideType) { [weak self] in
//                    if profileVerificationData.profileVerified{
//                        self?.delegate?.hideProfileVerificationView()
//                    }
//                }
//                ViewControllerUtils.addSubView(viewControllerToDisplay: profileVerificationVC)
//                profileVerificationVC.view.layoutIfNeeded()
//            }else{
//                inviteClicked(matchedUserCellViewModel.matchedUser!, position: sender.tag)
//            }
//        }else{
            inviteClicked(matchedUserCellViewModel.matchedUser!, position: sender.tag)
//        }
    }

    @IBAction func callBtnPressed(_ sender: UIButton) {
        if sender.backgroundColor == UIColor(netHex: 0xcad2de) {
            guard let call_disaable_msg = matchedUserCellViewModel.getErrorMessageForCall() else { return }
            UIApplication.shared.keyWindow?.makeToast( call_disaable_msg)
            return
        }
        matchedUserCellViewModel.callTheRespectiveMatchUser()
    }

    @IBAction func chatOptionPressed(_ sender: UIButton) {
        guard let userId = matchedUserCellViewModel.matchedUser?.userid else { return }
        let chatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatViewController.initializeDataBeforePresentingView(ride: matchedUserCellViewModel.ride, userId: userId, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: chatViewController, animated: false)
    }

    @IBAction func moreOptionPressed(_ sender: UIButton) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.remind, style: .default) { action -> Void in
            self.inviteClicked(self.matchedUserCellViewModel.matchedUser!, position: self.matchedUserCellViewModel.row!)
        }
        let secondAction: UIAlertAction = UIAlertAction(title: Strings.cancel_invite, style: .default) { action -> Void in
            let getTheInvitation = self.matchedUserCellViewModel.getOutGoingInviteForRide()
            if let invitation = getTheInvitation {
                self.matchedUserSelectionDelegate?.cancelSelectedUserPressed(invitation: invitation, status: 0)
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
}

//MARK: inviteButton Title show hide
extension MatchedUserTableViewCell {
    private func checkAndSetInvitedLabel() {
        if inviteOrOfferRideBtn == nil {return}
        handleCustomizationToInviteView()
        setTitleToInviteBtn()
        if inviteOrOfferRideBtn == nil || matchedUserCellViewModel.rideId == nil || matchedUserCellViewModel.rideId!.isZero == true || matchedUserCellViewModel.rideType == nil || matchedUserCellViewModel.rideType!.isEmpty == true{
            return
        }
        let invite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: matchedUserCellViewModel.rideId!, rideType: matchedUserCellViewModel.rideType!, matchedUserRideId: matchedUserCellViewModel.matchedUser!.rideid!, matchedUserTaxiRideId: nil)

        checkAndEnableMultiInvite(enable: true)
        if invite != nil && invite?.invitingUserId !=  UserDataCache.getCurrentUserId() {
            inviteOrOfferRideBtn.setTitle( Strings.ACCEPT_CAPS, for: .normal)
            inviteOrOfferRideBtn.isHidden = false
            inviteProgressImageView.isHidden =  true
            inviteOrOfferRideShowingView.isHidden = false
            hideCallBtn()
        }else if Ride.RIDER_RIDE == matchedUserCellViewModel.rideType{
            handleVisibilityOfInviteElementsBasedOnInvite(riderRideId: matchedUserCellViewModel.rideId!, passengerRideId: matchedUserCellViewModel.matchedUser!.rideid!)
        }else{
            handleVisibilityOfInviteElementsBasedOnInvite(riderRideId: matchedUserCellViewModel.matchedUser!.rideid!, passengerRideId: matchedUserCellViewModel.rideId!)
            handleEnablingOfMultiInvite()
        }
    }
    private func setTitleToInviteBtn() {
        if Ride.RIDER_RIDE == matchedUserCellViewModel.rideType{
            inviteOrOfferRideBtn.setTitle(Strings.OFFER_RIDE_CAPS, for: .normal)
        }else{
            inviteOrOfferRideBtn.setTitle(Strings.JOIN_CAPS, for: .normal)
        }
    }

    private func handleVisibilityOfInviteElementsBasedOnInvite(riderRideId : Double,passengerRideId : Double){

        if let _ = RideInviteCache.getInstance().getOutGoingInvitationPresentBetweenRide(riderRideId: riderRideId, passengerRideId: passengerRideId, rideType: matchedUserCellViewModel.rideType!,userId: matchedUserCellViewModel.matchedUser!.userid!){
            inviteOrOfferRideBtn.isHidden = true
            inviteProgressImageView.isHidden =  true
            inviteOrOfferRideShowingView.isHidden = true
            handleCallBtnVisibility()
        }else{
            inviteOrOfferRideBtn.isHidden = false
            inviteProgressImageView.isHidden =  true
            inviteOrOfferRideShowingView.isHidden = false
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
        if viewController != nil && viewController!.isKind(of: SendInviteBaseViewController.self) {
            if UserProfile.SUPPORT_CALL_ALWAYS == matchedUserCellViewModel.matchedUser!.callSupport && matchedUserCellViewModel.matchedUser!.enableChatAndCall {
                handleCallOptions()
            }else if matchedUserCellViewModel.matchedUser!.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED && matchedUserCellViewModel.matchedUser!.enableChatAndCall {
                let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: matchedUserCellViewModel.matchedUser?.userid))
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
    }

    private func handleCallOptions() {
        let sendInviteViewController = (self.viewController as! SendInviteBaseViewController)
        if matchedUserCellViewModel.matchedUser?.matchingSortingStatus == MatchedUser.ENABLE_CALL_OPTION_TO_INACTIVE_USER && sendInviteViewController.sendInviteViewModel.callOptionEnableSelectedRow == matchedUserCellViewModel.row && !sendInviteViewController.sendInviteViewModel.callOptionEnabledId.contains(matchedUserCellViewModel.matchedUser!.userid!){
            sendInviteViewController.sendInviteViewModel.callOptionEnableSelectedRow = -1
            sendInviteViewController.sendInviteViewModel.callOptionEnabledId.append(matchedUserCellViewModel.matchedUser!.userid!)

            riderIsOfflineView.isHidden = false
            rideMatchDetailsStackView.isHidden = true
            enableCallOption(status: true)
        }else if sendInviteViewController.sendInviteViewModel.callOptionEnabledId.contains(matchedUserCellViewModel.matchedUser!.userid!) {
            riderIsOfflineView.isHidden = false
            rideMatchDetailsStackView.isHidden = true
            enableCallOption(status: true)
        }else{
            riderIsOfflineView.isHidden = true
            rideMatchDetailsStackView.isHidden = false
            enableCallOption(status: true)
        }
    }

    private func enableCallOption(status: Bool) {
        if status {
            callOptionBtn.backgroundColor = UIColor(netHex: 0x2196F3)
        }else{
            callOptionBtn.backgroundColor = UIColor(netHex: 0xcad2de)
        }
    }

    @objc private func tapped(_ sender:UITapGestureRecognizer) {
        AppDelegate.getAppDelegate().log.debug("")
        matchedUserCellViewModel.selectedUser = !matchedUserCellViewModel.selectedUser
        var sendInviteViewController : SendInviteBaseViewController?
        if viewController != nil && viewController!.isKind(of: SendInviteBaseViewController.self) {
            sendInviteViewController = (self.viewController as! SendInviteBaseViewController)
        }
        if sendInviteViewController != nil && sendInviteViewController!.sendInviteViewModel.selectedMatches.values.contains(true){
            if (!matchedUserCellViewModel.selectedUser) {
                UIImageView.transition(with: profileImageView, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
                setContactImage()
                matchedUserSelectionDelegate?.userUnSelectedAtIndex(row: matchedUserCellViewModel.row!, matchedUser: matchedUserCellViewModel.matchedUser!)
            } else {
                userImageLongPress()
            }
        } else {
            moveToProfile()
            matchedUserCellViewModel.selectedUser = !matchedUserCellViewModel.selectedUser
        }
    }

    private func moveToProfile() {
        if matchedUserCellViewModel.matchedUser == nil{
            return
        }
        if viewController != nil && viewController!.isKind(of: SendInviteBaseViewController.classForCoder()) {
            let sendInviteViewController = (self.viewController as! SendInviteBaseViewController)
            sendInviteViewController.sendInviteViewModel.selectedUserIndex = matchedUserCellViewModel.row!
        }
        let profile:ProfileDisplayViewController = (UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController)
        let profileData = matchedUserCellViewModel.prepareDataForProfileView()
        profile.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: matchedUserCellViewModel.matchedUser!.userid!),isRiderProfile: profileData.userRole! , rideVehicle: profileData.vehicle,userSelectionDelegate: userSelectionDelegate,displayAction: true, isFromRideDetailView : false, rideNotes: matchedUserCellViewModel.matchedUser?.rideNotes, matchedRiderOnTimeCompliance: matchedUserCellViewModel.matchedUser!.userOnTimeComplianceRating, noOfSeats: (matchedUserCellViewModel.matchedUser as? MatchedPassenger)?.requiredSeats, isSafeKeeper: matchedUserCellViewModel.matchedUser!.hasSafeKeeperBadge)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: profile, animated: false)
    }
}

//MARK: Invite
extension MatchedUserTableViewCell {
    fileprivate func sendInviteAfterWalletValidation(_ position: Int, _ matchedUser: MatchedUser) {
        if position >= 0 {
            inviteOrOfferRideBtn.isHidden = true
            inviteProgressImageView.isHidden = false
            self.inviteProgressImageView.startAnimating()
            SendInviteViewModel.isAnimating = true
        }
        setDataToRow(row: position)
        let invitation = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: matchedUserCellViewModel.rideId!, rideType: matchedUserCellViewModel.rideType!, matchedUserRideId: matchedUser.rideid!, matchedUserTaxiRideId: nil)

        if invitation != nil && matchedUser.newFare == invitation!.newFare{
            matchedUser.pickupTime = invitation!.pickupTime
            matchedUser.dropTime = invitation!.dropTime
            matchedUser.pickupTimeRecalculationRequired = false
            joinMatchedUser(matchedUser: matchedUser, displayPointsConfirmation: true,invitation: invitation!)
        }else{
            inviteMatchedUser(matchedUser: matchedUser, invite: invitation)
        }
    }

    private func inviteClicked(_ matchedUser: MatchedUser,position : Int) {
        if let defaultPaymentMethod = UserDataCache.getInstance()?.getDefaultLinkedWallet() {
            if (defaultPaymentMethod.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE || defaultPaymentMethod.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI) && SendInviteViewModel.isAnimating {
                inviteOrOfferRideBtn.shake()
                UIApplication.shared.keyWindow?.makeToast( Strings.request_in_progress)
                return
            }
            sendInviteAfterWalletValidation(position, matchedUser)
        } else {
           sendInviteAfterWalletValidation(position, matchedUser)
        }
    }

    private func setDataToRow(row: Int) {
        if viewController != nil && viewController!.isKind(of: SendInviteBaseViewController.classForCoder()) {
            let sendInviteViewController = (self.viewController as! SendInviteBaseViewController)
            sendInviteViewController.sendInviteViewModel.callOptionEnableSelectedRow = row
        }
    }
}

//MARK: Multi invite selection
extension MatchedUserTableViewCell {
    private func handleEnablingOfMultiInvite() {
        if matchedUserCellViewModel.ride?.status == Ride.RIDE_STATUS_SCHEDULED || matchedUserCellViewModel.ride?.status == Ride.RIDE_STATUS_DELAYED{
            inviteOrOfferRideBtn.setTitle(Strings.switch_rider, for: .normal)
            checkAndEnableMultiInvite(enable: false)
        }else{
            checkAndEnableMultiInvite(enable: true)
        }
    }

    private func checkAndEnableMultiInvite(enable : Bool) {
        if enable{
            var longGesture = UILongPressGestureRecognizer()
            longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
            longGesture.minimumPressDuration = 0.2
            profileImageView.addGestureRecognizer(longGesture)
        }
    }

    @objc private func longPress(_ sender:UILongPressGestureRecognizer) {
        if sender.state == .began{
            matchedUserCellViewModel.selectedUser = !matchedUserCellViewModel.selectedUser
            userImageLongPress()
        }
    }

    private func userImageLongPress() {
        if Ride.PASSENGER_RIDE == matchedUserCellViewModel.rideType && (matchedUserCellViewModel.ride?.status == Ride.RIDE_STATUS_SCHEDULED || matchedUserCellViewModel.ride?.status == Ride.RIDE_STATUS_DELAYED){
            return
        }
        if (matchedUserCellViewModel.selectedUser){
            UIImageView.transition(with: profileImageView, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setContactImage()
            matchedUserSelectionDelegate?.userSelectedAtIndex(row: matchedUserCellViewModel.row!, matchedUser: matchedUserCellViewModel.matchedUser!)
        } else {
            UIImageView.transition(with: profileImageView, duration: 0.5, options: UIView.AnimationOptions.transitionFlipFromLeft, animations: nil, completion: nil)
            setContactImage()
            matchedUserSelectionDelegate?.userUnSelectedAtIndex(row: matchedUserCellViewModel.row!, matchedUser: matchedUserCellViewModel.matchedUser!)
        }
    }

    func setContactImage(){//MARK: its not private as its calling from sendInviteBaseVC also
        if matchedUserCellViewModel.selectedUser{
            profileImageView.image = UIImage(named: "rider_select")
        }else{
            guard let matchedUser = matchedUserCellViewModel.matchedUser else {return}
            ImageCache.getInstance().setImageToView(imageView: profileImageView, imageUrl: matchedUser.imageURI ?? "", gender: matchedUserCellViewModel.matchedUser?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        }
    }

    func multiInvitePressed(matchedUser: MatchedUser,invitation: RideInvitation?, status: Int) {
        if status == 1{
            joinMatchedUser(matchedUser: matchedUser, displayPointsConfirmation: true,invitation: invitation!)
        } else {
            inviteMatchedUser(matchedUser: matchedUser,invite : invitation)
        }
    }
}

//MARK: Farechange
extension MatchedUserTableViewCell {
    private func handleFareChangeView() {
        if FareChangeUtils.isFareChangeApplicable(matchedUser: matchedUserCellViewModel.matchedUser!) {
            if matchedUserCellViewModel.matchedUser!.userRole == MatchedUser.PASSENGER {
                pointsOrPercentageRideMatchShowingLabel.isUserInteractionEnabled = false
                fareChangeButton.isUserInteractionEnabled = true
            } else if matchedUserCellViewModel.matchedUser!.userRole == MatchedUser.RIDER {
                fareChangeButton.isUserInteractionEnabled = false
                pointsOrPercentageRideMatchShowingLabel.isUserInteractionEnabled = true
                pointsOrPercentageRideMatchShowingLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(fareChangeTapped(_:))))
            }else{
                pointsOrPercentageRideMatchShowingLabel.isUserInteractionEnabled = false
                fareChangeButton.isUserInteractionEnabled = false
                pointsOrPercentageRideMatchShowingLabel.textColor = UIColor(netHex: 0x26AA4F)
                matchingPercentageORPriceShowingLabel.textColor = UIColor(netHex: 0x26AA4F)
            }
        } else {
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
        if matchedUserCellViewModel.ride!.isKind(of:PassengerRide.classForCoder()){
            noOfSeats = (matchedUserCellViewModel.ride as! PassengerRide).noOfSeats
            rideFarePerKm = (matchedUserCellViewModel.matchedUser as! MatchedRider).fare ?? 0.0
        }else if matchedUserCellViewModel.matchedUser!.isKind(of: MatchedPassenger.classForCoder()){
            noOfSeats = (matchedUserCellViewModel.matchedUser as! MatchedPassenger).requiredSeats
            rideFarePerKm = (matchedUserCellViewModel.ride as! RiderRide).farePerKm
        }
        let fareChangeViewController = UIStoryboard(name: "LiveRide", bundle: nil).instantiateViewController(withIdentifier: "FareChangeViewController") as! FareChangeViewController
        fareChangeViewController.initializeDataBeforePresenting(rideType: matchedUserCellViewModel.rideType!,actualFare: matchedUserCellViewModel.matchedUser!.points!,distance: matchedUserCellViewModel.matchedUser!.distance!,selectedSeats: noOfSeats, farePerKm: rideFarePerKm) { (actualFare, requestedFare) in
            self.matchedUserCellViewModel.matchedUser?.newFare = requestedFare
            self.matchedUserCellViewModel.matchedUser?.fareChange = true
            self.updateNewFare(selectedUser: self.matchedUserCellViewModel.matchedUser!)
        }
        ViewControllerUtils.presentViewController(currentViewController: nil, viewControllerToBeDisplayed: fareChangeViewController, animated: false, completion: nil)
    }

    private func updateNewFare(selectedUser : MatchedUser) {
        if matchedUserCellViewModel.matchedUser!.rideid == selectedUser.rideid && matchedUserCellViewModel.matchedUser!.userRole == selectedUser.userRole{
            matchedUserCellViewModel.matchedUser!.newFare = selectedUser.newFare
            inviteClicked(selectedUser,position: -1)
            (self.viewController as! SendInviteBaseViewController).iboTableView.reloadData()
            (self.viewController as! SendInviteBaseViewController).iboTableView.setContentOffset(CGPoint(x: 0, y: (self.viewController as! SendInviteBaseViewController).sendInviteViewModel.contentOffset), animated: true)
            return
        }
    }
}

//MARK: Invite
extension MatchedUserTableViewCell {
    private func inviteMatchedUser(matchedUser : MatchedUser, invite : RideInvitation?) {
        if matchedUser.userRole == MatchedUser.RIDER {
            if (invite != nil && invite!.fareChange) {
                if (matchedUser.newFare < invite!.newFare){
                    invitingRider(matchedUser: matchedUser)
                } else {
                    joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!)
                }
            } else if (matchedUser.newFare != -1) && (matchedUser.newFare < matchedUser.points!) {
                invitingRider(matchedUser: matchedUser)
            } else if invite == nil {
                invitingRider(matchedUser: matchedUser)
            } else {
                joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!)
            }
        } else if matchedUser.userRole == MatchedUser.PASSENGER {
            if (invite != nil && invite!.fareChange) {
                if (matchedUser.newFare > invite!.newFare){
                    invitingPassenger(matchedUser: matchedUser)
                } else {
                    joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!)
                }
            } else if (matchedUser.newFare != -1) && (matchedUser.newFare > matchedUser.points!) {
                invitingPassenger(matchedUser: matchedUser)
            } else if invite == nil {
                invitingPassenger(matchedUser: matchedUser)
            } else {
                joinMatchedUser(matchedUser: matchedUser,displayPointsConfirmation : false,invitation: invite!)
            }
        }
    }

    private func joinMatchedUser(matchedUser : MatchedUser,displayPointsConfirmation : Bool,invitation : RideInvitation){
        let clientConfiguration = ConfigurationCache.getObjectClientConfiguration()
        if matchedUser.verificationStatus == false && SharedPreferenceHelper.getJoinWithUnverifiedUsersStatus() == false && SharedPreferenceHelper.getCurrentUserGender() == User.USER_GENDER_FEMALE && Int(matchedUser.noOfRidesShared) <= clientConfiguration.minNoOfRidesReqNotToShowJoiningUnverifiedDialog{
            let alertControllerWithCheckBox = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "AlertControllerWithCheckBox") as! AlertControllerWithCheckBox
            alertControllerWithCheckBox.initializeDataBeforePresenting(alertTitle: Strings.dont_show_again_title, checkBoxText: Strings.dont_show_again_checkBox_text, handler: { (result,dontShow) in
                SharedPreferenceHelper.setJoinWithUnverifiedUsersStatus(status: dontShow)
                if Strings.yes_caps == result{
                    self.continueJoin(invitation: invitation, displayPointsConfirmation: displayPointsConfirmation,matchedUser : matchedUser)
                } else {
                    self.stopAnimatingInviteProgressView()
                }
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: alertControllerWithCheckBox)
        }else{
            self.continueJoin(invitation: invitation, displayPointsConfirmation: displayPointsConfirmation,matchedUser : matchedUser)
        }
    }

    private func invitingRider(matchedUser : MatchedUser) {
        var selectedRiders = [MatchedRider]()
        selectedRiders.append(matchedUser as! MatchedRider)
        InviteRiderHandler(passengerRide: matchedUserCellViewModel.ride as! PassengerRide, selectedRiders: selectedRiders, displaySpinner: false, selectedIndex: "\((matchedUserCellViewModel.row ?? 0)+1)", viewController: viewController!).inviteSelectedRiders(inviteHandler: { (error,nserror) in
            if error == nil && nserror == nil{
                if self.viewController != nil{
                    if self.viewController!.isKind(of: SendInviteBaseViewController.self){
                        (self.viewController as! SendInviteBaseViewController).displayAckForRideRequest(matchedUser: matchedUser)
                    }
                }
            }
            self.stopAnimatingInviteProgressView()
        })
    }

    private func invitingPassenger(matchedUser : MatchedUser) {
        var selectedPassengers = [MatchedPassenger]()
        selectedPassengers.append(matchedUser as! MatchedPassenger)
        InviteSelectedPassengersAsyncTask(riderRide: matchedUserCellViewModel.ride as! RiderRide, selectedUsers: selectedPassengers, viewController: viewController!, displaySpinner: false, selectedIndex: "\((matchedUserCellViewModel.row ?? 0)+1)", invitePassengersCompletionHandler: { (error,nserror) in
            if error == nil && nserror == nil{
                if self.viewController != nil{
                    if self.viewController!.isKind(of: SendInviteBaseViewController.self){
                        (self.viewController as! SendInviteBaseViewController).displayAckForRideRequest(matchedUser: matchedUser)
                    }
                }
            }
            self.stopAnimatingInviteProgressView()
        }).invitePassengersFromMatches()
    }

    private func continueJoin(invitation : RideInvitation,displayPointsConfirmation: Bool,matchedUser : MatchedUser){
        if matchedUser.userRole == MatchedUser.RIDER{
            let passengerRide = matchedUserCellViewModel.ride! as! PassengerRide
            JoinPassengerToRideHandler(viewController: viewController, riderRideId: matchedUser.rideid!, riderId: matchedUser.userid!, passengerRideId: passengerRide.rideId, passengerId: passengerRide.userId,rideType: matchedUser.userRole, pickupAddress: matchedUser.pickupLocationAddress, pickupLatitude: matchedUser.pickupLocationLatitude!, pickupLongitude: matchedUser.pickupLocationLongitude!, pickupTime: matchedUser.pickupTime, dropAddress: matchedUser.dropLocationAddress, dropLatitude: matchedUser.dropLocationLatitude!, dropLongitude: matchedUser.dropLocationLongitude!, dropTime: matchedUser.dropTime, matchingDistance: matchedUser.distance!, points: matchedUser.points!,newFare: matchedUser.newFare, noOfSeats: passengerRide.noOfSeats, rideInvitationId: invitation.rideInvitationId,invitingUserName : invitation.invitingUserName!,invitingUserId : invitation.invitingUserId,displayPointsConfirmationAlert: displayPointsConfirmation, riderHasHelmet: (matchedUser as! MatchedRider).riderHasHelmet, pickupTimeRecalculationRequired: matchedUser.pickupTimeRecalculationRequired, passengerRouteMatchPercentage: matchedUser.matchPercentage!, riderRouteMatchPercentage: matchedUser.matchPercentageOnMatchingUserRoute, moderatorId: nil,listener: self).joinPassengerToRide(invitation: invitation)
        } else if matchedUser.userRole == MatchedUser.PASSENGER {
            let riderRide = matchedUserCellViewModel.ride! as! RiderRide
            JoinPassengerToRideHandler(viewController: viewController!, riderRideId: riderRide.rideId, riderId: riderRide.userId, passengerRideId: matchedUser.rideid!, passengerId: matchedUser.userid!,rideType: matchedUser.userRole, pickupAddress: matchedUser.pickupLocationAddress, pickupLatitude: matchedUser.pickupLocationLatitude!, pickupLongitude: matchedUser.pickupLocationLongitude!, pickupTime: matchedUser.pickupTime, dropAddress: matchedUser.dropLocationAddress, dropLatitude: matchedUser.dropLocationLatitude!, dropLongitude: matchedUser.dropLocationLongitude!, dropTime: matchedUser.dropTime, matchingDistance: matchedUser.distance!, points: matchedUser.points!,newFare: matchedUser.newFare, noOfSeats: (matchedUser as! MatchedPassenger).requiredSeats, rideInvitationId: invitation.rideInvitationId,invitingUserName : invitation.invitingUserName!,invitingUserId : invitation.invitingUserId, displayPointsConfirmationAlert: displayPointsConfirmation, riderHasHelmet: false, pickupTimeRecalculationRequired: matchedUser.pickupTimeRecalculationRequired, passengerRouteMatchPercentage: matchedUser.matchPercentageOnMatchingUserRoute, riderRouteMatchPercentage: matchedUser.matchPercentage!, moderatorId: nil, listener: self).joinPassengerToRide(invitation: invitation)
        }
    }

    private func stopAnimatingInviteProgressView() {
        self.inviteProgressImageView.stopAnimating()
        self.inviteProgressImageView.isHidden = true
        SendInviteViewModel.isAnimating = false
        if self.viewController != nil{
            if self.viewController != nil && self.viewController!.isKind(of: SendInviteBaseViewController.classForCoder()) {
                let sendInviteViewController = (self.viewController as! SendInviteBaseViewController)
                sendInviteViewController.iboTableView.reloadData()
                sendInviteViewController.iboTableView.setContentOffset(CGPoint(x: 0, y: sendInviteViewController.sendInviteViewModel.contentOffset), animated: true)
            }
        }
    }
}

//MARK: RideInvite listener
extension MatchedUserTableViewCell : RideInvitationActionCompletionListener{
    func rideInviteAcceptCompleted(rideInvitationId: Double) {
        stopAnimatingInviteProgressView()
        rideInviteActionCompletionListener?.rideInviteAcceptCompleted(rideInvitationId: rideInvitationId)
    }

    func rideInviteRejectCompleted(rideInvitation: RideInvitation) {
        stopAnimatingInviteProgressView()
        rideInviteActionCompletionListener?.rideInviteRejectCompleted(rideInvitation: rideInvitation)
        rideInvitation.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_REJECTED
        let rideInvitationStatus = RideInviteStatus(rideInvitation: rideInvitation)
        NotificationStore.getInstance().removeInviteNotificationByInvitation(invitationId: rideInvitationStatus.invitationId)
        RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
    }

    func rideInviteActionFailed(rideInvitationId: Double,responseError: ResponseError?, error: NSError?, isNotificationRemovable: Bool) {
        stopAnimatingInviteProgressView()
        rideInviteActionCompletionListener?.rideInviteActionFailed(rideInvitationId: rideInvitationId, responseError: responseError, error: error, isNotificationRemovable: isNotificationRemovable)
    }

    func rideInviteActionCancelled () {
        stopAnimatingInviteProgressView()
    }
}

//extension MatchedUserTableViewCell : RideInvitationUpdateListener {
//    func rideInvitationStatusUpdated() {
//        updateStatusDelegate?.updateRideStatusView()
//    }
//}
