//
//  MatchedUserRideActionView.swift
//  Quickride
//
//  Created by Rajesab on 14/06/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

protocol RideDetailTableViewCellUserSelectionDelegate : class {
    func cancelSelectedUserPressed(invitation: RideInvitation, status: Int)
    func gotItAction()
    func changePlanAction()
    func displayAckForRideRequest(matchedUser: MatchedUser)
    func updateRideStatusView()
    func declineInviteAction(rideInvitation: RideInvitation?)
    func selectedUserDelegate()
}

class MatchedUserRideActionView: UIView {
    
    @IBOutlet weak var contactOptionShowingView: UIView!
    @IBOutlet weak var callOptionButton: UIButton!
    @IBOutlet weak var chatOptionButton: UIButton!
    @IBOutlet weak var callToInviteOptionButton: UIButton!
    @IBOutlet weak var moreOptionButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var inviteOrOfferRideStackView: UIStackView!
    @IBOutlet weak var rideConfirmActionView: UIView!
    
    //MARK: ReadyToGoAction
    @IBOutlet weak var readyToGoActionView: UIView!
    @IBOutlet weak var ReadyToGoJoinButton: UIButton!
    @IBOutlet weak var callToInviteButton: UIButton!
    
    private var rideDetailViewCellViewModel = RideDetailViewCellViewModel()
    private var viewController: RideDetailedMapViewController?
    private var userSelectionDelegate: RideDetailTableViewCellUserSelectionDelegate?
    
    func initialiseUIWithData(ride: Ride?, matchedUser: MatchedUser, viewController : RideDetailedMapViewController, viewType: DetailViewType, selectedIndex: Int, rideInviteActionCompletionListener: RideInvitationActionCompletionListener?, userSelectionDelegate: RideDetailTableViewCellUserSelectionDelegate?, selectedUserDelegate: SelectedUserDelegate?) {
        rideDetailViewCellViewModel.initialiseUIWithData(ride: ride, matchedUser: matchedUser, viewType: viewType, selectedIndex: selectedIndex, routeMetrics: nil, rideActionCompletionDelegate: self, rideInviteActionCompletionListener : rideInviteActionCompletionListener, selectedUserDelegate: selectedUserDelegate)
        self.viewController = viewController
        self.userSelectionDelegate = userSelectionDelegate
        checkAndSetInvitedLabel()
    }
    
    @IBAction func joinButtonTapped(_ sender: UIButton) {
        if callToInviteButton.backgroundColor == UIColor(netHex: 0xcad2de) {
            rideDetailViewCellViewModel.inviteClicked(matchedUser: rideDetailViewCellViewModel.matchedUser, viewController: viewController, displaySpinner: true)
        } else {
            showCallToJoinDetailsVC(sender: sender)
        }
    }
    
    @IBAction func callToJoinButtonTapped(_ sender: UIButton) {
        rideDetailViewCellViewModel.inviteClicked(matchedUser: rideDetailViewCellViewModel.matchedUser!, viewController: viewController!, displaySpinner: true)
        performCallAction(sender: sender)
    }
    
    @IBAction func callButtonPressed(_ sender: UIButton) {
        performCallAction(sender: sender)
    }
    
    private func showCallToJoinDetailsVC(sender: UIButton) {
        if let matchedRider = rideDetailViewCellViewModel.matchedUser as? MatchedRider {
            if matchedRider.rideStatus == Ride.RIDE_STATUS_STARTED {
                let callToJoinPopVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CallToJoinConfirmationViewController") as! CallToJoinConfirmationViewController
                callToJoinPopVC.initializeViews(rideStatus: matchedRider.rideStatus) { (action) in
                    if action == Strings.call_to_join {
                        self.rideDetailViewCellViewModel.inviteClicked(matchedUser: self.rideDetailViewCellViewModel.matchedUser!, viewController: self.viewController!,displaySpinner: true)
                        self.performCallAction(sender: sender)
                    } else if action == Strings.continue_to_invite {
                        self.rideDetailViewCellViewModel.inviteClicked(matchedUser: self.rideDetailViewCellViewModel.matchedUser!, viewController: self.viewController!, displaySpinner: true)
                    }
                }
                ViewControllerUtils.addSubView(viewControllerToDisplay: callToJoinPopVC)
            } else {
                rideDetailViewCellViewModel.inviteClicked(matchedUser: rideDetailViewCellViewModel.matchedUser, viewController: viewController, displaySpinner: true)
            }
        }
    }
    
