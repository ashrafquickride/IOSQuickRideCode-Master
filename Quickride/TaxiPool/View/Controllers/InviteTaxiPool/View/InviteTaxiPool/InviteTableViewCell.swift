//
//  InviteTableViewCell.swift
//  Quickride
//
//  Created by Ashutos on 8/6/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class InviteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftView: UIView!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var backGroundView: QuickRideCardView!
    @IBOutlet weak var profileImageView: CircularImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var verificationStatusImageView: UIImageView!
    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var ratingStackView: UIStackView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var deviationKMLabel: UILabel!
    @IBOutlet weak var pickUptimeShowingLabel: UILabel!
    @IBOutlet weak var animationImageView: UIImageView!
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var contactOptionView: UIView!
    @IBOutlet weak var callOptionBtn: UIButton!
    @IBOutlet weak var chatOptionBtn: UIButton!
    @IBOutlet weak var moreOptionBtn: UIButton!
    @IBOutlet weak var inviteStatusImageView: UIImageView!
    @IBOutlet weak var inviteStatusLabel: UILabel!
    @IBOutlet weak var inviteBtn: QRCustomButton!
    
    private var inviteTaxiPoolCellViewModel: InviteTaxiPoolCellViewModel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpUIWithData(data: MatchedPassenger?,ride: Ride?,row: Int,allInvites: [TaxiInviteEntity]?) {
        inviteTaxiPoolCellViewModel = InviteTaxiPoolCellViewModel(ride: ride, matchedPassengerData: data,row: row, allInvites: allInvites)
        setUPUI(data: inviteTaxiPoolCellViewModel?.matchedPassengerData)
        handleInviteStatus()
    }
    
    private func setUPUI(data: MatchedPassenger?) {
        if let passengerData = data {
            profileImageView.isUserInteractionEnabled = true
            profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
            verificationStatusImageView.image = UserVerificationUtils.getVerificationImageBasedOnVerificationData(profileVerificationData: passengerData.profileVerificationData)
            ImageCache.getInstance().setImageToView(imageView: profileImageView, imageUrl: passengerData.imageURI ?? "", gender: passengerData.gender ?? "U",imageSize: ImageCache.DIMENTION_SMALL)
            nameLabel.text = passengerData.name?.capitalized
            companyNameLabel.text = inviteTaxiPoolCellViewModel?.getCompanyName(data: passengerData)
            getSetRating(passengerData: passengerData)
            pickUptimeShowingLabel.text = DateUtils.getTimeStringFromTimeInMillis(timeStamp: passengerData.pickupTime, timeFormat: DateUtils.TIME_FORMAT_hhmm_a)!
        }
    }
    
    private func handleInviteStatus() {
        
        if inviteTaxiPoolCellViewModel?.checkInviteIsExist() ?? false {
            inviteView.isHidden = true
            handleCallBtnVisibility()
        }else{
            handleCustomizationToInviteView()
        }
    }
    
    @objc private func tapped(_ sender:UITapGestureRecognizer) {
        guard let matchedPassengerData = inviteTaxiPoolCellViewModel?.matchedPassengerData else{return}
        
        let profile:ProfileDisplayViewController = (UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController)
        profile.initializeDataBeforePresentingView(profileId: StringUtils.getStringFromDouble(decimalNumber: matchedPassengerData.userid!),isRiderProfile: UserRole.Passenger , rideVehicle: nil,userSelectionDelegate: nil,displayAction: true, isFromRideDetailView : false, rideNotes: matchedPassengerData.rideNotes, matchedRiderOnTimeCompliance: matchedPassengerData.userOnTimeComplianceRating, noOfSeats: matchedPassengerData.requiredSeats, isSafeKeeper: matchedPassengerData.hasSafeKeeperBadge)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: profile, animated: false)
    }
    
    private func getSetRating(passengerData: MatchedPassenger) {
        if (passengerData.rating)! > 0.0 {
            ratingLabel.text = String(passengerData.rating!) + "(\(passengerData.noOfReviews))"
        }else{
            ratingLabel.text = ""
        }
    }
    
    private func handleCustomizationToInviteView(){
        inviteView.isHidden = false
        inviteBtn.isHidden = false
        animationImageView.animationImages
            = [UIImage(named: "match_option_invite_progress_1"),UIImage(named: "match_option_invite_progress_2")] as? [UIImage]
        animationImageView.isHidden = true
        animationImageView.animationDuration = 0.3
        animationImageView.tag = inviteTaxiPoolCellViewModel!.row!
    }
    
    @IBAction func inviteBtnPressed(_ sender: UIButton) {
        inviteBtn.isHidden = true
        animationImageView.isHidden = false
        animationImageView.startAnimating()
        invitePassengerTaxiPool()
    }
    
    private func invitePassengerTaxiPool() {
        guard let createInviteData = inviteTaxiPoolCellViewModel?.createInviteObject() else {return}
        
        let taxiPoolInvite = TaxiPoolInvitePasengerHandler(taxiInviteData: createInviteData)
        taxiPoolInvite.invitePassenger { [weak self] (data, error) in
            if data != nil {
                if self?.inviteTaxiPoolCellViewModel?.checkInviteIsExist() ?? false {
                    return
                }
                self?.inviteTaxiPoolCellViewModel?.updateRideInViteCacheAfterInvite(invitationData: data!)
                self?.inviteView.isHidden = true
                self?.handleCallBtnVisibility()
            }else{
                self?.animationImageView.stopAnimating()
                self?.animationImageView.isHidden = true
                self?.inviteBtn.isHidden = false
            }
        }
    }
    
    private func cancelANInvite() {
        guard let inviteId = inviteTaxiPoolCellViewModel?.getTheInviteForCancel() else { return }
        QuickRideProgressSpinner.startSpinner()
        TaxiPoolRestClient.cancelInvite(inviteId: inviteId) { [weak self] (responseObject, error) in
             QuickRideProgressSpinner.stopSpinner()
            if responseObject!["result"] as! String == "SUCCESS"{
                TaxiPoolInvitationCache.getInstance().removeAnInvitationFromLocal(rideId: self?.inviteTaxiPoolCellViewModel?.ride?.rideId ?? 0, invitationId: inviteId)
                TaxiPoolInvitationCache.getInstance().getAllInvitesForRide(rideId: self?.inviteTaxiPoolCellViewModel?.ride?.rideId ?? 0.0) { (data, error) in
                    self?.inviteTaxiPoolCellViewModel?.allInvites?.removeAll()
                    self?.inviteTaxiPoolCellViewModel?.allInvites = data
                }
                self?.handleInviteStatus()
            }else{
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: self?.parentViewController, handler: nil)
            }
        }
    }
    
    @IBAction func callBtnPressed(_ sender: UIButton) {
        if sender.backgroundColor == UIColor(netHex: 0xcad2de) {
            guard let call_disaable_msg = inviteTaxiPoolCellViewModel?.getErrorMessageForCall() else { return }
            UIApplication.shared.keyWindow?.makeToast( call_disaable_msg)
            return
        }
        inviteTaxiPoolCellViewModel?.callTheRespectiveMatchUser()
    }
    
    @IBAction func chatBtnPressed(_ sender: UIButton) {
        guard let userId = inviteTaxiPoolCellViewModel?.matchedPassengerData?.userid else { return }
        let chatViewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatViewController.initializeDataBeforePresentingView(ride: inviteTaxiPoolCellViewModel?.ride, userId: userId, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: parentViewController, viewControllerToBeDisplayed: chatViewController, animated: false)
    }
    
    @IBAction func moreOptionBtnPressed(_ sender: UIButton) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.remind, style: .default) { action -> Void in
            self.invitePassengerTaxiPool()
        }
        let secondAction: UIAlertAction = UIAlertAction(title: Strings.cancel_invite, style: .default) { action -> Void in
            self.cancelANInvite()
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(secondAction)
        actionSheetController.addAction(cancelAction)
        parentViewController?.present(actionSheetController, animated: true)
    }
    
    private func handleCallBtnVisibility() {
        inviteStatusImageView.image =  UIImage(named: "request_sent")
        inviteStatusLabel.text = Strings.request_sent
        contactOptionView.isHidden = false
        if UserProfile.SUPPORT_CALL_ALWAYS == inviteTaxiPoolCellViewModel?.matchedPassengerData?.callSupport && inviteTaxiPoolCellViewModel?.matchedPassengerData?.enableChatAndCall ?? false {
            enableCallOption(status: true)
        }else if inviteTaxiPoolCellViewModel?.matchedPassengerData?.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED && inviteTaxiPoolCellViewModel?.matchedPassengerData?.enableChatAndCall ?? false {
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: inviteTaxiPoolCellViewModel?.matchedPassengerData?.userid))
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
}
