//
//  PassengerJoinedRideGotCancelledHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PassengerJoinedRideGotCancelledHandler : RideNotificationHandler{
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let groupValue = clientNotification.groupValue, !groupValue.isEmpty, let rideId = Double(groupValue), let ride = MyActiveRidesCache.getRidesCacheInstance()?.getPassengerRide(passengerRideId: rideId), ride.status != Ride.RIDE_STATUS_REQUESTED else {
                return handler(true)
            }
            return handler(false)
        }
        
    }
  
   func getPassengerRideObject (userNotification : UserNotification) -> Ride? {
    AppDelegate.getAppDelegate().log.debug("getPassengerRideObject()")
    var passengerRideObj: Ride?
    let notificationDynamicParams : String? = userNotification.msgObjectJson
    if (notificationDynamicParams != nil) {
      let notificationDynamicDataObj = Mapper<RiderCancelledRideNotificationDynamicData>().map(JSONString: notificationDynamicParams!)! as RiderCancelledRideNotificationDynamicData
      passengerRideObj = MyActiveRidesCache.singleCacheInstance?.getPassengerRide(passengerRideId :
        Double(notificationDynamicDataObj.passengerRideId!)!)
    }
    return passengerRideObj
  }
  override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
    
    let passengerRide : Ride? = getPassengerRideObject (userNotification: userNotification)
    if (passengerRide != nil) {
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: passengerRide, isFromRideCreation: true, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
  }

}

public class RiderCancelledRideNotificationDynamicData : NSObject, Mappable {
  var passengerRideId : String?
  var riderUserId : String?
  var riderGender : String?
  
  public required init?(map: Map) {
    
  }
  
  public func mapping(map: Map) {
    passengerRideId <- map[Ride.FLD_PASSENGERRIDEID]
    riderUserId <- map["phone"]
    riderGender <- map["gender"]
  }
    public override var description: String {
        return "passengerRideId: \(String(describing: self.passengerRideId))," + "riderUserId: \(String(describing: self.riderUserId))," + "riderGender: \(String(describing: self.riderGender)),"
    }
}