    private func performCallAction(sender: UIButton) {
        if sender.backgroundColor == UIColor(netHex: 0xcad2de) {
            UIApplication.shared.keyWindow?.makeToast( Strings.call_disable_msg)
            return
        }
        guard let matchedUser = rideDetailViewCellViewModel.matchedUser,let ride = rideDetailViewCellViewModel.ride, let rideType = ride.rideType else { return }
        let refID = rideType+StringUtils.getStringFromDouble(decimalNumber: ride.rideId)
        AppUtilConnect.callNumber(receiverId: StringUtils.getStringFromDouble(decimalNumber: matchedUser.userid), refId: refID, name: matchedUser.name ?? "", targetViewController: ViewControllerUtils.getCenterViewController())
    }
    
    @IBAction func chatOptionPressed(_ sender: UIButton) {
        guard let matchedUser = rideDetailViewCellViewModel.matchedUser, let userId = matchedUser.userid else { return }
        let chatConversationDialogue = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatConversationDialogue.initializeDataBeforePresentingView(ride: rideDetailViewCellViewModel.ride, userId: userId, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: chatConversationDialogue, animated: false)
    }
    
    @IBAction func moreOptionPressed(_ sender: UIButton) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.remind, style: .default) { action -> Void in
            self.inviteClicked()
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
    
    @IBAction func gotItButtonTapped(_ sender: UIButton) {
        userSelectionDelegate?.gotItAction()
    }
    
    @IBAction func changePlanButtonTapped(_ sender: UIButton) {
        userSelectionDelegate?.changePlanAction()
    }
    
    @IBAction func inviteOrOfferRideBtnPressed(_ sender: UIButton) {
        if rideDetailViewCellViewModel.selectedUserDelegate != nil {
            userSelectionDelegate?.selectedUserDelegate()
        } else {
            inviteClicked()
        }
    }
    
    private func inviteClicked() {
        rideDetailViewCellViewModel.inviteClicked(matchedUser: rideDetailViewCellViewModel.matchedUser!, viewController: viewController!, displaySpinner: true)
    }
    
    @IBAction func declineButtontapped(_ sender: UIButton) {
        userSelectionDelegate?.declineInviteAction(rideInvitation: rideDetailViewCellViewModel.rideInvitation)
    }
}
extension MatchedUserRideActionView: RideActionCompletionDelegate {
    func displayAckForRideRequest(matchedUser: MatchedUser) {
        userSelectionDelegate?.displayAckForRideRequest(matchedUser: matchedUser)
    }
    
    func stopAnimatingProgressView(matchedUser: MatchedUser?) {
        if matchedUser?.userid != rideDetailViewCellViewModel.matchedUser?.userid {
            return
        }
        if self.viewController != nil{
            viewController?.showRideActionButtonsView()
        }
        QuickRideProgressSpinner.stopSpinner()
    }
}
//MARK: inviteButton Title show hide
extension MatchedUserRideActionView {
    private func checkAndSetInvitedLabel() {
        if rideDetailViewCellViewModel.viewType == DetailViewType.RideConfirmView || rideDetailViewCellViewModel.viewType == DetailViewType.PaymentPendingView {
            rideConfirmActionView.isHidden = false
            inviteOrOfferRideStackView.isHidden = true
            contactOptionShowingView.isHidden = true
            readyToGoActionView.isHidden = true
        } else {
            rideConfirmActionView.isHidden = true
            setTitleToInviteBtn()
            if rideDetailViewCellViewModel.ride?.rideId == nil || rideDetailViewCellViewModel.ride?.rideId.isZero == true {
                joinButton.isHidden = false
                declineButton.isHidden = true
                checkContactVisibility()
                contactOptionShowingView.isHidden = true
                if rideDetailViewCellViewModel.matchedUser!.isReadyToGo {
                    inviteOrOfferRideStackView.isHidden = true
                    readyToGoActionView.isHidden = false
                } else {
                    inviteOrOfferRideStackView.isHidden = false
                    readyToGoActionView.isHidden = true
                }
                return
            }
            if rideDetailViewCellViewModel.ride?.rideId == nil || rideDetailViewCellViewModel.ride?.rideId.isZero == true || rideDetailViewCellViewModel.ride?.rideType == nil {
                return
            }
            let invite = RideInviteCache.getInstance().getAnyInvitationSentByMatchedUserForTheRide(rideId: rideDetailViewCellViewModel.ride!.rideId, rideType: rideDetailViewCellViewModel.ride!.rideType!, matchedUserRideId: rideDetailViewCellViewModel.matchedUser!.rideid!, matchedUserTaxiRideId: (rideDetailViewCellViewModel.matchedUser as? MatchedPassenger)?.passengerTaxiRideId)
            if invite != nil && invite?.invitingUserId !=  UserDataCache.getCurrentUserId() {
                rideDetailViewCellViewModel.rideInvitation = invite
                joinButton.setTitle(Strings.ACCEPT_CAPS, for: .normal)
                declineButton.isHidden = false
                joinButton.isHidden = false
                contactOptionShowingView.isHidden = true
                inviteOrOfferRideStackView.isHidden = false
                readyToGoActionView.isHidden = true
            }else if Ride.RIDER_RIDE == rideDetailViewCellViewModel.ride?.rideType{
                handleVisibilityOfInviteElementsBasedOnInvite(riderRideId: rideDetailViewCellViewModel.ride!.rideId, passengerRideId: rideDetailViewCellViewModel.matchedUser!.rideid!)
            }else{
                handleVisibilityOfInviteElementsBasedOnInvite(riderRideId: rideDetailViewCellViewModel.matchedUser!.rideid!, passengerRideId: rideDetailViewCellViewModel.ride!.rideId)
            }
        }
    }
    private func setTitleToInviteBtn() {
        if Ride.RIDER_RIDE == rideDetailViewCellViewModel.ride?.rideType{
            joinButton.setTitle(Strings.OFFER_RIDE_CAPS, for: .normal)
            ReadyToGoJoinButton.setTitle(Strings.OFFER_RIDE_CAPS, for: .normal)
        }else{
            joinButton.setTitle(Strings.JOIN_CAPS, for: .normal)
            ReadyToGoJoinButton.setTitle(Strings.JOIN_CAPS, for: .normal)
        }
    }
    
