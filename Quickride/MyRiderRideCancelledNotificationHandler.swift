//
//  MyRiderRideCancelledNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class MyRiderRideCancelledNotificationHandler : RideNotificationHandler {
  
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let msgObjectJson = clientNotification.msgObjectJson, !msgObjectJson.isEmpty, let rideId = Double(msgObjectJson) else
            {
                return handler(false)
            }
            if let _ = MyClosedRidesCache.getClosedRidesCacheInstance().getPassengerRide(rideId: rideId){
                return handler(true)
            }else if let _ = MyClosedRidesCache.getClosedRidesCacheInstance().getRiderRide(rideId: rideId){
                return handler(true)
            }
            return handler(false)
        }
        
    }

  override func handlePositiveAction(userNotification:UserNotification, viewController : UIViewController?) {
    AppDelegate.getAppDelegate().log.debug( "\(userNotification)")
    
    super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    
    let myRidesVC = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myRidesController)
    
    ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: myRidesVC, animated: false)
  }
  override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handleTap()")
    handlePositiveAction(userNotification: userNotification, viewController: viewController)
  }
}
