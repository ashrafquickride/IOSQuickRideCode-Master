//
//  EndorsementRequestNotificationHandler.swift
//  Quickride
//
//  Created by Vinutha on 09/09/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class EndorsementRequestNotificationHandler: NotificationHandler {
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        if let notificationData = getEndorsementRequestNotificationData(userNotification: userNotification) {
            getUserProfileAndMoveToRespectiveView(notificationData: notificationData, userNotification: userNotification, viewController: viewController)
        }
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        if let endorsementRequestNotificationData = getEndorsementRequestNotificationData(userNotification: userNotification) {
            let endorseCofirmationViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EndorseCofirmationViewController") as! EndorseCofirmationViewController
            endorseCofirmationViewController.initializeData(endorsementRequestNotiifcationData: endorsementRequestNotificationData, notication: userNotification, handler: { (action) in
            })
            ViewControllerUtils.addSubView(viewControllerToDisplay: endorseCofirmationViewController)
        }
    }
    
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {
        if let endorsementRequestNotificationData = getEndorsementRequestNotificationData(userNotification: userNotification) {
            let refundRejectReasonsViewController = UIStoryboard(name: StoryBoardIdentifiers.payment_storyboard,bundle: nil).instantiateViewController(withIdentifier: "RefundRejectReasonsViewController") as! RefundRejectReasonsViewController
            refundRejectReasonsViewController.initializeReasons(reasons: Strings.endorsement_reject_reason, actionName: Strings.decline_action_caps) { (rejectReason) in
                
                self.rejectEndorsementRequest(endorsementRequestNotificationData: endorsementRequestNotificationData, userNotification: userNotification, rejectReason: rejectReason!, viewController: viewController)
            }
                
            ViewControllerUtils.addSubView(viewControllerToDisplay: refundRejectReasonsViewController)
        }
    }
    
    private func getEndorsementRequestNotificationData(userNotification: UserNotification) -> EndorsementRequestNotificationData? {
        if let msgObjectJson = userNotification.msgObjectJson {
            return Mapper<EndorsementRequestNotificationData>().map(JSONString: msgObjectJson)
        }
        return nil
    }
    
    private func getUserProfileAndMoveToRespectiveView(notificationData: EndorsementRequestNotificationData, userNotification: UserNotification, viewController: UIViewController?) {
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.getUserProfile(userId: notificationData.userId) { (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil {
                if let userProfile = Mapper<UserProfile>().map(JSONObject: responseObject!["resultData"]) {
                    self.moveToEndorsementRequestView(notificationData: notificationData, userProfile: userProfile, userNotification: userNotification, viewController: viewController)
                }
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
            }
        }
    }
    
    private func moveToEndorsementRequestView(notificationData: EndorsementRequestNotificationData, userProfile: UserProfile, userNotification: UserNotification, viewController: UIViewController?) {
        let endorsementRequestViewController = UIStoryboard(name: StoryBoardIdentifiers.verifcation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "EndorsementRequestViewController") as! EndorsementRequestViewController
        endorsementRequestViewController.initializeData(userProfile: userProfile, endorsementRequestNotificationData: notificationData, notication: userNotification)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: endorsementRequestViewController, animated: false)
    }
    
    private func rejectEndorsementRequest(endorsementRequestNotificationData: EndorsementRequestNotificationData, userNotification: UserNotification, rejectReason: String?, viewController: UIViewController?) {
        QuickRideProgressSpinner.startSpinner()
        ProfileVerificationRestClient.rejectEndorsementRequest(userId: QRSessionManager.getInstance()?.getUserId() ?? "0", requestorUserId: endorsementRequestNotificationData.userId ?? "0", rejectReason: rejectReason ?? ""){ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                UIApplication.shared.keyWindow?.makeToast( "Endorsement Rejected")
                NotificationStore.getInstance().removeNotificationFromLocalList(userNotification: userNotification)
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
            }
        }
    }
    
    override func getNegativeActionNameWhenApplicable(userNotification : UserNotification) -> String? {
        return Strings.REJECT
    }
    override func getPositiveActionNameWhenApplicable(userNotification : UserNotification) -> String? {
        return Strings.endorse_now_action
    }
    
    override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return nil
    }
    
}
