//
//  PassengerRejectedRiderInviteNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PassengerRejectedRiderInviteNotificationHandler : RideNotificationHandler{
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let groupValue = clientNotification.groupValue, !groupValue.isEmpty, let rideId = Double(groupValue),let _ = MyActiveRidesCache.getRidesCacheInstance()?.getRiderRide(rideId: rideId) else {
                return handler(false)
            }
            return handler(true)
        }
        
    }
    override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("handleTap()")
        
        let rideId = userNotification.groupValue
        let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
        if(myActiveRidesCache == nil || rideId == nil || rideId!.isEmpty)
        {
            return
        }
        let ride = myActiveRidesCache!.getRiderRide(rideId: Double(rideId!)!)
        
        if (ride != nil) {
            let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
            mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: true, isFreezeRideRequired: ride!.freezeRide, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
        }
    }

}
