//
//  ConversationContactSelectViewController.swift
//  Quickride
//
//  Created by QuickRideMac on 07/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation


class ConversationContactSelectViewController: ConversationContactBaseViewController,RemoveRidePartnerContactReciever{
    
    var displayToast = true
    private var contactOptionsDialogue : ContactOptionsDialouge?
    private var  modelLessDialogue: ModelLessDialogue?
    
    override func viewDidLoad() {
        AppDelegate.getAppDelegate().log.debug("")
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationContactCell", for: indexPath) as! ConversationContactCell
        if (indexPath.section == 0 && indexPath.row >= recentchatsSearchResutls.count) || (indexPath.section == 1 && indexPath.row >= ridePartnersSearchResults.count){
            return cell
        }
        var contact : Contact?
        if indexPath.section == 0{
          contact  = recentchatsSearchResutls[indexPath.row]
        }else if indexPath.section == 1{
            contact  = ridePartnersSearchResults[indexPath.row]
        }
        else
        {
            return cell
        }
        
        cell.initializeViews(contact: contact!, fromBlockedUsers: moveToContacts)
        cell.contactImage.image = nil
        ImageCache.getInstance().setImageToView(imageView: cell.contactImage, imageUrl: contact!.contactImageURI, gender: contact!.contactGender,imageSize: ImageCache.DIMENTION_TINY)
        cell.callButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ConversationContactSelectViewController.displayMenuOption(_:))))
        cell.contactImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ConversationContactSelectViewController.navigateToProfile(_:))))
        if UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus == 0 && contact != nil && contact!.enableChatAndCall == false{
            self.isCallAndChatEnabled[indexPath.row] = false
        }
        else if  UserDataCache.getInstance()!.getLoggedInUserProfile()?.numberOfRidesAsRider == 0{
            if RideManagementUtils.getUserQualifiedToDisplayContact(){
                self.isCallAndChatEnabled[indexPath.row] = true
            }
            else{
                self.isCallAndChatEnabled[indexPath.row] = false
                if displayToast == true{
                    modelLessDialogue = ModelLessDialogue.loadFromNibNamed(nibNamed: "ModelLessView") as! ModelLessDialogue
                    modelLessDialogue?.initializeViews(message: Strings.no_balance_reacharge_toast, actionText: Strings.link_caps)
                    modelLessDialogue?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(payMentVC(_:))))
                    modelLessDialogue?.isUserInteractionEnabled = true
                    modelLessDialogue?.frame = CGRect(x: 5, y: self.view.frame.size.height/2, width: self.view.frame.width, height: 80)
                    self.view.addSubview(modelLessDialogue!)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.removeModelLessDialogue()
                    }
                    displayToast = false
                }
            }
        }
        else{
            self.isCallAndChatEnabled[indexPath.row] = true
        }
         return cell
    }
    
    private func removeModelLessDialogue() {
        if modelLessDialogue != nil {
            modelLessDialogue?.removeFromSuperview()
        }
    }
    
    @objc private func payMentVC(_ recognizer: UITapGestureRecognizer) {
        removeModelLessDialogue()
        let addFavoriteLocationViewController  = UIStoryboard(name : StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "PaymentViewController") as! PaymentViewController
        self.navigationController?.pushViewController(addFavoriteLocationViewController, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AppDelegate.getAppDelegate().log.debug("\(indexPath)")
        if (indexPath.section == 0 && indexPath.row >= recentchatsSearchResutls.count) || (indexPath.section == 1 && indexPath.row >= ridePartnersSearchResults.count){
            return
        }
        var contact : Contact?
        if indexPath.section == 0{
            contact  = recentchatsSearchResutls[indexPath.row]
        }else if indexPath.section == 1{
            contact  = ridePartnersSearchResults[indexPath.row]
            
        }

        contactNameSearchBar.endEditing(false)
        if moveToContacts == false
        {
            if self.isCallAndChatEnabled[indexPath.row]!{
                moveToChatView(contact: contact!)
            }
        }
        else{
            contactSelectionReceiver?.contactSelected(contact: contact!)
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    @objc func displayMenuOption(_ sender : UITapGestureRecognizer)
    {
        let tapLocation = sender.location(in: self.contactsTableView)
        let indexPath = self.contactsTableView.indexPathForRow(at: tapLocation)
        var UserContact : Contact?
        guard let index = indexPath else { return }
        if index.section == 0{
            UserContact  = recentchatsSearchResutls[index.row]
        }else if index.section == 1{
            UserContact  = ridePartnersSearchResults[index.row]
        }
        guard let contact = UserContact else { return }
        let alertController : RidePartnerContactAlertController =  RidePartnerContactAlertController(viewController: self) { (result) -> Void in
            if result == Strings.remove{
                MessageDisplay.displayErrorAlertWithAction(title: nil, isDismissViewRequired : false, message1: Strings.contactdel_confirm, message2: nil, positiveActnTitle: Strings.no_caps,negativeActionTitle : Strings.yes_caps,linkButtonText: nil, viewController: nil, handler: { (result) in
                    if Strings.yes_caps == result, let contactIdStr = contact.contactId{
                        if let contactId = Double(contactIdStr), let userDatsCache =  UserDataCache.getInstance(), userDatsCache.isFavouritePartner(userId: contactId){
                            RemoveRideParticipantContactTask.removeRidePartner(contactId: contactIdStr, isFavPartner: true, viewController: self, receiver: self)
                        }else{
                            RemoveRideParticipantContactTask.removeRidePartner(contactId: contactIdStr, isFavPartner: false, viewController: self, receiver: self)
                        }
                    }
                })
                
            }
            else if result == Strings.call{
                self.navigateToContactView(contact: contact)
            }
        }
        if (UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus == 0 && contact.enableChatAndCall == false) || contact.supportCall == UserProfile.SUPPORT_CALL_NEVER || (UserDataCache.getInstance()!.getLoggedInUserProfile()?.numberOfRidesAsRider == 0 && !RideManagementUtils.getUserQualifiedToDisplayContact()){
                    alertController.removeAlertAction()
                    alertController.cancelAlertAction()
                    
                    alertController.showAlertController()
        }else{
                    alertController.contactAlertAction()
                    alertController.removeAlertAction()
                    alertController.cancelAlertAction()
                    
                    alertController.showAlertController()
            }
    }
    func navigateToContactView(contact: Contact){
        guard let contactId = contact.contactId else { return }
            AppUtilConnect.callNumber(receiverId: contactId, refId: Strings.contact, name: contact.contactName, targetViewController: self)
    }

    func getUserBasicInfo(contact: Contact) -> (UserBasicInfo,CommunicationType){
        let userBasicInfo = UserBasicInfo(userId: Double(contact.contactId!)!, gender: contact.contactGender, userName: contact.contactName, imageUri: contact.contactImageURI, callSupport: contact.supportCall)
        let supportCall : CommunicationType?
        if UserProfile.SUPPORT_CALL_ALWAYS == userBasicInfo.callSupport{
            supportCall = CommunicationType.Call
        }
        else if UserProfile.SUPPORT_CALL_AFTER_JOINED == userBasicInfo.callSupport{
            supportCall = CommunicationType.Call
        }
        else{
            supportCall = CommunicationType.Chat
        }
        return(userBasicInfo,supportCall!)
    }
    func RidePartnerRemoved() {
        self.refershContacts()
    }

    func moveToChatView(contact: Contact){
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        let userBasicInfoDetails = self.getUserBasicInfo(contact: contact)
        viewController.initializeDataBeforePresentingView(ride: nil, userId: userBasicInfoDetails.0.userId ?? 0, isRideStarted: false, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: self, viewControllerToBeDisplayed: viewController, animated: false)
        if let vc = topViewController, vc.isFromCentralChat{
            self.navigationController?.viewControllers.remove(at: (self.navigationController?.viewControllers.count ?? 0) - 2)
        }
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc func navigateToProfile(_ sender : UITapGestureRecognizer)
    {
        let tapLocation = sender.location(in: self.contactsTableView)
        let indexPath = self.contactsTableView.indexPathForRow(at: tapLocation)
        var contact : Contact?
        
        if indexPath!.section == 0{
            contact  = recentchatsSearchResutls[indexPath!.row]
        }else if indexPath!.section == 1{
            contact  = ridePartnersSearchResults[indexPath!.row]
        }
        let profileDisplayViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ProfileDisplayViewController") as! ProfileDisplayViewController
        profileDisplayViewController.initializeDataBeforePresentingView(profileId: contact!.contactId!,isRiderProfile: RideManagementUtils.getUserRoleBasedOnRide(),rideVehicle : nil, userSelectionDelegate: nil, displayAction: false, isFromRideDetailView : false, rideNotes: nil, matchedRiderOnTimeCompliance: nil, noOfSeats: nil, isSafeKeeper: false)
        self.navigationController?.pushViewController(profileDisplayViewController, animated: false)
    }
    
}
