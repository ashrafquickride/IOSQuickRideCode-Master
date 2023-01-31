//
//  UpcomingRideCollectionViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 12/03/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import Lottie

class UpcomingRideCollectionViewCell: UICollectionViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var rideTimingLabel: UILabel!
    @IBOutlet weak var fromToAddressView: UIView!
    @IBOutlet weak var fromAddressLabel: UILabel!
    @IBOutlet weak var toAddressLabel: UILabel!
    @IBOutlet weak var rideNotificationView: UIView!
    @IBOutlet weak var rideNotificationCountLabel: UILabel!
    @IBOutlet weak var rideNotificationImageView: UIImageView!
    @IBOutlet weak var rideRequestInfoLabel: UILabel!
    @IBOutlet weak var noMatchLabel: UILabel!
    @IBOutlet weak var shareRideButton: UIButton!
    @IBOutlet weak var noMatchView: UIView!
    @IBOutlet weak var matchRiderView: UIView!
    @IBOutlet weak var matchedUserDescriptionLabel: UILabel!
    @IBOutlet weak var matchRiderCountLabel: UILabel!
    @IBOutlet weak var overflowButton: UIButton! //accessing from controller to set tag
    @IBOutlet weak var rideFreezeImageView: UIImageView!
    @IBOutlet weak var rideFreezeImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var matchedRideViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var findMatchingView: UIView!
    @IBOutlet weak var matchAnimatedControlView: AnimatedControl!
    @IBOutlet weak var findMatchingTitleLabel: UILabel!
    @IBOutlet weak var findingMatchImageView: UIImageView!
    //homeOfficeAddressView - UI for home & Office address
    @IBOutlet weak var homeOfficeAddressView: UIView!
    @IBOutlet weak var homeAddressLabel: UILabel!
    @IBOutlet weak var officeAddressLabel: UILabel!
    @IBOutlet weak var matchParticipantButton: UIButton!
    @IBOutlet weak var cellButton: UIButton!
    @IBOutlet weak var rideStatusLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var rideStatusLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var rideStatusLabel: UILabel!
    @IBOutlet weak var dayTitleForNextRideLabel: UILabel!
    @IBOutlet weak var dayTitleLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dayTitleLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstMatchedUserImageView: CircularImageView!
    @IBOutlet weak var seconMatchedUserImageView: CircularImageView!
    @IBOutlet weak var thirdMatchedUserImageView: CircularImageView!
    //MARK: TaxiPool data Outlets
    @IBOutlet weak var taxiPoolDataShowingView: UIView!
    @IBOutlet weak var taxipoolInfoShowingLabel: UILabel!
    @IBOutlet weak var taxiPoolPassengerInfoShowingStackView: UIStackView!
    @IBOutlet weak var firstSeatImageTaxiPool: UIImageView!
    @IBOutlet weak var secondSeatImageTaxiPool: UIImageView!
    @IBOutlet weak var thirdSeatImageTaxiPool: UIImageView!
    @IBOutlet weak var fourthSeatImageTaxiPool: UIImageView!
    @IBOutlet weak var taxiDetailsShowingView: UIView!
    @IBOutlet weak var taxiNumberShowingLabel: UILabel!
    //MARK: OutStation
    @IBOutlet weak var outStationDataShowingView: UIView!
    @IBOutlet weak var outStationDetailsLabel: UILabel!
    @IBOutlet weak var taxiIconImageView: UIImageView!
    
    //MARK: Properties
    var ride: Ride?
    weak var delegate: MyRidesDetailTableViewCellDelegate?
    lazy var myRideDetailTableViewCellModel: MyRideDetailTableViewCellModel = {
        return MyRideDetailTableViewCellModel()
    }()
    var cellIndexPath: IndexPath?
    var allMatchedUserImageViewList: [UIImageView] = []
    var isMatchParticipantButtonHidden = false
    var taxiShareRide: TaxiShareRide?
    var numberOfSeatsImageArray = [UIImageView]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        firstMatchedUserImageView.image = nil
        seconMatchedUserImageView.image = nil
        thirdMatchedUserImageView.image = nil
        matchRiderCountLabel.text = ""
        findingMatchImageView.isHidden = false
        matchedUserDescriptionLabel.text = ""
        rideRequestInfoLabel.text = ""
        rideNotificationView.isHidden = true
        rideNotificationView.backgroundColor = .white
        rideNotificationCountLabel.textColor = .white
        rideNotificationImageView.isHidden = true
        rideStatusLabel.backgroundColor = .clear
        firstMatchedUserImageView.layer.borderColor = UIColor.clear.cgColor
        seconMatchedUserImageView.layer.borderColor = UIColor.clear.cgColor
        thirdMatchedUserImageView.layer.borderColor = UIColor.clear.cgColor
        taxiPoolDataShowingView.isHidden = true
        taxiDetailsShowingView.isHidden = true
        taxiNumberShowingLabel.text = ""
        taxipoolInfoShowingLabel.text = ""
        taxiShareRide = nil
        outStationDataShowingView.isHidden = true
    }
    //MARK: Methods
    func setupUI() {
        allMatchedUserImageViewList = [firstMatchedUserImageView, seconMatchedUserImageView, thirdMatchedUserImageView]
        findingMatchImageView.tintColor = .green
        ViewCustomizationUtils.addCornerRadiusToView(view: rideNotificationView, cornerRadius: rideNotificationView.frame.width / 2)
        myRideDetailTableViewCellModel.delegate = self
        overflowButton.setImage(UIImage(named: "ic_more_vert")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        overflowButton.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    func configureView(ride: Ride) {
        self.ride = ride
        setRideStartDateForCardView(ride: ride)
        checkStatusInfo(for: ride)
        getIncomingPendingRideInivitation(ride: ride)
        getOutgoingPendingRideInvitations(ride: ride)
        if let riderRide = (ride as? RiderRide), riderRide.freezeRide {
            rideFreezeImageView.isHidden = false
            rideFreezeImageViewWidthConstraint.constant = 15
        } else {
            rideFreezeImageView.isHidden = true
            rideFreezeImageViewWidthConstraint.constant = 0
        }
        rideTimingLabel.text = RideViewUtils.getRideStartTime(ride: ride, format: DateUtils.TIME_FORMAT_hmm_a)
        configureAddressInfo(ride: ride)
        setFindingMatchImageView(ride: ride)
    }
    
    func setFindingMatchImageView(ride: Ride) {
        if ride.rideType == Ride.RIDER_RIDE {
            findingMatchImageView.image = UIImage(named: "myride_passenger_icon")
        } else {
            findingMatchImageView.image = UIImage(named: "myride_car_icon")
        }
    }
    
    func setRideStartDateForCardView(ride: Ride) {
        dayTitleLabelBottomConstraint.constant = 10
        dayTitleLabelHeightConstraint.constant = 20
        dayTitleForNextRideLabel.text = DateUtils.configureRideDateTime(ride: ride)
    }
    func configureMatchingListForMyRides(ride: Ride, section: Int, row: Int,viewController : UIViewController) {
        if myRideDetailTableViewCellModel.joinedRideParticipant.count == 0 {
            showLOTAnimation(isShow: true)
            myRideDetailTableViewCellModel.getMatchedRides(ride: ride,viewController : viewController)
            myRideDetailTableViewCellModel.ride = ride
        } else {
            showLOTAnimation(isShow: false)
            alwaysHideFindMatchUI()
        }
    }
    
    func showLOTAnimation(isShow: Bool) {
        if isShow{
            findMatchingView.isHidden = false
            matchAnimatedControlView.isHidden = false
            findingMatchImageView.isHidden = true
            findMatchingTitleLabel.text = ""
            matchAnimatedControlView.animationView.animation = Animation.named("simple-dot-loader")
            matchAnimatedControlView.animationView.play()
            matchAnimatedControlView.animationView.loopMode = .loop
        } else {
            findMatchingView.isHidden = true
            findMatchingTitleLabel.text = ""
            findingMatchImageView.isHidden = true
            matchAnimatedControlView.isHidden = true
            matchAnimatedControlView.animationView.stop()
        }
    }
    
    func alwaysShowFindMatchesUI() {
        findingMatchImageView.isHidden = false
        findMatchingView.isHidden = false
        findMatchingTitleLabel.text = Strings.find_matches
        isMatchParticipantButtonHidden = false
    }
    
    func alwaysHideFindMatchUI() {
        findMatchingView.isHidden = true
        findMatchingTitleLabel.text = ""
        findingMatchImageView.isHidden = true
    }
    
    func getIncomingPendingRideInivitation(ride: Ride) {
        let ridePendingInvitation: [Double: RideInvitation] =  myRideDetailTableViewCellModel.getIncomingInvitesForRide(ride: ride)
        let invites  = Array(ridePendingInvitation.values)
        if invites.count > 0 {
            if ride.rideType == Ride.REGULAR_RIDER_RIDE ||  ride.rideType == Ride.RIDER_RIDE  {
                //Handling Passenger Ride request Invitation to Rider Ride
                var passengerRideInvitation = [RideInvitation]()
                for invite in invites {
                    if ride.rideId == invite.rideId {
                        passengerRideInvitation.append(invite)
                    }
                }
                rideNotificationView.isHidden = false
                rideNotificationView.backgroundColor = .red
                rideNotificationCountLabel.textColor = .white
                rideNotificationImageView.isHidden = true
                rideRequestInfoLabel.text = Ride.RIDE_STATUS_REQUEST_PENDING
                rideNotificationCountLabel.text = "\(passengerRideInvitation.count)"
                rideRequestInfoLabel.textColor = UIColor(netHex: 0xE20000)
                passengerRideInvitation.removeAll()
            } else {
                //Handling Rider Invitation for Passenger Ride
                var riderRideInvitation = [RideInvitation]()
                for invite in invites {
                    if ride.rideId == invite.passenegerRideId {
                        riderRideInvitation.append(invite)
                    }
                }
                rideNotificationView.isHidden = false
                rideNotificationView.backgroundColor = .red
                rideNotificationCountLabel.textColor = .white
                rideRequestInfoLabel.text = Ride.RIDE_STATUS_INVITATION_PENDING
                rideNotificationCountLabel.text = "\(riderRideInvitation.count)"
                rideRequestInfoLabel.textColor = UIColor(netHex: 0xE20000)
                rideNotificationImageView.isHidden = true
                riderRideInvitation.removeAll()
            }
        } else {
            if taxiShareRide != nil {
                return
            }
            rideRequestInfoLabel.text = ""
            rideNotificationView.isHidden = true
        }
    }
    
    func getOutgoingPendingRideInvitations(ride: Ride) {
        //If any incoming Pending Invitation is there, then show that for particular ride
        if myRideDetailTableViewCellModel.getIncomingInvitesForRide(ride: ride).values.count == 0 {
            if taxiShareRide != nil {
                return
            }
            let outgoingPendingInvitation: [RideInvitation] = myRideDetailTableViewCellModel.getOutGoingInvitesForRide(ride: ride)
            if outgoingPendingInvitation.count > 0 {
                if ride.rideType == Ride.REGULAR_RIDER_RIDE ||  ride.rideType == Ride.RIDER_RIDE  {
                    rideNotificationView.isHidden = false
                    rideNotificationView.backgroundColor = .red
                    rideNotificationCountLabel.textColor = .white
                    rideNotificationImageView.isHidden = true
                    rideRequestInfoLabel.text = Ride.RIDE_STATUS_REQUEST_PENDING
                    rideNotificationCountLabel.text = "\(outgoingPendingInvitation.count)"
                    rideRequestInfoLabel.textColor = UIColor(netHex: 0xE20000)
                } else {
                    rideNotificationView.isHidden = false
                    rideNotificationView.backgroundColor = .red
                    rideNotificationCountLabel.textColor = .white
                    rideRequestInfoLabel.text = Ride.RIDE_STATUS_INVITATION_PENDING
                    rideNotificationCountLabel.text = "\(outgoingPendingInvitation.count)"
                    rideRequestInfoLabel.textColor = UIColor(netHex: 0xE20000)
                    rideNotificationImageView.isHidden = true
                }
            }
        }
    }
    
    private func setupShowRideView(isShow: Bool) {
        noMatchView.isHidden = !isShow
        shareRideButton.isHidden = !isShow
        ImageUtils.setTintedIcon(origImage: UIImage(named: "share_icon_green")!, imageView: shareRideButton.imageView!, color: Colors.link)
        isShow ? (noMatchLabel.text = "No Matches") : (noMatchLabel.text = "")
    }
    
    
    private func setupMatchedUserProfileData(matchedUserList: [MatchedUser]) {
        setupShowRideView(isShow: false)
        alwaysHideFindMatchUI()
        matchRiderView.isHidden = false
        if matchedUserList.first?.userRole == Ride.RIDER_RIDE || matchedUserList.first?.userRole == Ride.REGULAR_RIDER_RIDE {
            matchedUserDescriptionLabel.text =  Strings.ride_givers
        } else {
            matchedUserDescriptionLabel.text = Strings.ride_takers
        }
        if matchedUserList.count == 1 {
            ImageCache.getInstance().setImageToView(imageView: allMatchedUserImageViewList[0], imageUrl: matchedUserList.first?.imageURI, gender: matchedUserList.first?.gender ?? "U",imageSize: ImageCache.DIMENTION_TINY)
            configureMatchRiderCountView(isShow: true, matchedUserCount: 0)
        } else if matchedUserList.count == 2 {
            for (index, participent) in matchedUserList.enumerated() {
                ImageCache.getInstance().setImageToView(imageView: allMatchedUserImageViewList[index], imageUrl: participent.imageURI, gender: participent.gender ?? "U",imageSize: ImageCache.DIMENTION_TINY)
            }
            configureMatchRiderCountView(isShow: true, matchedUserCount: 0)
        } else if matchedUserList.count == 3 {
            for (index, participent) in matchedUserList.enumerated() {
                ImageCache.getInstance().setImageToView(imageView: allMatchedUserImageViewList[index], imageUrl: participent.imageURI, gender: participent.gender ?? "U",imageSize: ImageCache.DIMENTION_TINY)
            }
            configureMatchRiderCountView(isShow: true, matchedUserCount: 0)
        } else {
            for (index, participent) in matchedUserList.enumerated() {
                ImageCache.getInstance().setImageToView(imageView: allMatchedUserImageViewList[index], imageUrl: participent.imageURI, gender: participent.gender ?? "U",imageSize: ImageCache.DIMENTION_TINY)
                if index == 1 {
                    break
                }
            }
            allMatchedUserImageViewList[2].image = UIImage(named: "match_user_more_icon")
            configureMatchRiderCountView(isShow: false, matchedUserCount: matchedUserList.count - 2)
        }
        showLOTAnimation(isShow: false)
    }
    
    func configureMatchRiderCountView(isShow: Bool, matchedUserCount: Int? = nil) {
        matchRiderCountLabel.isHidden = isShow
        if !isShow {
            matchRiderCountLabel.text = "+\(matchedUserCount ?? 0)"
        }
        showLOTAnimation(isShow: false)
    }
    @IBAction func shareRideButtonTapped(_ sender: UIButton) {
        JoinMyRide().prepareDeepLinkURLForRide(rideId: StringUtils.getStringFromDouble(decimalNumber: ride?.rideId), riderId: StringUtils.getStringFromDouble(decimalNumber: ride?.userId), from: ride?.startAddress ?? "", to: ride?.endAddress ?? "", startTime: ride?.startTime ?? 0, vehicleType: (ride as? RiderRide)?.vehicleType ?? "", viewController: ViewControllerUtils.getCenterViewController(),isFromTaxiPool: false)
    }
    
    @IBAction func overflowButtonTapped(_ sender: UIButton) {
        delegate?.rideEditButtonTapped(ride: self.ride,rideParticipants: myRideDetailTableViewCellModel.joinedRideParticipant, senderTag: overflowButton.tag,taxiShareRide: self.taxiShareRide, dropDownView: nil)
    }
    
    @IBAction func cellButtonTapped(_ sender: UIButton) {
        if let indexPath = cellIndexPath {
            delegate?.cellButtonTapped(ride: self.ride, indexPath: indexPath)
        }
    }
    
    @IBAction func matchedUserButtonTapped(_ sender: UIButton) {
        //if matchParticipantButton hidden = true--then show live ride screen else show Invite&Match
        if isMatchParticipantButtonHidden || taxiShareRide != nil {
            if let indexPath = cellIndexPath {
                delegate?.cellButtonTapped(ride: self.ride, indexPath: indexPath)
            }
        } else {
            if let ride = ride {
                delegate?.matchUserProfileButtonTapped(ride: ride)
            }
        }
    }
}

extension UpcomingRideCollectionViewCell {
    func checkStatusInfo(for ride: Ride) {
        isMatchParticipantButtonHidden = false
        rideStatusLabel.text = ""
        if let ride = ride as? PassengerRide, (ride.rideType == Ride.REGULAR_PASSENGER_RIDE || ride.rideType == Ride.PASSENGER_RIDE) {
            handleJoinedParticipant(riderRideId: ride.riderRideId)
            if let riderRideStatus = RideManagementUtils.getRiderRideStatusForPassenger(ride: ride), riderRideStatus == Ride.RIDE_STATUS_STARTED {
                setUIForPassengerStartedRide()
            } else {
                if Ride.RIDE_STATUS_SUSPENDED == ride.status {
                    rideNotificationView.isHidden = false
                    rideRequestInfoLabel.textColor = UIColor(netHex: 0xE20000)
                    rideRequestInfoLabel.text = Ride.RIDE_STATUS_SUSPENDED
                } else if Ride.RIDE_STATUS_SCHEDULED == ride.status {
                    let passengerRide = ride
                    if passengerRide.taxiRideId == nil || passengerRide.taxiRideId == 0.0 {
                        rideNotificationView.isHidden = false
                        rideNotificationCountLabel.text = ""
                        rideNotificationView.backgroundColor = .clear
                        rideNotificationImageView.isHidden = false
                        rideRequestInfoLabel.textColor = UIColor(netHex: 0x00B557)
                        rideRequestInfoLabel.text = Ride.FLD_CONFIRMED.uppercased()
                    } else {
                        taxiShareRide = MyActiveRidesCache.singleCacheInstance?.getTaxiShareRideData(taxiRideId: passengerRide.taxiRideId!, userId: passengerRide.userId,myRidesCacheListener: self)
                        guard let taxiShareRide = taxiShareRide else {return}
                        handleTaxiPoolUI(taxiShareRide: taxiShareRide)
                    }
                } else if Ride.RIDE_STATUS_COMPLETED == ride.status {
                    rideRequestInfoLabel.textColor = UIColor(netHex: 0x00B557)
                    rideRequestInfoLabel.text = Ride.RIDE_STATUS_COMPLETED
                } else if Ride.RIDE_STATUS_STARTED == ride.status {
                    let passengerRide = ride
                    if passengerRide.taxiRideId == nil || passengerRide.taxiRideId == 0.0 {
                        setUIForPassengerStartedRide()
                    } else {
                        taxiShareRide = MyActiveRidesCache.singleCacheInstance?.getTaxiShareRideData(taxiRideId: passengerRide.taxiRideId!, userId: passengerRide.userId,myRidesCacheListener: self)
                        guard let taxiShareRide = taxiShareRide else {return}
                        handleTaxiPoolUI(taxiShareRide: taxiShareRide)
                    }
                } else if Ride.CHECK_IN_RIDE == ride.status {
                    isMatchParticipantButtonHidden = true
                } else if Ride.RIDE_STATUS_DELAYED == ride.status {
                    let passengerRide = ride
                    if passengerRide.taxiRideId == nil || passengerRide.taxiRideId == 0.0 {
                        setRideStatusView(status: ride.status)
                    } else {
                        taxiShareRide = MyActiveRidesCache.singleCacheInstance?.getTaxiShareRideData(taxiRideId: passengerRide.taxiRideId!, userId: passengerRide.userId,myRidesCacheListener: self)
                        guard let taxiShareRide = taxiShareRide else {return}
                        handleTaxiPoolUI(taxiShareRide: taxiShareRide)
                    }
                    isMatchParticipantButtonHidden = true
                }
            }
        }
        
        if ride.rideType == Ride.RIDER_RIDE || ride.rideType == Ride.REGULAR_RIDER_RIDE {
            handleJoinedParticipant(riderRideId: ride.rideId)
            if Ride.RIDE_STATUS_SUSPENDED == ride.status {
                rideNotificationView.isHidden = false
                rideRequestInfoLabel.textColor = UIColor(netHex: 0xE20000)
                rideRequestInfoLabel.text = Ride.RIDE_STATUS_SUSPENDED
            } else if Ride.RIDE_STATUS_DELAYED == ride.status {
                setRideStatusView(status: ride.status)
                isMatchParticipantButtonHidden = true
            } else if Ride.RIDE_STATUS_STARTED == ride.status {
                rideNotificationView.isHidden = false
                rideNotificationCountLabel.text = ""
                rideNotificationView.backgroundColor = .clear
                setRideStatusView(status: ride.status)
                isMatchParticipantButtonHidden = true
            } else if Ride.CHECK_IN_RIDE == ride.status {
                isMatchParticipantButtonHidden = true
            }
        }
    }
    
    private func handleTaxiPoolUI(taxiShareRide: TaxiShareRide) {
        rideNotificationCountLabel.text = ""
        rideNotificationView.backgroundColor = .clear
        taxiPoolDataShowingView.isHidden = false
        taxipoolInfoShowingLabel.isHidden = true
        taxiPoolPassengerInfoShowingStackView.isHidden = false
        numberOfSeatsImageArray = [firstSeatImageTaxiPool,secondSeatImageTaxiPool,thirdSeatImageTaxiPool,fourthSeatImageTaxiPool]
        setImageForTaxiPool(capacity: Int(taxiShareRide.capacity ?? 0), availableSeats: Int(taxiShareRide.availableSeats!))
        
        if isPaymentPending(taxiShareRide: taxiShareRide) {
            rideNotificationView.isHidden = true
            rideNotificationImageView.isHidden = true
            rideRequestInfoLabel.textColor = .orange
            rideRequestInfoLabel.text = Strings.payment_pending_title
        }else{
            updateTaxiRideStatus(taxiShareRide: taxiShareRide)
        }
    }
    
    private func isPaymentPending(taxiShareRide: TaxiShareRide) -> Bool{
        var status = false
        for taxiPassengerData in taxiShareRide.taxiShareRidePassengerInfos ?? [] {
            if (taxiPassengerData.passengerUserId == Double(QRSessionManager.sharedInstance?.getUserId() ?? "0")) && (taxiPassengerData.joinStatus == TaxiShareRidePassengerInfos.PAYMENT_PENDING) {
                status = true
            }
        }
        return status
    }
    
    private func updateTaxiRideStatus(taxiShareRide : TaxiShareRide) {
        if Int(taxiShareRide.availableSeats ?? 0) != 0 {
            rideNotificationView.isHidden = true
            rideNotificationImageView.isHidden = true
            rideRequestInfoLabel.textColor = UIColor.black.withAlphaComponent(0.6)
            let availableSeats = Int(taxiShareRide.availableSeats!)
            if availableSeats > 1 {
                rideRequestInfoLabel.text = String(format: Strings.seats_to_confirm_taxi_pool,arguments: [String(availableSeats)]).uppercased()
            } else {
                rideRequestInfoLabel.text = Strings.one_seat_to_confirm_taxi_pool
            }
        } else {
            rideNotificationView.isHidden = false
            rideNotificationImageView.isHidden = false
            rideRequestInfoLabel.textColor = UIColor(netHex: 0x00B557)
            rideRequestInfoLabel.text = updateTaxiPoolStatus()
        }
        if taxiShareRide.vehicleNumber != nil && taxiShareRide.vehicleNumber != "" {
            taxiDetailsShowingView.isHidden = false
            taxiNumberShowingLabel.text = taxiShareRide.vehicleNumber ?? ""
        }
    }
    
    private func setImageForTaxiPool(capacity: Int, availableSeats: Int) {
        for (index, imageView) in numberOfSeatsImageArray.enumerated() {
            imageView.isHidden = !(index < capacity)
            imageView.image = index < capacity - availableSeats ? UIImage(named: "seat_occupied") : UIImage(named: "seat_not_occu_taxi")
        }
    }
    
    func setHomeOfficeAddressView(ride: Ride) {
        homeOfficeAddressView.isHidden = false
        fromToAddressView.isHidden = true
        outStationDataShowingView.isHidden = true
        if let cacheInstance = UserDataCache.getInstance() {
            if let homeLocation = cacheInstance.getHomeLocation(), let  officeLocation = cacheInstance.getOfficeLocation() {
                if ride.startAddress == homeLocation.address, ride.endAddress == officeLocation.address {
                    homeAddressLabel.text = Strings.home
                    officeAddressLabel.text = Strings.office
                    return
                }
                if ride.startAddress == officeLocation.address, ride.endAddress == homeLocation.address {
                    homeAddressLabel.text = Strings.office
                    officeAddressLabel.text = Strings.home
                    return
                }
                setFromToAddressView(ride: ride)
            } else {
                setFromToAddressView(ride: ride)
            }
        }
    }
    
    
    func setRideStatusView(status: String) {
        dayTitleLabelHeightConstraint.constant = 0
        dayTitleLabelBottomConstraint.constant = 0
        rideStatusLabelHeightConstraint.constant = 26
        rideStatusLabelBottomConstraint.constant = 10
        dayTitleForNextRideLabel.text = ""
        if status == Ride.RIDE_STATUS_STARTED {
            rideStatusLabel.text = Ride.RIDE_STATUS_STARTED.uppercased()
            rideStatusLabel.textColor = UIColor(netHex: 0x00b557)
            rideStatusLabel.backgroundColor = UIColor(red: 0.0, green: 0.71, blue: 0.34, alpha: 0.1)
        } else if status == Ride.RIDE_STATUS_DELAYED {
            rideStatusLabel.text = Ride.RIDE_STATUS_DELAYED.uppercased()
            rideStatusLabel.textColor = UIColor(netHex: 0xfd5d5d)
            rideStatusLabel.backgroundColor = UIColor(red: 253/255.0, green: 93/255.0, blue: 93/255.0, alpha: 0.2)
        }
    }
    
    func setFromToAddressView(ride: Ride) {
        if let taxiShareRide = taxiShareRide {
            if taxiShareRide.tripType == Strings.out_station {
                fromToAddressView.isHidden = true
                homeOfficeAddressView.isHidden = true
                outStationDataShowingView.isHidden = false
                if taxiShareRide.journeyType == TaxiShareRide.ONE_WAY{
                    outStationDetailsLabel.text = String(format: Strings.one_way_trip_to, arguments: [taxiShareRide.endAddress ?? ""])
                }else{
                    outStationDetailsLabel.text = String(format: Strings.round_trip_to_myride, arguments: [taxiShareRide.endAddress ?? ""])
                }
            }else{
                setRideaddress(startAddress: ride.startAddress, endAddress: ride.endAddress)
            }
        }else{
            setRideaddress(startAddress: ride.startAddress, endAddress: ride.endAddress)
        }
    }
    
    private func setRideaddress(startAddress : String ,endAddress: String) {
        homeOfficeAddressView.isHidden = true
        fromToAddressView.isHidden = false
        outStationDataShowingView.isHidden = true
        fromAddressLabel.text = startAddress
        toAddressLabel.text = endAddress
    }
    
    
    func configureAddressInfo(ride: Ride) {
        if let userCache = UserDataCache.getInstance(), let _ = userCache.getHomeLocation(), let _ = userCache.getOfficeLocation() {
            setHomeOfficeAddressView(ride: ride)
        } else {
            setFromToAddressView(ride: ride)
        }
    }
    
    func getShortAddressForStartLocation(ride: Ride) {
        self.fromAddressLabel.text = ride.startAddress
    }
    
    func getShortAddressForEndLocation(ride: Ride) {
        self.toAddressLabel.text = ride.endAddress
    }
    
    func setUIForPassengerStartedRide() {
        rideNotificationView.isHidden = false
        rideNotificationCountLabel.text = ""
        rideNotificationView.backgroundColor = .clear
        rideRequestInfoLabel.textColor = UIColor(netHex: 0x00B557)
        rideRequestInfoLabel.text = Ride.FLD_CONFIRMED.uppercased()
        setRideStatusView(status: Ride.RIDE_STATUS_STARTED)
        isMatchParticipantButtonHidden = true
    }
    
    private func updateTaxiPoolStatus() -> String {
        if let taxiShareRide = taxiShareRide {
            switch taxiShareRide.status {
            case TaxiShareRide.TAXI_SHARE_RIDE_STARTED :
                return Strings.taxi_started
            case TaxiShareRide.TAXI_SHARE_RIDE_DELAYED :
                return Strings.taxi_delayed
            case TaxiShareRide.TAXI_SHARE_RIDE_BOOKING_IN_PROGRESS, TaxiShareRide.TAXI_SHARE_RIDE_SUCCESSFUL_BOOKING,TaxiShareRide.TAXI_SHARE_RIDE_POOL_IN_PROGRESS :
                return Strings.taxi_allotment_process
            case TaxiShareRide.TAXI_SHARE_RIDE_POOL_CONFIRMED :
                if taxiShareRide.shareType == GetTaxiShareMinMaxFare.EXCLUSIVE_TAXI {
                    return Strings.exclusive_taxi_confirmed
                }else{
                    return Strings.taxi_pool_confirm
                }
            case TaxiShareRide.TAXI_SHARE_RIDE_ALLOTTED,TaxiShareRide.TAXI_SHARE_RIDE_RE_ALLOTTED :
                return Strings.taxi_alloted
            case TaxiShareRide.TAXI_SHARE_RIDE_ARRIVED :
                return Strings.taxi_arrived
            default:
                return Strings.taxi_joined
            }
        }else { return "" }
    }
}
//MARK: MyRidePendingNotificationDelegate
extension UpcomingRideCollectionViewCell: MyRideDetailTableViewCellModelDelegate {
    func receivedMatchedTaxiDetails(matchedTaxi: [MatchedShareTaxi]) {
        if matchedTaxi.count != 0 {
            taxiPoolDataShowingView.isHidden = false
            taxipoolInfoShowingLabel.isHidden = false
            taxiPoolPassengerInfoShowingStackView.isHidden = true
        }
    }
    
    func receiveMatchedRiderDetails(matchedUser: [MatchedUser]) {
        showLOTAnimation(isShow: false)
        if matchedUser.count > 0 {
            setupMatchedUserProfileData(matchedUserList: matchedUser)
            matchParticipantButton.isHidden = false
        } else {
            matchParticipantButton.isHidden = true
            matchRiderView.isHidden = true
            if myRideDetailTableViewCellModel.ride?.rideType == Ride.RIDER_RIDE{
                setupShowRideView(isShow: true)
            }else{
                setupShowRideView(isShow: false)
                alwaysShowFindMatchesUI()
                findMatchingTitleLabel.text = "No Matches"
            }
        }
    }
    
}

//MARK: Joined Rideparticipant showing if present
extension UpcomingRideCollectionViewCell {
    private func handleJoinedParticipant(riderRideId: Double?) {
        if let rideParticipants = MyActiveRidesCache.getRidesCacheInstance()?.getRideDetailInfoIfExist(riderRideId: riderRideId)?.rideParticipants {
            var newRideParticipants = [RideParticipant]()
            for rideParticipant in rideParticipants{
                if rideParticipant.userId == Double(QRSessionManager.getInstance()!.getUserId()){
                    continue
                }
                if rideParticipant.status != Ride.RIDE_STATUS_COMPLETED {
                    newRideParticipants.append(rideParticipant)
                }
            }
            myRideDetailTableViewCellModel.joinedRideParticipant = newRideParticipants
            //If joined participant data will be available, then not showing matched user list and tapping on profile button it should go to live ride screen
            if myRideDetailTableViewCellModel.joinedRideParticipant.count > 0 {
                rideNotificationImageView.isHidden = false
                alwaysHideFindMatchUI()
                isMatchParticipantButtonHidden = true
                setupRideParticipantsData(rideParticipantList: newRideParticipants)
            } else {
                rideNotificationView.isHidden = true
                rideNotificationView.backgroundColor = .clear
                rideNotificationImageView.isHidden = true
                rideRequestInfoLabel.text = ""
                showLOTAnimation(isShow: true)
                isMatchParticipantButtonHidden = false
            }
        }
    }
    
    func setupRideParticipantsData(rideParticipantList: [RideParticipant]) {
        setupShowRideView(isShow: false)
        alwaysHideFindMatchUI()
        isMatchParticipantButtonHidden = true
        matchRiderView.isHidden = false
        if let ride = self.ride, ride.rideType == Ride.REGULAR_RIDER_RIDE || ride.rideType == Ride.RIDER_RIDE {
            rideRequestInfoLabel.textColor =  UIColor(netHex: 0x00b557)
            if rideParticipantList.count == 1 {
                rideRequestInfoLabel.text = String(format: Strings.rider_joined, "\(rideParticipantList.count)")
            } else {
                rideRequestInfoLabel.text = String(format: Strings.riders_joined, "\(rideParticipantList.count)")
            }
            if rideParticipantList.count == 1 {
                matchedUserDescriptionLabel.text = rideParticipantList.first?.name
                ImageCache.getInstance().setImageToView(imageView: allMatchedUserImageViewList[0], imageUrl:  rideParticipantList.first?.imageURI, gender: rideParticipantList.first?.gender ?? "U",imageSize: ImageCache.DIMENTION_TINY)
                RideViewUtils.setBorderToUserImageBasedOnStatus(image: allMatchedUserImageViewList[0], status: rideParticipantList.first?.status ?? "")
                configureMatchRiderCountView(isShow: true, matchedUserCount: 0)
                return
            } else if rideParticipantList.count == 2 {
                for (index, participent) in rideParticipantList.enumerated() {
                    ImageCache.getInstance().setImageToView(imageView: allMatchedUserImageViewList[index], imageUrl: participent.imageURI, gender: participent.gender ?? "U",imageSize: ImageCache.DIMENTION_TINY)
                    RideViewUtils.setBorderToUserImageBasedOnStatus(image: allMatchedUserImageViewList[index], status: participent.status)
                }
                matchedUserDescriptionLabel.text = (rideParticipantList.first?.name ?? "") + " + 1"
                configureMatchRiderCountView(isShow: true, matchedUserCount: 0)
                return
            } else if rideParticipantList.count == 3 {
                for (index, participent) in rideParticipantList.enumerated() {
                    ImageCache.getInstance().setImageToView(imageView: allMatchedUserImageViewList[index], imageUrl: participent.imageURI, gender: participent.gender ?? "U",imageSize: ImageCache.DIMENTION_TINY)
                    RideViewUtils.setBorderToUserImageBasedOnStatus(image: allMatchedUserImageViewList[index], status: participent.status)
                }
                matchedUserDescriptionLabel.text = (rideParticipantList.first?.name ?? "") + " + 2"
                configureMatchRiderCountView(isShow: true, matchedUserCount: 0)
                return
            } else {
                for (index, participent) in rideParticipantList.enumerated() {
                    ImageCache.getInstance().setImageToView(imageView: allMatchedUserImageViewList[index], imageUrl: participent.imageURI, gender: participent.gender ?? "U",imageSize: ImageCache.DIMENTION_TINY)
                    RideViewUtils.setBorderToUserImageBasedOnStatus(image: allMatchedUserImageViewList[index], status: participent.status)
                    if index == 1 {
                        break
                    }
                }
                allMatchedUserImageViewList[2].image = UIImage(named: "match_user_more_icon")
                configureMatchRiderCountView(isShow: false, matchedUserCount: rideParticipantList.count - 2)
                return
            }
        } else {
            //For passenger only show rider details
            for participent in rideParticipantList {
                if participent.rider {
                    matchedUserDescriptionLabel.text = participent.name
                    ImageCache.getInstance().setImageToView(imageView: allMatchedUserImageViewList[0], imageUrl:  participent.imageURI, gender: participent.gender ?? "U",imageSize: ImageCache.DIMENTION_TINY)
                    RideViewUtils.setBorderToUserImageBasedOnStatus(image: allMatchedUserImageViewList[0], status: participent.status)
                    configureMatchRiderCountView(isShow: true, matchedUserCount: 0)
                    return
                }
            }
        }
    }
}
extension UpcomingRideCollectionViewCell : MyRidesCacheListener {
    func receivedActiveRides(activeRiderRides: [Double : RiderRide], activePassengerRides: [Double : PassengerRide]) {}
    
    func receiveClosedRides(closedRiderRides: [Double : RiderRide], closedPassengerRides: [Double : PassengerRide]) {}
    
    func receiveActiveRegularRides(regularRiderRides: [Double : RegularRiderRide], regularPassengerRides: [Double : RegularPassengerRide]) {}
    
    func receiveRideDetailInfo(rideDetailInfo: RideDetailInfo) {
        if rideDetailInfo.taxiShareRide != nil {
            taxiShareRide = rideDetailInfo.taxiShareRide
            handleTaxiPoolUI(taxiShareRide: taxiShareRide!)
        }
    }
    func onRetrievalFailure(responseError: ResponseError?, error: NSError?) {}
}
