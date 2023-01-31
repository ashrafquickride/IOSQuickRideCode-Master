//
//  RideRescheduleSuggestionNotificationHandler.swift
//  Quickride
//
//  Created by iDisha on 14/06/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RideRescheduleSuggestionNotificationHandler: NotificationHandler {
    
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {
        if let userDataCache = UserDataCache.getInstance(){
            let notificationSettings = userDataCache.getLoggedInUserNotificationSettings()
            notificationSettings.rideRescheduleSuggestions = false
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
    
    func navigateToLiveRideView (ride : Ride) {
        AppDelegate.getAppDelegate().log.debug("navigateToLiveRideView()")
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.dont_remind
    }
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.reschedule
    }
}
