//
//  InviteCarpoolRideGiverCollectionViewCell.swift
//  Quickride
//
//  Created by HK on 11/11/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import CoreLocation

class InviteCarpoolRideGiverCollectionViewCell: UICollectionViewCell {
    
    //MARK: Profile
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileVerificationImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var starImageView: UIImageView!
    @IBOutlet weak var ratingShowingLabel: UILabel!
    @IBOutlet weak var ratingShowingLabelHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var routeMatcPercentageLabel: UILabel!
    @IBOutlet weak var pointsShowingLabel: UILabel!
    @IBOutlet weak var rideTimeShowingLabel: UILabel!
    //MARK:Ride Taker PickUpDataShowingView
    @IBOutlet weak var walkPathViewForPickUp: UIView!
    @IBOutlet weak var walkPathAfterTravelView: UIView!
    @IBOutlet weak var walkPathdistanceShowingLabel: UILabel!
    @IBOutlet weak var afterRideWalkingDistanceShowingLabel: UILabel!
    //MARK: RideTakerORGiver Points Details
    @IBOutlet weak var firstSeatImageView: UIImageView!
    @IBOutlet weak var secondSeatImageView: UIImageView!
    @IBOutlet weak var thirdSeatImageView: UIImageView!
    @IBOutlet weak var fouthSeatImageView: UIImageView!
    @IBOutlet weak var fifthSeatImageView: UIImageView!
    @IBOutlet weak var sixthSeatImageView: UIImageView!
    //MARK: Contact Options
    @IBOutlet weak var contactOptionShowingView: UIView!
    @IBOutlet weak var callOptionBtn: UIButton!
    @IBOutlet weak var chatOptionBtn: UIButton!
    @IBOutlet weak var moreOptionBtn: UIButton!
    //MARK: Invite
    @IBOutlet weak var inviteRideShowingView: UIView!
    @IBOutlet weak var inviteProgressImageView: UIImageView!
    @IBOutlet weak var inviteRideBtn: UIButton!
    
    private var numberOfSeatsImageArray = [UIImageView]()
    private weak var viewcontroller: UIViewController?
    private var viewModel = InviteCarpoolRideGiverCollectionViewCellModel()
    
