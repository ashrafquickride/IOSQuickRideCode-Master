//
//  PassengerJoinNotificationToRiderHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PassengerJoinNotificationToRiderHandler : RideNotificationHandler{
  
  override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handleTap()")
    
    guard let riderRideId = self.getRiderRideId(userNotification: userNotification) else {
        return
    }
    let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
    mainContentVC.initializeDataBeforePresenting(riderRideId: riderRideId, rideObj: nil, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
    ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
  }
  
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification,handler: @escaping (_ valid:Bool) -> Void)
    {
        handler(false)
    }
    override func handleTextToSpeechMessage(userNotification : UserNotification)
    {
        let riderRideId = getRiderRideId(userNotification: userNotification)
        let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
        if myActiveRidesCache == nil || riderRideId == nil{
            return
        }
        let ride = myActiveRidesCache!.getRiderRide(rideId: riderRideId!)
        if ride != nil{
            if Ride.RIDE_STATUS_STARTED == ride!.status{
                checkRiderRideStatusAndSpeakInvitation(text: userNotification.title!, time: NotificationHandler.delay_time)
            }
        }
    }

  private func getRiderRideId (userNotification : UserNotification) -> Double? {
    AppDelegate.getAppDelegate().log.debug("getRiderRideId()")
    var riderRideId: Double?
    let notificationDynamicParams : String? = userNotification.msgObjectJson
    if (notificationDynamicParams != nil) {
      let notificationDynamicDataObj = Mapper<PassengerJoinedRideNotificationToUserDynamicData>().map(JSONString: notificationDynamicParams!)! as PassengerJoinedRideNotificationToUserDynamicData
      riderRideId = Double(notificationDynamicDataObj.riderRideId!)!
    }
    return riderRideId
  }
}
