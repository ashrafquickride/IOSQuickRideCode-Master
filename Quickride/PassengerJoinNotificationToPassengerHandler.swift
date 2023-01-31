//
//  PassengerJoinNotificationToPassengerHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class PassengerJoinNotificationToPassengerHandler : RideNotificationHandler{
  
  override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handleTap()")
    super.handleTap(userNotification: userNotification, viewController: viewController)
    let riderRideId = self.getRiderRideId(userNotification: userNotification)
    
    let passengerRide =  MyActiveRidesCache.singleCacheInstance?.getPassengerRideByRiderRideId(riderRideId: riderRideId!)
    if passengerRide == nil {
      return
    }else{
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: passengerRide, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    
  }
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification,handler: @escaping (_ valid:Bool) -> Void)
    {
        handler(false)
    }
  
  func getRiderRideId (userNotification : UserNotification?) -> Double? {
    AppDelegate.getAppDelegate().log.debug("getRiderRideId()")
    if let notificationDynamicParams = userNotification?.msgObjectJson , let notificationDynamicDataObj = Mapper<PassengerJoinedRideNotificationToUserDynamicData>().map(JSONString: notificationDynamicParams), let riderRideId = Double(notificationDynamicDataObj.riderRideId!) {
      return riderRideId
      
    }
    return nil
  }
}

class PassengerJoinedRideNotificationToUserDynamicData : NSObject, Mappable {
  var riderRideId : String?
  var userId : String?
  var userGender : String?
  required init?(map: Map) {
    
  }
  
  func mapping(map: Map) {
    riderRideId <- map[Ride.FLD_ID]
    userId <- map["phone"]
    userGender <- map["gender"]
  }
    public override var description: String { 
        return "riderRideId: \(String(describing: self.riderRideId))," + "userId: \(String(describing: self.userId))," + "userGender: \(String(describing: self.userGender)),"
    }
}
