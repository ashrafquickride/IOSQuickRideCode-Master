//
//  PassengerToCheckOutRideNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class PassengerToCheckOutRideNotificationHandler : RideNotificationHandler,RideActionComplete{

    var userNotification : UserNotification?
    var viewController : UIViewController?
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let msgObjectJson = clientNotification.msgObjectJson, !msgObjectJson.isEmpty, let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance(), let riderRideId = Double(msgObjectJson) else {
                return handler(false)
            }
            guard let ride = myActiveRidesCache.getPassengerRideByRiderRideId(riderRideId: riderRideId) else {
                return handler(false)
            }
            return handler(ride.status == Ride.RIDE_STATUS_STARTED)
        }
        
    }

  override func handlePositiveAction(userNotification:UserNotification, viewController : UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
    self.userNotification = userNotification
    self.viewController = viewController
    let riderRideId = Double(userNotification.msgObjectJson!)
    let passengerRideId = Double(userNotification.groupValue!)
    let currentUserId = Double((QRSessionManager.getInstance()?.getUserId())!)!
    
    RideManagementUtils.completePassengerRide(riderRideId: riderRideId!, passengerRideId: passengerRideId!, userId: currentUserId, targetViewController: ViewControllerUtils.getCenterViewController(),rideCompletionActionDelegate: self)
  }
    override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
        self.userNotification = userNotification
        self.viewController = viewController
        super.handleTap(userNotification: userNotification, viewController: viewController)
        let riderRideId = Double(userNotification.msgObjectJson! as String)
        super.navigateToLiveRideView(riderRideId: riderRideId!)
    }
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
      AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
        return Strings.checkout_action
  }
    
    func rideActionCompleted(status: String) {
        if userNotification != nil {
          super.handlePositiveAction(userNotification: userNotification!, viewController: viewController)
        }
       
    }
    
    func rideActionFailed(status: String, error: ResponseError?) {
        
    }
    
}
