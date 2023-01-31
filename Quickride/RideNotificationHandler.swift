//
//  RideNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class RideNotificationHandler : NotificationHandler{

  func navigateToLiveRideView (riderRideId : Double) {
    AppDelegate.getAppDelegate().log.debug("navigateToLiveRideView() \(riderRideId)")
    let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
    mainContentVC.initializeDataBeforePresenting(riderRideId: riderRideId, rideObj: nil, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
    ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: mainContentVC, animated: true)
  }
    override func getNotiifcationIcon() -> UIImage {
      AppDelegate.getAppDelegate().log.debug("getNotiifcationIcon()")
        return UIImage(named: "notification_car")!
    }

}

