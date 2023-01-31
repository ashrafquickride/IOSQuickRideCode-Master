//
//  RideTrackingEnableNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 23/11/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideTrackingEnableNotificationHandler: NotificationHandler {
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
       return handler(false)
            
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        guard let riderRideIdString = userNotification.msgObjectJson, let riderRideId = Double(riderRideIdString), riderRideId == 0 else {
            return
        }
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: riderRideId, rideObj: nil, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        if let userDataCache = UserDataCache.getInstance(){
            let notificationSettings = userDataCache.getLoggedInUserNotificationSettings()
            notificationSettings.locationUpdateSuggestions = false
            let params : [String : String] = notificationSettings.getParams()
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.updateUserUserNotificationSetting(targetViewController: nil, params: params) { (responseObject, error) -> Void in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
                    let userDataCache = UserDataCache.getInstance()
                    if(userDataCache != nil)
                    {
                        userDataCache!.storeUserUserNotificationSetting(userId: QRSessionManager.getInstance()!.getUserId(),notificationSettings: notificationSettings)
                    }
                }else {
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: nil, handler: nil)
                }
            }
        }
    }
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.dont_remind
    }
}
