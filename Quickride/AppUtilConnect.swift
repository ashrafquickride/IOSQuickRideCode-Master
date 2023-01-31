//
//  AppUtilConnect.swift
//  Quickride
//
//  Created by Swagat Kumar Bisoyi on 11/16/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UIKit
import MessageUI
import ObjectMapper

class AppUtilConnect: NSObject{
    
    // Call
    class func callNumber(receiverId : String, refId: String?,name: String,targetViewController : UIViewController) {
        AppDelegate.getAppDelegate().log.debug("")
        guard let userId = QRSessionManager.getInstance()?.getUserId() else { return  }
        if UserDataCache.getInstance()?.getUserRecentRideType() == Ride.RIDER_RIDE{
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.RIDER_CONTACT_INITIATED, params: ["userId": userId,"contactInitiatedWithUserId": receiverId], uniqueField: User.FLD_USER_ID)
        }else{
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.PASSENGER_CONTACT_INITIATED, params: ["userId": userId,"contactInitiatedWithUserId": receiverId,"androidVersion" : "0.0","iosVersion" : AppConfiguration.APP_CURRENT_VERSION_NO], uniqueField: User.FLD_USER_ID)
        }
        UserRestClient.saveCallLog(fromUserId: QRSessionManager.getInstance()?.getUserId(), toUserId: receiverId, refId: refId, viewController: targetViewController) { (responseObject, error) in }
        if let appStartUpData = SharedPreferenceHelper.getAppStartUpData(),appStartUpData.enableNumberMasking{
            showCallOptionPopUp(name: name,receiverId : receiverId,viewcontroller: targetViewController)
        }else{
            getPhoneNumberAndCall(receiverId: receiverId, targetViewController: targetViewController)
        }
        
    }
    class func callTaxiDriver(receiverId : String, refId: String?,name: String,targetViewController : UIViewController) {
        AppDelegate.getAppDelegate().log.debug("")
        guard let userId = QRSessionManager.getInstance()?.getUserId() else { return  }
        if UserDataCache.getInstance()?.getUserRecentRideType() == Ride.RIDER_RIDE{
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.RIDER_CONTACT_INITIATED, params: ["userId": userId,"contactInitiatedWithDriverId": receiverId], uniqueField: User.FLD_USER_ID)
        }else{
            AnalyticsUtils.getInstance().triggerEvent(eventType: AnalyticsConstants.PASSENGER_CONTACT_INITIATED, params: ["userId": userId,"contactInitiatedWithDriverId": receiverId,"androidVersion" : "0.0","iosVersion" : AppConfiguration.APP_CURRENT_VERSION_NO], uniqueField: User.FLD_USER_ID)
        }
        UserRestClient.saveCallLog(fromUserId: QRSessionManager.getInstance()?.getUserId(), toUserId: receiverId, refId: refId, viewController: targetViewController) { (responseObject, error) in }
        guard let securityPreference =  UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences() else { return }
        if securityPreference.numSafeguard == nil || securityPreference.numSafeguard == SecurityPreferences.SAFEGAURD_STATUS_DEFAULT {
            let callOptionPopVC = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ShowCallOptionsViewController") as! ShowCallOptionsViewController
            callOptionPopVC.initialiseData(name: name) { (result) in
                self.getVirtualNumberAndCall(receiverId: receiverId,callerSourceApp: "TAXIPOOL",receiverSourceApp: "TAXI", targetViewController: targetViewController)
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: callOptionPopVC)
        } else {
            self.getVirtualNumberAndCall(receiverId: receiverId,callerSourceApp: "TAXIPOOL",receiverSourceApp: "TAXI", targetViewController: targetViewController)        }
        
    }
    
    class func showCallOptionPopUp(name: String,receiverId : String,viewcontroller: UIViewController) {
        guard let securityPreference =  UserDataCache.getInstance()?.getLoggedInUsersSecurityPreferences() else { return }
        if securityPreference.numSafeguard == nil || securityPreference.numSafeguard == SecurityPreferences.SAFEGAURD_STATUS_DEFAULT {
            let callOptionPopVC = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ShowCallOptionsViewController") as! ShowCallOptionsViewController
            callOptionPopVC.initialiseData(name: name) { (result) in
                getPhoneNumberAndCall(receiverId : receiverId,targetViewController : viewcontroller)
            }
            ViewControllerUtils.addSubView(viewControllerToDisplay: callOptionPopVC)
        } else {
            self.getPhoneNumberAndCall(receiverId: receiverId, targetViewController: viewcontroller)
        }
    }
    
    class func dialNumber(phoneNumber : String,viewController : UIViewController){
        if let phoneCallURL:NSURL = NSURL(string: "tel://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(phoneCallURL as URL)) {
                    application.open(phoneCallURL as URL, options: [:], completionHandler: nil)
            } else {
                MessageDisplay.displayAlert(messageString: Strings.phone_number_is_not_available, viewController: viewController, handler: nil)
            }
        }
    }
    
    class func getPhoneNumberAndCall(receiverId : String,targetViewController : UIViewController){
        if isUserHavingCallCredits(){
            self.getVirtualNumberAndCall(receiverId: receiverId, callerSourceApp: "CARPOOL",receiverSourceApp: "CARPOOL", targetViewController: targetViewController)
        }else {
            
            let callChargeDetails = UIStoryboard(name: StoryBoardIdentifiers.callChargealert_storyboard, bundle: nil).instantiateViewController(withIdentifier: "CallChageViewController") as! CallChageViewController
            callChargeDetails.initializeData(userId: receiverId, handler:{ (action) in
                switch action {
                case .call :
                    AppUtilConnect.getVirtualNumberAndCall(receiverId: receiverId, callerSourceApp: "CARPOOL",receiverSourceApp: "CARPOOL", targetViewController: targetViewController)
                    break
                case .chat:
                    if let userId = Double(receiverId) {
                        let chatConversationDialogue = UIStoryboard(name: StoryBoardIdentifiers.conversation_storyboard, bundle: nil).instantiateViewController(withIdentifier: "ChatConversationDialogue") as! ChatConversationDialogue
                        chatConversationDialogue.initializeDataBeforePresentingView(ride: nil, userId: userId, isRideStarted: false, listener: nil)
                        ViewControllerUtils.displayViewController(currentViewController: targetViewController, viewControllerToBeDisplayed: chatConversationDialogue, animated: false)
                        
                    }
                }
            })
            callChargeDetails.modalPresentationStyle = .overFullScreen
            targetViewController.present(callChargeDetails, animated: true)
        }
    }
    
    class func getVirtualNumberAndCall(receiverId : String, callerSourceApp : String, receiverSourceApp : String, targetViewController : UIViewController){
        QuickRideProgressSpinner.startSpinner()
        UserRestClient.getVirtualNumber(callerId: (QRSessionManager.getInstance()?.getUserId())!,callerSourceApp: callerSourceApp,  receiverId: receiverId,receiverSourceApp : receiverSourceApp, viewController: targetViewController){ (responseObject, error) in
            QuickRideProgressSpinner.stopSpinner()
            if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" && responseObject!["resultData"] != nil{
                if let userContactNoMask = Mapper<UserContactNoMask>().map(JSONObject: responseObject!["resultData"]) {
                    if userContactNoMask.receiverEnabledMasking ?? false {
                         UIApplication.shared.keyWindow?.makeToast( Strings.user_enabled_number_masking)
                    }
                    self.dialNumber(phoneNumber: userContactNoMask.dialNumber!, viewController: targetViewController)
                }
            } else {
                ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
            }
        }
    }
    
    class func isUserHavingCallCredits() -> Bool{
        if let callCreditDetails = UserDataCache.sharedInstance?.callCreditDetails, let clientConfiguration = ConfigurationCache.getInstance()?.getClientConfiguration() {
            if callCreditDetails.callCredits >= clientConfiguration.maximumCreditsRequiredPerCall{
                return true
            }
        }
        return false
    }
    
    class func callSupportNumber(phoneNumber:String, targetViewController : UIViewController) {
        AppDelegate.getAppDelegate().log.debug("")
        self.dialNumber(phoneNumber: phoneNumber, viewController: targetViewController)
    }
    
    // Face time
    class func facetime(phoneNumber:String, targetViewController : UIViewController) {
        AppDelegate.getAppDelegate().log.debug("facetime() \(phoneNumber)")
        if let facetimeURL:NSURL = NSURL(string: "facetime://\(phoneNumber)") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(facetimeURL as URL)) {
                    application.open(facetimeURL as URL, options: [:], completionHandler: nil)
            }else{
                MessageDisplay.displayAlert(messageString: Strings.phone_face_time_is_not_available, viewController: targetViewController, handler: nil)
            }
        }
    }
}