    private func handleVisibilityOfInviteElementsBasedOnInvite(riderRideId : Double,passengerRideId : Double) {
        if let _ =  RideInviteCache.getInstance().getOutGoingInvitationPresentBetweenRide(riderRideId: riderRideId, passengerRideId: passengerRideId, rideType: rideDetailViewCellViewModel.ride!.rideType!,userId: rideDetailViewCellViewModel.matchedUser!.userid!){
            joinButton.isHidden = true
            declineButton.isHidden = true
            inviteOrOfferRideStackView.isHidden = true
            handleCallBtnVisibility()
        }else{
            joinButton.isHidden = false
            declineButton.isHidden = true
            checkContactVisibility()
            contactOptionShowingView.isHidden = true
            if rideDetailViewCellViewModel.matchedUser!.isReadyToGo {
                inviteOrOfferRideStackView.isHidden = true
                readyToGoActionView.isHidden = false
            } else {
                inviteOrOfferRideStackView.isHidden = false
                readyToGoActionView.isHidden = true
            }
        }
    }
    
    private func handleCallBtnVisibility() {
        contactOptionShowingView.isHidden = false
        readyToGoActionView.isHidden = true
        if rideDetailViewCellViewModel.matchedUser!.isReadyToGo  {
            callToInviteOptionButton.isHidden = false
            callOptionButton.isHidden = true
            chatOptionButton.isHidden = true
        } else {
            callToInviteOptionButton.isHidden = true
            callOptionButton.isHidden = false
            chatOptionButton.isHidden = false
        }
        checkContactVisibility()
    }
    
    private func checkContactVisibility() {
        if UserProfile.SUPPORT_CALL_ALWAYS == rideDetailViewCellViewModel.matchedUser!.callSupport && rideDetailViewCellViewModel.matchedUser!.enableChatAndCall {
            enableCallOption(status: true)
        }else if rideDetailViewCellViewModel.matchedUser!.callSupport == UserProfile.SUPPORT_CALL_AFTER_JOINED && rideDetailViewCellViewModel.matchedUser!.enableChatAndCall {
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: rideDetailViewCellViewModel.matchedUser?.userid))
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
            callOptionButton.backgroundColor = UIColor(netHex: 0x2196F3)
            callToInviteButton.backgroundColor = UIColor(netHex: 0xFCA126)
            callToInviteOptionButton.backgroundColor = UIColor(netHex: 0xFCA126)
        }else{
            callOptionButton.backgroundColor = UIColor(netHex: 0xcad2de)
            callToInviteButton.backgroundColor = UIColor(netHex: 0xcad2de)
            callToInviteOptionButton.backgroundColor = UIColor(netHex: 0xcad2de)
        }
    }
}
