//
//  EndorsementRequestViewModel.swift
//  Quickride
//
//  Created by Vinutha on 08/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit

class EndorsementRequestViewModel {
    
    //MARK: Properties
    var listOfRides = [String]()
    var userProfile = UserProfile()
    var endorsementRequestNotificationData = EndorsementRequestNotificationData()
    var notication: UserNotification?
    
    //MARK: Initializer
    func initializeData(userProfile: UserProfile, endorsementRequestNotificationData: EndorsementRequestNotificationData, notication: UserNotification) {
        self.userProfile = userProfile
        self.endorsementRequestNotificationData = endorsementRequestNotificationData
        self.notication = notication
    }
    
    //MARK: Methods
    func rejectEndorsementRequest(rejectReason: String?, viewController: UIViewController?) {
        QuickRideProgressSpinner.startSpinner()
        ProfileVerificationRestClient.rejectEndorsementRequest(userId: QRSessionManager.getInstance()?.getUserId() ?? "0", requestorUserId: endorsementRequestNotificationData.userId ?? "0", rejectReason: rejectReason ?? ""){ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UIApplication.shared.keyWindow?.makeToast( "Endorsement Rejected")
                NotificationCenter.default.post(name: .endorsementRequestRejected, object: nil)
                NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: self.notication!)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    
    func getErrorMessageForChat() -> String?{
        if UserDataCache.getInstance()?.getLoggedInUserProfile()?.verificationStatus == 0 && endorsementRequestNotificationData.allowChatAndCallFromUnverifiedUsers == "false" {
            return Strings.chat_and_call_disable_msg
        }
        return nil
    }
    
    func getErrorMessageForCall() -> String?{
        if userProfile.verificationStatus == 0 && endorsementRequestNotificationData.allowChatAndCallFromUnverifiedUsers == "false" {
            return Strings.chat_and_call_disable_msg
        } else if let supportCall = endorsementRequestNotificationData.allowCallsFrom, supportCall == UserProfile.SUPPORT_CALL_AFTER_JOINED {
            let contact = UserDataCache.getInstance()?.getRidePartnerContact(contactId: StringUtils.getStringFromDouble(decimalNumber: userProfile.userId))
            if (contact != nil && contact!.contactType != Contact.RIDE_PARTNER) && !RideValidationUtils.checkUserJoinedInUpCommingRide(userId: userProfile.userId){
                return Strings.call_joined_partner_msg
            }
        } else if let supportCall = endorsementRequestNotificationData.allowCallsFrom, supportCall == UserProfile.SUPPORT_CALL_NEVER{
            return Strings.no_call_please_msg
        }
        return nil
    }
}
