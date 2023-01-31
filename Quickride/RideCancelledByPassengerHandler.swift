//
//  RideCancelledByPassengerHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RideCancelledByPassengerHandler : RideNotificationHandler {
  
  
  func getRiderRideObject (userNotification : UserNotification) -> Ride? {
    AppDelegate.getAppDelegate().log.debug("getRiderRideObject()")
    var riderRideObj: Ride?
    let notificationDynamicParams : String? = userNotification.msgObjectJson
    if (notificationDynamicParams != nil) {
      let notificationDynamicDataObj = Mapper<PassengerCancelledRideNotificationDynamicData>().map(JSONString: notificationDynamicParams!)! as PassengerCancelledRideNotificationDynamicData
        riderRideObj = MyActiveRidesCache.singleCacheInstance?.getRiderRide(rideId:
        Double(notificationDynamicDataObj.riderRideId!)!)
    }
    return riderRideObj
  }

    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let ride = self.getRiderRideObject(userNotification: clientNotification) else {
                return handler(false)
            }
            return handler(true)
        }
    }

    override func handleTextToSpeechMessage(userNotification : UserNotification)
    {
        let myActiveRidesCache = MyActiveRidesCache.getRidesCacheInstance()
        if myActiveRidesCache == nil{
            return
        }
        let ride = getRiderRideObject(userNotification: userNotification)
        if ride != nil{
            if Ride.RIDE_STATUS_STARTED == ride!.status{
                checkRiderRideStatusAndSpeakInvitation(text: userNotification.title!, time: NotificationHandler.delay_time)
            }
        }
    }

  override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handleTap()")
    
    let scheduledRiderRide : Ride? = getRiderRideObject (userNotification: userNotification)
    
    if (scheduledRiderRide != nil) {
        
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: scheduledRiderRide, isFromRideCreation: true, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
        
    }
  }
}
class PassengerCancelledRideNotificationDynamicData : NSObject, Mappable {
  var riderRideId : String?
  var passengerUserId : String?
  var passengerGender : String?
  
  required init?(map: Map) {
    
  }
  
  func mapping(map: Map) {
    riderRideId <- map[Ride.FLD_ID]
    passengerUserId <- map["phone"]
    passengerGender <- map["gender"]
  }
    public override var description: String { 
        return "riderRideId: \(String(describing: self.riderRideId))," + "passengerUserId: \(String(describing: self.passengerUserId))," + "passengerGender: \(String(describing: self.passengerGender)),"
    }
}
