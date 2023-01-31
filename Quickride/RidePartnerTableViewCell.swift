//
//  RidePartnerTableViewCell.swift
//  Quickride
//
//  Created by Vinutha on 03/08/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class RidePartnerTableViewCell: UITableViewCell {
    
    //MARK: Outlets
    @IBOutlet weak var contactNameLabel: UILabel!
    @IBOutlet weak var contactCompanyNameLabel: UILabel!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var favouriteImage: UIImageView!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var callChatView: UIView!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    
    private var viewController: UIViewController?
    private var contact: Contact?
    private var rideType: String?
    private var rideInvitation: RideInvitation?
    
    func initializeRidePartner(contact: Contact,rideId : Double,rideType: String,viewController: UIViewController){
        self.contact = contact
        self.rideType = rideType
        self.viewController = viewController
        contactNameLabel.text = contact.contactName
        contactCompanyNameLabel.text = contact.companyName
        ImageCache.getInstance().setImageToView(imageView: contactImage, imageUrl: contact.contactImageURI, gender: contact.contactGender,imageSize: ImageCache.DIMENTION_TINY)
        let allInvitedRides = RideInviteCache.getInstance().getInvitationsForRide(rideId: rideId, rideType: rideType)
        var inviteSent = false
        for invite in allInvitedRides{
            if rideType == Ride.RIDER_RIDE && contact.contactId == StringUtils.getStringFromDouble(decimalNumber: invite.passengerId){
                inviteSent = true
                rideInvitation = invite
                break
            }else if rideType == Ride.PASSENGER_RIDE && contact.contactId == StringUtils.getStringFromDouble(decimalNumber: invite.riderId){
                inviteSent = true
                rideInvitation = invite
                break
            }
        }
        if inviteSent{
            inviteButton.isHidden = true
            callChatView.isHidden = false
            checkCallChatOptionAvailability(contact: contact)
        }else{
            inviteButton.isHidden = false
            callChatView.isHidden = true
        }

        if UserDataCache.getInstance()?.isFavouritePartner(userId: Double(contact.contactId ?? "") ?? 0) == true{
            favouriteImage.isHidden = false
        }else{
            favouriteImage.isHidden = true
        }
    }
    
    private func checkCallChatOptionAvailability(contact: Contact){
        if contact.enableChatAndCall{
            if contact.supportCall != UserProfile.SUPPORT_CALL_NEVER{
                callButton.backgroundColor = UIColor(netHex: 0x2196f3)
            }else{
                callButton.backgroundColor = UIColor(netHex: 0xcad2de)
            }
            chatButton.backgroundColor = UIColor(netHex: 0x19ac4a)
        }else{
            callButton.backgroundColor = UIColor(netHex: 0xcad2de)
            chatButton.backgroundColor = UIColor(netHex: 0xcad2de)
        }
    }
    
    private func cancelSelectedUser(invitation: RideInvitation,viewController: UIViewController){
        RideMatcherServiceClient.updateRideInvitationStatus(invitationId: invitation.rideInvitationId, invitationStatus: RideInvitation.RIDE_INVITATION_STATUS_CANCELLED, viewController: viewController) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS"{
                UIApplication.shared.keyWindow?.makeToast(Strings.invite_cancelled_toast, point: CGPoint(x: viewController.view.frame.size.width/2, y: viewController.view.frame.size.height-200), title: nil, image: nil, completion: nil)
                invitation.invitationStatus = RideInvitation.RIDE_INVITATION_STATUS_CANCELLED
                let rideInvitationStatus = RideInviteStatus(rideInvitation: invitation)
                RideInviteCache.getInstance().updateRideInviteStatus(invitationStatus: rideInvitationStatus)
                NotificationCenter.default.post(name: .cancelRideInvitationSuccess,  object: nil, userInfo: nil)
            }else{
                var userInfo = [String: Any]()
                userInfo["responseObject"] = responseObject
                userInfo["error"] = error
                NotificationCenter.default.post(name: .cancelRideInvitationFailed, object: nil, userInfo: userInfo)
            }
        }
    }
    
    @IBAction func inviteButtonTapped(_ sender: UIButton) {
        var userInfo = [String : Any]()
        userInfo["index"] = sender.tag
        NotificationCenter.default.post(name: .inviteRidePartnerContactTapped, object: nil, userInfo: userInfo)
    }
    
    @IBAction func callButtonTapped(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("callButtonClicked()")
        if let callDisableMsg = getErrorMessageForCall(){
            UIApplication.shared.keyWindow?.makeToast( callDisableMsg)
            return
        }
        AppUtilConnect.callNumber(receiverId: contact?.contactId ?? "", refId: Strings.profile,  name: contact?.contactName ?? "", targetViewController: viewController!)
    }
    
    func getErrorMessageForCall() -> String?{
        if contact?.enableChatAndCall == false{
            return Strings.chat_and_call_disable_msg
        }else if contact?.enableChatAndCall == true && contact?.supportCall == UserProfile.SUPPORT_CALL_NEVER{
            return Strings.no_call_please_msg
        }else if (rideType == Ride.RIDER_RIDE || rideType == Ride.REGULAR_RIDER_RIDE) && !RideManagementUtils.getUserQualifiedToDisplayContact(){
            return Strings.link_wallet_for_call_msg
        }else{
            return nil
        }
    }
    
    
    @IBAction func chatButtonTapped(_ sender: UIButton) {
        AppDelegate.getAppDelegate().log.debug("chatButtonClicked()")
        if let chatDisableMsg = getErrorMessageForChat(){
            UIApplication.shared.keyWindow?.makeToast( chatDisableMsg )
            return
        }
        let chatConversationDialogue = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        chatConversationDialogue.initializeDataBeforePresentingView(ride: nil, userId: Double(contact?.contactId ?? "") ?? 0, isRideStarted: false, listener: nil)
        viewController?.navigationController?.pushViewController(chatConversationDialogue, animated: true)
    }
    
    func getErrorMessageForChat() -> String?{
        if contact?.enableChatAndCall == false{
            return Strings.chat_and_call_disable_msg
        }else if (rideType == Ride.RIDER_RIDE || rideType == Ride.REGULAR_RIDER_RIDE) && !RideManagementUtils.getUserQualifiedToDisplayContact() {
            return Strings.link_wallet_for_call_msg
        }
        return nil
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let firstAction: UIAlertAction = UIAlertAction(title: Strings.remind, style: .default) { action -> Void in
            var userInfo = [String : Any]()
            userInfo["index"] = sender.tag
            NotificationCenter.default.post(name: .inviteRidePartnerContactTapped, object: nil, userInfo: userInfo)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: Strings.cancel_invite, style: .default) { action -> Void in
            if let rideInvitation = self.rideInvitation, let viewController = self.viewController {
                self.cancelSelectedUser(invitation: rideInvitation, viewController: viewController)
            }
        }
        let removeUIAlertAction = UIAlertAction(title: Strings.cancel, style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(removeUIAlertAction)
        viewController?.present(actionSheetController, animated: true)
    }
}
