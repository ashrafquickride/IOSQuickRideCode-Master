//
//  CommunicationUtils.swift
//  Quickride
//
//  Created by KNM Rao on 05/09/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

protocol CommunicationUtilsListener
{
    func removeSuperView()
}

class CommunicationUtils {
    
    var userBasicInfo : UserBasicInfo
    var viewController : UIViewController
    var isRidePartner = false
    var delegate : CommunicationUtilsListener?
    var isRideStarted = false
    private var ride: Ride?
    
    init(ride: Ride?,userBasicInfo : UserBasicInfo,isRideStarted : Bool,viewController : UIViewController, delegate : CommunicationUtilsListener){
        self.userBasicInfo = userBasicInfo
        self.viewController = viewController
        self.delegate = delegate
        self.isRideStarted = isRideStarted
        self.ride = ride
    }
    func checkAndNavigateToContactViewController(){
        
        let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber : self.userBasicInfo.userId))
        if contact != nil && contact!.contactType == Contact.RIDE_PARTNER{
            self.isRidePartner = true
        }
        if CommunicationUtils.checkAndEnableCallOption(callSupport: userBasicInfo.callSupport, isRidePartner: isRidePartner) == false{
            moveToChatView()
        }
        else{
            self.navigateToContactView()
        }
    }
    
    static func checkAndEnableCallOption(callSupport : String, isRidePartner: Bool) -> Bool
    {
        
        if(UserProfile.SUPPORT_CALL_NEVER == callSupport)
        {
            return false
        }
        else if(UserProfile.SUPPORT_CALL_ALWAYS == callSupport)
        {
            return true
        }
        else{
            if isRidePartner == true
            {
                return true
            }
            else
            {
                return false
            }
        }
    }
    
    
    func navigateToContactView(){
        let contactViewController = UIStoryboard(name: "Common", bundle: nil).instantiateViewController(withIdentifier: "ContactOptionsDialouge") as! ContactOptionsDialouge
        contactViewController.initializeDataBeforePresentingView(ride: ride, presentConatctUserBasicInfo: userBasicInfo,supportCall: CommunicationType.Call, delegate: self.delegate, isRideStarted: isRideStarted, dismissDelegate: nil)
        ViewControllerUtils.addSubView(viewControllerToDisplay: contactViewController)
    }
    func moveToChatView(){
        
        let viewController = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
        viewController.initializeDataBeforePresentingView(ride: nil, userId : userBasicInfo.userId ?? 0, isRideStarted: isRideStarted, listener: nil)
        ViewControllerUtils.displayViewController(currentViewController: self.viewController, viewControllerToBeDisplayed: viewController, animated: false)
    }
}
