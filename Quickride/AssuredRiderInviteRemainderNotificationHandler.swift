//
//  AssuredRiderInviteRemainderNotificationHandler.swift
//  Quickride
//
//  Created by Admin on 25/07/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class AssuredRiderInviteRemainderNotificationHandler : NotificationHandler{
    
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        guard let riderRideId = Double(userNotification.msgObjectJson!) else {
            return
        }
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: riderRideId, rideObj: nil, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
        
    }
    
    
}
