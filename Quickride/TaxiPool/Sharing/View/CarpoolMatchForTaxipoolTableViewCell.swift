//
//  CarpoolMatchForTaxipoolTableViewCell.swift
//  Quickride
//
//  Created by QR Mac 1 on 07/10/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class CarpoolMatchForTaxipoolTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: CircularImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var verificationImage: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var deviationLabel: UILabel!
    @IBOutlet weak var pickupTimeLabel: UILabel!
    @IBOutlet weak var callChatView: UIView!
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var invitingImage: UIImageView!
    @IBOutlet weak var inviteButton: QRCustomButton!
    @IBOutlet weak var ratingShowingLabelHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var callButton: UIButton!
    
    private var carpoolMatch: MatchingTaxiPassenger?
    private var viewModel =  TaxipoolPassengersViewModel()
    
    func showCarpoolMatch(carpoolMatch: MatchingTaxiPassenger,viewModel: TaxipoolPassengersViewModel){
        self.carpoolMatch = carpoolMatch
        self.viewModel = viewModel
        ImageCache.getInstance().setImageToView(imageView: userImageView, imageUrl: carpoolMatch.imageURI ?? "", gender: carpoolMatch.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
        userNameLabel.text = carpoolMatch.name?.capitalized
        companyNameLabel.text = UserVerificationUtils.getVerificationTextBasedOnVerificationData(profileVerificationData: carpoolMatch.profileVerificationData, companyName: carpoolMatch.companyName?.capitalized)
        if companyNameLabel.text == Strings.not_verified {
            companyNameLabel.textColor = UIColor.black
        }else{
            companyNameLabel.textColor = UIColor(netHex: 0x24A647)
        }
        if (carpoolMatch.rating)! > 0.0{
            ratingShowingLabelHeightConstraints.constant = 20.0
            ratingLabel.font = UIFont.systemFont(ofSize: 13.0)
            ratingImage.isHidden = false
            ratingLabel.textColor = UIColor(netHex: 0x9BA3B1)
            ratingLabel.text = String(carpoolMatch.rating!) + "(\(String(carpoolMatch.noOfReviews)))"
            ratingLabel.backgroundColor = .clear
            ratingLabel.layer.cornerRadius = 0.0
        }else{
            ratingShowingLabelHeightConstraints.constant = 15.0
            ratingLabel.font = UIFont.boldSystemFont(ofSize: 10.0)
            ratingImage.isHidden = true
            ratingLabel.textColor = .white
            ratingLabel.text = Strings.new_user_matching_list
            ratingLabel.backgroundColor = UIColor(netHex: 0xFCA126)
            ratingLabel.layer.cornerRadius = 8.0
            ratingLabel.layer.masksToBounds = true
        }
        verificationImage.image =  UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: carpoolMatch.profileVerificationData)
        deviationLabel.text = TaxiUtils.getDistanceString(distance: carpoolMatch.deviation)
        pickupTimeLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: carpoolMatch.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)
        handleCustomizationToInviteView()
        if let _ = MyActiveTaxiRideCache.getInstance().getTaxiOutgoingInvite(taxiRideId: viewModel.taxiRide?.id ?? 0, userId: carpoolMatch.userid ?? 0){
            showCallChatView()
        }else{
            inviteView.isHidden = false
            callChatView.isHidden = true
        }
    }
    
    private func handleCustomizationToInviteView(){
        invitingImage.animationImages
            = [UIImage(named: "match_option_invite_progress_1"),UIImage(named: "match_option_invite_progress_2")] as? [UIImage]
        invitingImage.isHidden = true
        invitingImage.animationDuration = 0.3
    }
    
    private func startAnimation(){
        invitingImage.isHidden = false
        invitingImage.startAnimating()
        inviteButton.isHidden = true
    }
    
    private func stopAnimation(){
        invitingImage.isHidden = true
        invitingImage.stopAnimating()
        inviteButton.isHidden = false
    }
    
    private func showCallChatView(){
        inviteView.isHidden = true
        callChatView.isHidden = false
        checkCallOptionAvailability()
    }
    
    @IBAction func inviteButtonTapped(_ sender: Any) {
        guard let taxiRide = viewModel.taxiRide, let carpoolMatch = carpoolMatch else { return }
        let taxiInvite = TaxiPoolInvite(taxiRideGroupId: Int(taxiRide.taxiGroupId ?? 0), invitingUserId: Int(taxiRide.userId ?? 0), invitingRideId: Int(taxiRide.id ?? 0), invitingRideType: TaxiPoolInvite.TAXI, invitedUserId: Int(carpoolMatch.userid ?? 0), invitedRideId: Int(carpoolMatch.rideid ?? 0), invitedRideType: TaxiPoolInvite.TAXI, fromLat: carpoolMatch.fromLocationLatitude ?? 0, fromLng: carpoolMatch.fromLocationLongitude ?? 0, toLat: carpoolMatch.toLocationLatitude ?? 0, toLng: carpoolMatch.toLocationLongitude ?? 0, distance: carpoolMatch.distance ?? 0, pickupTimeMs: Int(carpoolMatch.pickupTime ?? 0), overviewPolyLine: carpoolMatch.taxiRoutePolyline ?? "")
        startAnimation()
        viewModel.sendInviteToCarpoolPassenger(taxiInvite: taxiInvite) { [weak self] responseObject, error in
            self?.stopAnimation()
            if responseObject == nil && error == nil{
                self?.showCallChatView()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self?.parentViewController, handler: nil)
            }
        }
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        if sender.backgroundColor == UIColor(netHex: 0xcad2de) {
            guard let call_disaable_msg = getErrorMessageForCall() else { return }
            UIApplication.shared.keyWindow?.makeToast( call_disaable_msg)
            return
        }
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: carpoolMatch?.userid), refId: "", name: carpoolMatch?.name ?? "", targetViewController: parentViewController ?? ViewControllerUtils.getCenterViewController())
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        guard let userId = carpoolMatch?.userid else { return }
        let chatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatViewController.isFromTaxipool = true
        chatViewController.initializeDataBeforePresentingView(ride: nil, userId: userId, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: chatViewController, animated: false)
    }
    
    @IBAction func moreButtonTapped(_ sender: Any) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.remind, style: .default) { action -> Void in
            guard let invite = MyActiveTaxiRideCache.getInstance().getTaxiOutgoingInvite(taxiRideId: self.viewModel.taxiRide?.id ?? 0, userId: self.carpoolMatch?.userid ?? 0) else { return }
            self.viewModel.sendInviteToCarpoolPassenger(taxiInvite: invite) { responseObject, error in
                if responseObject == nil || error == nil{
                }else{
                }
            }
        }
        
        let secondAction: UIAlertAction = UIAlertAction(title: Strings.cancel_invite, style: .default) { action -> Void in
            guard let invite = MyActiveTaxiRideCache.getInstance().getTaxiOutgoingInvite(taxiRideId: self.viewModel.taxiRide?.id ?? 0, userId: self.carpoolMatch?.userid ?? 0) else { return }
            QuickRideProgressSpinner.startSpinner()
            self.viewModel.cancelCarpoolPassengerInvite(inviteId: invite.id ?? "") { responseObject, error in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject == nil && error == nil{
                    self.inviteView.isHidden = false
                    self.inviteView.isHidden = true
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self.parentViewController, handler: nil)
                }
            }
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in}
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        parentViewController?.present(actionSheetController, animated: true)
    }
    
    @IBAction func goToProfileTapped(_ sender: Any) {
        let profileDisplayViewController = (UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController)
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: carpoolMatch?.userid), isRiderProfile: UserRole.Passenger, rideVehicle: nil, userSelectionDelegate: nil, displayAction: true, isFromRideDetailView: false, rideNotes: carpoolMatch?.rideNotes, matchedRiderOnTimeCompliance: carpoolMatch?.userOnTimeComplianceRating, noOfSeats: 1, isSafeKeeper: carpoolMatch?.hasSafeKeeperBadge ?? false)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: profileDisplayViewController, animated: false)
    }
    
    func getErrorMessageForCall() -> String?{
        if (carpoolMatch?.userRole == MatchedUser.RIDER || carpoolMatch?.userRole == MatchedUser.REGULAR_RIDER) && !RideManagementUtils.getUserQualifiedToDisplayContact(){
            return Strings.link_wallet_for_call_msg
        }else if let enableChatAndCall = carpoolMatch?.enableChatAndCall, !enableChatAndCall{
            return Strings.chat_and_call_disable_msg
        }else if carpoolMatch?.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED{
            return Strings.call_joined_partner_msg
        }else if carpoolMatch?.callSupport == UserProfile.SUPPORT_CALL_NEVER{
            return Strings.no_call_please_msg
        }
        return nil
    }
    func checkCallOptionAvailability(){
        if UserProfile.SUPPORT_CALL_ALWAYS == carpoolMatch?.callSupport && carpoolMatch?.enableChatAndCall == true {
            callButton.backgroundColor = UIColor(netHex: 0x2196F3)
        }else if carpoolMatch?.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED && carpoolMatch?.enableChatAndCall == true{
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: carpoolMatch?.userid))
            if contact != nil && contact!.contactType == Contact.RIDE_PARTNER{
                callButton.backgroundColor = UIColor(netHex: 0x2196F3)
            }else{
                callButton.backgroundColor = UIColor(netHex: 0xcad2de)
            }
        }else{
            callButton.backgroundColor = UIColor(netHex: 0xcad2de)
        }
    }
}
