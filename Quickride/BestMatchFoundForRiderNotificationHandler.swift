//
//  BestMatchFoundForRiderNotificationHandler.swift
//  Quickride
//
//  Created by QR Mac 1 on 16/04/21.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class BestMatchFoundForRiderNotificationHandler:  NotificationHandler{
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
        return Strings.VIEW_TO_JOIN
    }
    
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        AppDelegate.getAppDelegate().log.debug("getNegativeActionNameWhenApplicable()")
        return Strings.unsubscribe
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?){
        var ride: Ride?
        if let rideIdString = userNotification.groupValue,let rideId = Double(rideIdString){
            ride = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideId)
        }
        guard let rideObj = ride else { return }
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        let bestMatchAlertNotification = Mapper<BestMatchAlertNotification>().map(JSONString: msgObjectJson)
        if let notification = bestMatchAlertNotification,let rideId = Double(notification.rideId ?? ""){
            QuickRideProgressSpinner.startSpinner()
            RouteMatcherServiceClient.getMatchingPassenger(passengerRideId: rideId, riderRideId: rideObj.rideId, targetViewController: viewController,complitionHandler: { (responseObject, error) -> Void in
                QuickRideProgressSpinner.stopSpinner()
                if let responseObject = responseObject, responseObject["result"] as? String == "SUCCESS", let resultData = responseObject["resultData"] {
                    if let matchedPassenger = Mapper<MatchedPassenger>().map(JSONObject: resultData){
                        self.moveToRideDetailView(ride: rideObj, matchedUser: matchedPassenger,viewController: viewController)
                    }
                }
            })
        }
    }
    
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?){
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        let bestMatchAlertNotification = Mapper<BestMatchAlertNotification>().map(JSONString: msgObjectJson)
        if let notification = bestMatchAlertNotification{
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.updateBestMatchAlertStatus(rideMatchAlertId: notification.rideMatchAlertId ?? "",userId: UserDataCache.getInstance()?.userId ?? "", status: RideMatchAlertRegistration.INACTIVE){(responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    super.handleNegativeAction(userNotification: userNotification, viewController: viewController)
                    UIApplication.shared.keyWindow?.makeToast("Best match alert unsubscribed")
                    if let rideMatchAlertRegistration = Mapper<RideMatchAlertRegistration>().map(JSONObject:responseObject!["resultData"]){
                        SharedPreferenceHelper.storeBestMatchAlertActivetdRides(routeId: Double(rideMatchAlertRegistration.routeId), rideMatchAlertRegistration: rideMatchAlertRegistration)
                    }
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: ViewControllerUtils.getCenterViewController(), handler: nil)
                }
            }
        }
    }
        
    func moveToRideDetailView(ride: Ride,matchedUser: MatchedUser,viewController: UIViewController?) {
        let mainContentVC = UIStoryboard(name: StoryBoardIdentifiers.ridedetails_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RideDetailedMapViewController") as! RideDetailedMapViewController
        mainContentVC.initializeData(ride: ride, matchedUserList: [matchedUser], viewType: DetailViewType.RideDetailView, selectedIndex: 0, startAndEndChangeRequired: false, selectedUserDelegate: nil)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
}