    func showMatchedRider(matchedRider: MatchedRider,taxiRide: TaxiRidePassenger,viewcontroller: UIViewController){
        viewModel = InviteCarpoolRideGiverCollectionViewCellModel(matchedRider: matchedRider, taxiRide: taxiRide)
        self.viewcontroller = viewcontroller
        setUpUI()
        handleCustomizationToInviteView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        numberOfSeatsImageArray = [firstSeatImageView,secondSeatImageView,thirdSeatImageView,fouthSeatImageView,fifthSeatImageView,sixthSeatImageView]
    }
    private func setUpUI() {
        ImageCache.getInstance().setImageToView(imageView: profileImageView, imageUrl: viewModel.matchedRider?.imageURI ?? "", gender: viewModel.matchedRider?.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        nameLabel.text = viewModel.matchedRider?.name?.capitalized
        let companyName = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: viewModel.matchedRider?.profileVerificationData, companyName: viewModel.matchedRider?.companyName?.capitalized)
        companyNameLabel.text = companyName
        if companyNameLabel.text == Strings.not_verified {
            companyNameLabel.textColor = UIColor.black
        }else{
            companyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        if (viewModel.matchedRider?.rating)! > 0.0{
            ratingShowingLabelHeightConstraints.constant = 20.0
            ratingShowingLabel.font = UIFont.systemFont(ofSize: 13.0)
            starImageView.isHidden = false
            ratingShowingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingShowingLabel.text = String(viewModel.matchedRider?.rating ?? 0) + "(\(String(viewModel.matchedRider?.noOfReviews ?? 0)))"
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
        profileVerificationImageView.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: viewModel.matchedRider?.profileVerificationData)
        setDataForRider()
        handleCallBtnVisibility()
        handleVisibilityOfInviteElementsBasedOnInvite(riderRideId: viewModel.taxiRide?.id ?? 0, passengerRideId: viewModel.matchedRider!.rideid!)
    }
    private func handleVisibilityOfInviteElementsBasedOnInvite(riderRideId : Double,passengerRideId : Double){
        if let _ = RideInviteCache.getInstance().getOutGoingInvitationPresentBetweenRide(riderRideId: viewModel.matchedRider?.rideid ?? 0, passengerRideId: viewModel.taxiRide?.id ?? 0, rideType: TaxiPoolConstants.Taxi,userId: viewModel.matchedRider!.userid!){
            showRequestSentView()
        }else{
            showInviteView()
        }
    }
    
    private func handleCallBtnVisibility() {
        contactOptionShowingView.isHidden = false
        if UserProfile.SUPPORT_CALL_ALWAYS == viewModel.matchedRider!.callSupport && viewModel.matchedRider!.enableChatAndCall {
            enableCallOption(status: true)
        }else if viewModel.matchedRider!.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED && viewModel.matchedRider!.enableChatAndCall {
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: viewModel.matchedRider?.userid))
            if contact != nil && contact!.contactType == Contact.RIDE_PARTNER{
                enableCallOption(status: true)
            }else{
                enableCallOption(status: false)
            }
        }else{
            enableCallOption(status: false)
        }
    }
    
    private func enableCallOption(status: Bool) {
        if status {
            callOptionBtn.backgroundColor = UIColor(netHex: 0x2196F3)
        }else{
            callOptionBtn.backgroundColor = UIColor(netHex: 0xcad2de)
        }
    }
    
    private func setDataForRider() {
        rideTimeShowingLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: viewModel.matchedRider?.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        routeMatcPercentageLabel.text = "\(viewModel.matchedRider?.matchPercentage ?? 0)" + Strings.percentage_symbol
        pointsShowingLabel.text = StringUtils.getStringFromDouble(decimalNumber: viewModel.matchedRider?.points) + " \(Strings.points_new)"
        setOccupiedSeats(availableSeats: viewModel.matchedRider?.availableSeats ?? 1, capacity: viewModel.matchedRider?.capacity ?? 1)
        let startLocation = CLLocation(latitude: viewModel.taxiRide?.startLat ?? 0,longitude: viewModel.taxiRide?.startLng ?? 0)
        let pickUpLoaction = CLLocation(latitude: viewModel.matchedRider?.pickupLocationLatitude ?? 0,longitude: viewModel.matchedRider?.pickupLocationLongitude ?? 0)
        let startToPickupWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: startLocation, point2: pickUpLoaction, polyline: viewModel.taxiRide?.routePolyline ?? "")
        walkPathdistanceShowingLabel.text = getDistanceString(distance: startToPickupWalkDistance)
        let endLocation =  CLLocation(latitude: viewModel.taxiRide?.endLat ?? 0, longitude: viewModel.taxiRide?.endLng ?? 0)
        let dropToEndWalkDistance = GoogleMapUtils.getWalkPathForMatchedUser(point1: CLLocation(latitude: viewModel.matchedRider?.dropLocationLatitude ?? 0, longitude: viewModel.matchedRider?.dropLocationLongitude ?? 0), point2: endLocation , polyline: viewModel.taxiRide?.routePolyline ?? "")
        afterRideWalkingDistanceShowingLabel.text = getDistanceString(distance: dropToEndWalkDistance)
    }
    
    private func getDistanceString(distance: Double) -> String {
        if distance > 1000{
            var convertDistance = (distance/1000)
            let roundTodecimalTwoPoints = convertDistance.roundToPlaces(places: 1)
            return "\(roundTodecimalTwoPoints) \(Strings.KM)"
        } else {
            let roundTodecimalTwoPoints = Int(distance)
            return "\(roundTodecimalTwoPoints) \(Strings.meter)"
        }
    }
    
    private func setOccupiedSeats(availableSeats: Int, capacity: Int) {
        for (index, imageView) in numberOfSeatsImageArray.enumerated() {
            imageView.isHidden = !(index < capacity)
            imageView.image = index < capacity - availableSeats ? UIImage(named: "seat_occupied") : UIImage(named: "seats_not_occupied")
        }
    }
    
    @IBAction func inviteRideBtnPressed(_ sender: UIButton) {
        let defaultPaymentMethod = UserDataCache.getInstance()?.getDefaultLinkedWallet()
        if (defaultPaymentMethod?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI_GPAY_IPHONE || defaultPaymentMethod?.type == AccountTransaction.TRANSACTION_WALLET_TYPE_UPI) && SendInviteViewModel.isAnimating {
            inviteRideBtn.shake()
            UIApplication.shared.keyWindow?.makeToast(Strings.request_in_progress)
            return
        }
        if inviteRideBtn.tag >= 0 {
            inviteRideBtn.isHidden = true
            inviteProgressImageView.isHidden = false
            self.inviteProgressImageView.startAnimating()
            SendInviteViewModel.isAnimating = true
        }
        invitingRider(matchedUser: viewModel.matchedRider!)
    }
    
    private func invitingRider(matchedUser : MatchedRider) {
        var selectedRiders = [MatchedRider]()
        selectedRiders.append(matchedUser)
        let ride = PassengerRide(ride: Ride(taxiRide: viewModel.taxiRide!))
        ride.rideType = TaxiPoolConstants.Taxi
        startAnimation()
        InviteRiderHandler(passengerRide: ride, selectedRiders: selectedRiders, displaySpinner: false, selectedIndex: "0", viewController: viewcontroller ?? ViewControllerUtils.getCenterViewController()).inviteSelectedRiders(inviteHandler: { (error,nserror) in
            self.stopAnimation()
            SendInviteViewModel.isAnimating = false
            if error == nil && nserror == nil{
                self.showRequestSentView()
            }else{
                ErrorProcessUtils.handleResponseError(responseError: error, error: nserror, viewController: self.viewcontroller)
            }
        })
    }
    
    private func showRequestSentView(){
        contactOptionShowingView.isHidden = false
        inviteRideShowingView.isHidden = true
    }
    private func showInviteView(){
        contactOptionShowingView.isHidden = true
        inviteRideShowingView.isHidden = false
    }
    private func handleCustomizationToInviteView(){
        inviteProgressImageView.animationImages
            = [UIImage(named: "match_option_invite_progress_1"),UIImage(named: "match_option_invite_progress_2")] as? [UIImage]
        inviteProgressImageView.isHidden = true
        inviteProgressImageView.animationDuration = 0.3
    }
    
    private func startAnimation(){
        inviteProgressImageView.isHidden = false
        inviteProgressImageView.startAnimating()
        inviteRideBtn.isHidden = true
    }
    
    private func stopAnimation(){
        inviteProgressImageView.isHidden = true
        inviteProgressImageView.stopAnimating()
        inviteRideBtn.isHidden = false
    }
    
    func getErrorMessageForCall() -> String?{
        if (viewModel.matchedRider?.userRole == MatchedUser.RIDER || viewModel.matchedRider?.userRole == MatchedUser.REGULAR_RIDER) && !RideManagementUtils.getUserQualifiedToDisplayContact(){
            return Strings.link_wallet_for_call_msg
        }else if let enableChatAndCall = viewModel.matchedRider?.enableChatAndCall, !enableChatAndCall{
            return Strings.chat_and_call_disable_msg
        }else if viewModel.matchedRider?.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED{
            return Strings.call_joined_partner_msg
        }else if viewModel.matchedRider?.callSupport == UserProfile.SUPPORT_CALL_NEVER{
            return Strings.no_call_please_msg
        }
        return nil
    }
    
    @IBAction func callBtnPressed(_ sender: UIButton) {
        if sender.backgroundColor == UIColor(netHex: 0xcad2de) {
            guard let call_disaable_msg = getErrorMessageForCall() else { return }
            UIApplication.shared.keyWindow?.makeToast( call_disaable_msg)
            return
        }
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: viewModel.matchedRider!.userid), refId: "", name: viewModel.matchedRider?.name ?? "", targetViewController: ViewControllerUtils.getCenterViewController())
    }
    
    @IBAction func chatOptionPressed(_ sender: UIButton) {
        guard let userId = viewModel.matchedRider?.userid else { return }
        let chatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatViewController.isFromTaxipool = true
        chatViewController.initializeDataBeforePresentingView(ride: nil, userId: userId, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: viewcontroller, viewControllerToBeDisplayed: chatViewController, animated: false)
    }
    
    @IBAction func moreOptionPressed(_ sender: UIButton) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.remind, style: .default) { action -> Void in
            self.invitingRider(matchedUser: self.viewModel.matchedRider!)
        }
        let secondAction: UIAlertAction = UIAlertAction(title: Strings.cancel_invite, style: .default) { action -> Void in
            if let invitation = RideInviteCache.getInstance().getOutGoingInvitationPresentBetweenRide(riderRideId: self.viewModel.matchedRider?.rideid ?? 0, passengerRideId: self.viewModel.taxiRide?.id ?? 0, rideType: TaxiPoolConstants.Taxi,userId: self.viewModel.matchedRider!.userid!) {
                QuickRideProgressSpinner.startSpinner()
                self.viewModel.cancelSentInvite(invitation: invitation) { responseObject, error in
                    QuickRideProgressSpinner.stopSpinner()
                    if responseObject == nil && error == nil{
                        self.showInviteView()
                    }else{
                        ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.viewcontroller, handler: nil)
                    }
                }
            }
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        viewcontroller?.present(actionSheetController, animated: true)
    }
    
}
