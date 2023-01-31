//
//  RideDetailCollectionViewCell.swift
//  Quickride
//
//  Created by Vinutha on 02/03/20.
//  Copyright © 2020 iDisha. All rights reserved.
//

import UIKit
import CoreLocation

protocol RideDetailCollectionViewCellUserActionDelegate : class {
    func acceptAction()
    func rejectAction()
    func gotItAction()
    func changePlanAction()
}

class RideDetailCollectionViewCell: UICollectionViewCell {

    //MARK: OUTLETS
    //MARK: cardView
    @IBOutlet weak var backGroundView: QuickRideCardView!
    //MARK: Profile
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var safeKeeperButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileVerificationImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var ratingShowingLabel: UILabel!
    @IBOutlet weak var ratingShowingLabelHeightConstraints: NSLayoutConstraint!
    
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
    @IBOutlet weak var rideTypeImageView: UIImageView!
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
    //MARK: Contact Options
    @IBOutlet weak var contactOptionShowingView: UIView!
    @IBOutlet weak var callOptionBtn: UIButton!
    @IBOutlet weak var chatOptionBtn: UIButton!
    //MARK: ActionButton
    @IBOutlet weak var riderIsOfflineView: UIView!
    @IBOutlet weak var rideAcceptActionView: UIView!
    @IBOutlet weak var rideConfirmActionView: UIView!
    @IBOutlet weak var acceptActionButton: UIButton!
    @IBOutlet weak var RejectActionButton: UIButton!
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var changePlanButton: UIButton!
    @IBOutlet weak var rideMatchDetailsStackView: UIStackView!
    @IBOutlet weak var poolShowingLabel: UILabel!
    @IBOutlet weak var poolTypeView: UIView!
    
    
    //MARK: Variables
    private var numberOfSeatsImageArray = [UIImageView]()
    weak var viewController : UIViewController?
    private var rideDetailViewCellViewModel = RideDetailViewCellViewModel()
    private var userActionDelegate: RideDetailCollectionViewCellUserActionDelegate?
    private var userSelectionDelegate : UserSelectedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberOfSeatsImageArray = [firstSeatImageView,secondSeatImageView,thirdSeatImageView,fouthSeatImageView,fifthSeatImageView,sixthSeatImageView]
    }
    
    func initialiseUIWithData(ride: Ride?, matchedUser: MatchedUser, viewController : UIViewController, viewType: DetailViewType, userActionDelegate: RideDetailCollectionViewCellUserActionDelegate?, userSelectionDelegate : UserSelectedDelegate?) {
        rideDetailViewCellViewModel.initialiseUIWithData(ride: ride, matchedUser: matchedUser, viewType: viewType)
        self.viewController = viewController
        self.userActionDelegate = userActionDelegate
        self.userSelectionDelegate = userSelectionDelegate
        setUpUI()
    }
    
    private func setUpUI() {
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
        backGroundView.isUserInteractionEnabled = true
        ImageCache.getInstance().setImageToView(imageView: profileImageView, imageUrl: rideDetailViewCellViewModel.matchedUser?.imageURI ?? "", gender: rideDetailViewCellViewModel.matchedUser?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        nameLabel.text = rideDetailViewCellViewModel.matchedUser?.name?.capitalized
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
             UserDataCache.getInstance()?.getOtherUserCompleteProfile(userId: userId, targetViewController: viewController!, completeProfileRetrievalCompletionHandler: { (otherUserInfo, error, responseObject) -> Void in
                if otherUserInfo != nil {
                    self.rideDetailViewCellViewModel.matchedUser?.profileVerificationData = otherUserInfo?.userProfile?.profileVerificationData
                    self.rideDetailViewCellViewModel.matchedUser?.companyName = otherUserInfo?.userProfile?.companyName
                    self.rideDetailViewCellViewModel.matchedUser?.rating = otherUserInfo?.userProfile?.rating
                    self.rideDetailViewCellViewModel.matchedUser?.noOfReviews = otherUserInfo?.userProfile?.noOfReviews ?? 0
                    self.setUserOfficialAndVerificationData()
                }
            })
        }
        setDataForRiderOrPasenger(matchedUser: rideDetailViewCellViewModel.matchedUser!)
        if rideDetailViewCellViewModel.viewType == DetailViewType.RideInviteView {
            rideAcceptActionView.isHidden = false
            rideConfirmActionView.isHidden = true
        } else if rideDetailViewCellViewModel.viewType == DetailViewType.RideConfirmView {
            rideAcceptActionView.isHidden = true
            rideConfirmActionView.isHidden = false
        } else {
            rideAcceptActionView.isHidden = true
            rideConfirmActionView.isHidden = true
        }
        handleRideMatchDetailView()
        var clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration()
        if clientConfiguration == nil {
            clientConfiguration = ClientConfigurtion()
        }
        if clientConfiguration?.showCovid19SelfAssessment ?? false && rideDetailViewCellViewModel.matchedUser!.hasSafeKeeperBadge {
            safeKeeperButton.isHidden = false
        } else {
            safeKeeperButton.isHidden = true
        }
    }
    
    private func setUserOfficialAndVerificationData() {
        profileVerificationImageView.isHidden = false
        ratingShowingLabel.isHidden = false
        profileVerificationImageView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: self.rideDetailViewCellViewModel.matchedUser?.profileVerificationData)
        companyNameLabel.text = rideDetailViewCellViewModel.getCompanyName()
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
            ratingShowingLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
            starImageView.isHidden = true
            ratingShowingLabel.textColor = .white
            ratingShowingLabel.text = Strings.new_user_matching_list
            ratingShowingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            ratingShowingLabel.layer.cornerRadius = 2.0
            ratingShowingLabel.layer.masksToBounds = true
        }
    }
    
    private func setDataForRiderOrPasenger(matchedUser: MatchedUser) {
        if matchedUser.userRole == MatchedUser.RIDER { //MARK: Ride giver
            //MARK: For Time
            if let time = matchedUser.passengerReachTimeTopickup {
                self.rideTimeShowingLabel.text =  DateUtils.getTimeStringFromTimeInMillis(timeStamp: time, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            } else if let pickupTime = matchedUser.pickupTime {
                self.rideTimeShowingLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            } else {
                self.rideTimeShowingLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.startDate, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            }
            rideTakerPickUpDataView.isHidden = false
            rideGiverPickUpDataView.isHidden = true
            if let matchPercentage = matchedUser.matchPercentage {
                matchingPercentageORPriceShowingLabel.isHidden = false
                routeMatchOrPointsShowingLabel.isHidden = false
                matchingPercentageORPriceShowingLabel.text = "\(matchPercentage)" + Strings.percentage_symbol
                routeMatchOrPointsShowingLabel.text = Strings.route_match
            } else {
                matchingPercentageORPriceShowingLabel.isHidden = true
                routeMatchOrPointsShowingLabel.isHidden = true
            }
            rideTypeImageView.isHidden = false
            requestNumberOfSeatView.isHidden = true
            if rideDetailViewCellViewModel.matchedUser?.newFare != -1 {
                let attributePoints = FareChangeUtils.getFareDetails(newFare: StringUtils.getStringFromDouble(decimalNumber: matchedUser.newFare),actualFare: StringUtils.getStringFromDouble(decimalNumber: matchedUser.points!),textColor: pointsOrPercentageRideMatchShowingLabel.textColor)
                let ponits = NSAttributedString(string: " \(Strings.points_new)")
                let combination = NSMutableAttributedString()
                combination.append(attributePoints)
                combination.append(ponits)
                pointsOrPercentageRideMatchShowingLabel.attributedText = combination
            } else {
                pointsOrPercentageRideMatchShowingLabel.text = StringUtils.getStringFromDouble(decimalNumber: matchedUser.points) + " \(Strings.points_new)"
            }
            ridetypeimageWidthConstraints.constant = 15
            dotSeparatorView.isHidden = false
            poolTypeView.isHidden = false
            if matchedUser.userRole == MatchedUser.RIDER && (matchedUser as! MatchedRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                rideTypeImageView.image = UIImage(named: "biking_solid")
                carOrImageForWalkPathImageView.image = UIImage(named: "biking_solid")
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
            let startLocation = CLLocation(latitude:rideDetailViewCellViewModel.ride!.startLatitude,longitude: rideDetailViewCellViewModel.ride!.startLongitude)
            let pickUpLoaction = CLLocation(latitude: matchedUser.pickupLocationLatitude!,longitude: matchedUser.pickupLocationLongitude!)
            let startToPickupWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: startLocation, point2: pickUpLoaction, polyline: matchedUser.routePolyline!)
            walkPathdistanceShowingLabel.text = rideDetailViewCellViewModel.getDistanceString(distance: startToPickupWalkDistance)
            
            let endLocation =  CLLocation(latitude: rideDetailViewCellViewModel.ride!.endLatitude!, longitude: rideDetailViewCellViewModel.ride!.endLongitude!)
            let dropToEndWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: CLLocation(latitude: matchedUser.dropLocationLatitude!, longitude: matchedUser.dropLocationLongitude!), point2: endLocation , polyline: matchedUser.routePolyline!)
            afterRideWalkingDistanceShowingLabel.text = rideDetailViewCellViewModel.getDistanceString(distance: dropToEndWalkDistance)
            
        } else { //MARK: Ride taker
            self.rideTimeShowingLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: matchedUser.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
            
            pointsOrPercentageRideMatchShowingLabel.text = String.init(format: Strings.percentage_ride_taker_match, "\(matchedUser.matchPercentage ?? 0)\(Strings.percentage_symbol)")
            ridetypeimageWidthConstraints.constant = 0
            routeMatchOrPointsShowingLabel.text = Strings.points_new
            rideTypeImageView.isHidden = true
            passengerShowingStackViewWidth.constant = 0
            dotSeparatorView.isHidden = true
            poolTypeView.isHidden = true
            if rideDetailViewCellViewModel.matchedUser?.newFare != -1{
                matchingPercentageORPriceShowingLabel.attributedText = FareChangeUtils.getFareDetails(newFare: StringUtils.getStringFromDouble(decimalNumber: matchedUser.newFare),actualFare: StringUtils.getStringFromDouble(decimalNumber: matchedUser.points!),textColor: matchingPercentageORPriceShowingLabel.textColor)
            }else{
                matchingPercentageORPriceShowingLabel.text = StringUtils.getStringFromDouble(decimalNumber: matchedUser.points)
            }
            let numberOfSeatRequired = (rideDetailViewCellViewModel.matchedUser as! MatchedPassenger).requiredSeats
            if numberOfSeatRequired > 1 {
                numberOfSeatsForPassengerWidthConstrasaints.constant = 40
                requestNumberOfSeatView.isHidden = false
                numberOfSeatsLabel.text = "+ \(numberOfSeatRequired)"
            }else{
                numberOfSeatsForPassengerWidthConstrasaints.constant = 0
                requestNumberOfSeatView.isHidden = true
            }
            if matchedUser.userRole == MatchedUser.RIDER && (matchedUser as! MatchedRider).vehicleType == Vehicle.VEHICLE_TYPE_BIKE{
                carOrBikeImageView.image = UIImage(named: "biking_solid")
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
    
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        userActionDelegate?.acceptAction()
    }
    
    @IBAction func rejectButtontapped(_ sender: UIButton) {
        userActionDelegate?.rejectAction()
    }
    
    @IBAction func gotItButtonTapped(_ sender: UIButton) {
        userActionDelegate?.gotItAction()
    }
    
    @IBAction func changePlanButtonTapped(_ sender: UIButton) {
        userActionDelegate?.changePlanAction()
    }
    
    @IBAction func callBtnPressed(_ sender: UIButton) {
        if sender.backgroundColor == UIColor(netHex: 0x9BA3B1) {
            UIApplication.shared.keyWindow?.makeToast(message: Strings.call_disable_msg)
            return
        }
        guard let contactNo = rideDetailViewCellViewModel.matchedUser?.contactNo,let ride = rideDetailViewCellViewModel.ride, let rideType = rideDetailViewCellViewModel.ride?.rideType else { return }
        let refID = rideType+StringUtils.getStringFromDouble(decimalNumber: ride.rideId)
        AppUtilConnect.callNumber(phoneNumber: contactNo,receiverId: StringUtils.getStringFromDouble(decimalNumber: rideDetailViewCellViewModel.matchedUser!.userid), refId: refID, name: rideDetailViewCellViewModel.matchedUser?.name ?? "", targetViewController: ViewControllerUtils.getCenterViewController())
    }
    
    @IBAction func chatOptionPressed(_ sender: UIButton) {
        guard let userId = rideDetailViewCellViewModel.matchedUser?.userid, let name = rideDetailViewCellViewModel.matchedUser?.name, let callSupport = rideDetailViewCellViewModel.matchedUser?.callSupport, let contactNoStr = rideDetailViewCellViewModel.matchedUser?.contactNo, let contactNo =  Double(contactNoStr) else { return }
        let userBasicInfo = UserBasicInfo(userId : userId, gender : rideDetailViewCellViewModel.matchedUser?.gender,userName : name, imageUri: rideDetailViewCellViewModel.matchedUser?.imageURI, callSupport : callSupport,contactNo: contactNo)
        moveToChatView(userBasicInfo: userBasicInfo)
    }
    
    private func moveToChatView(userBasicInfo: UserBasicInfo) {
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.initializeDataBeforePresentingView(presentConatctUserBasicInfo : userBasicInfo, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: viewController, animated: false)
    }
    
    @objc private func tapped(_ sender:UITapGestureRecognizer) {
        if rideDetailViewCellViewModel.matchedUser == nil{
            return
        }
        let profile:ProfileDisplayViewController = (UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController)
        let profileData = rideDetailViewCellViewModel.prepareDataForProfileView()
        profile.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: rideDetailViewCellViewModel.matchedUser!.userid!),isRiderProfile: profileData.userRole! , rideVehicle: profileData.vehicle,userSelectionDelegate: userSelectionDelegate,displayAction: true, isFromRideDetailView : false, rideNotes: rideDetailViewCellViewModel.matchedUser?.rideNotes, matchedRiderOnTimeCompliance: rideDetailViewCellViewModel.matchedUser!.userOnTimeComplianceRating, noOfSeats: (rideDetailViewCellViewModel.matchedUser as? MatchedPassenger)?.requiredSeats, isSafeKeeper: rideDetailViewCellViewModel.matchedUser!.hasSafeKeeperBadge)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: profile, animated: false)
    }
}
