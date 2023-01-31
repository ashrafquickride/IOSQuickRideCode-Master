//
//  PassengerJoinRegularRideNotificationToPassengerHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 07/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class PassengerJoinRegularRideNotificationToPassengerHandler: RideNotificationHandler {
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let passengerRideId = self.getRegularPassengerRideId(userNotification: clientNotification) else {
                return handler(false)
            }
            guard let _  =  MyRegularRidesCache.getInstance().getRegularPassengerRide(passengerRideId: passengerRideId) else {
                return handler(false)
            }
            return handler(true)
        }
      
    }

  override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handleTap()")
    
    let passengerRideId = self.getRegularPassengerRideId(userNotification: userNotification)
    let passengerRide : RegularPassengerRide? = MyRegularRidesCache.getInstance().getRegularPassengerRide(passengerRideId: passengerRideId!)
    if passengerRide == nil {
        return
    }
    let recurringRideViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.recurringRideViewController) as! RecurringRideViewController
    
    recurringRideViewController.initializeDataBeforePresentingView(ride: passengerRide!, isFromRecurringRideCreation: false)
    
    ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: recurringRideViewController, animated: false)
    
  }
    private func getRegularPassengerRideId (userNotification : UserNotification) -> Double? {
        AppDelegate.getAppDelegate().log.debug("getRegularRiderRideId()")
        var passengerRideId: Double?
        let notificationDynamicParams : String? = userNotification.msgObjectJson
        if (notificationDynamicParams != nil) {
            let notificationDynamicDataObj = Mapper<PassengerJoinedRegularRideNotificationToPassengerDynamicData>().map(JSONString: notificationDynamicParams!)! as PassengerJoinedRegularRideNotificationToPassengerDynamicData
            passengerRideId = Double(notificationDynamicDataObj.regularPassengerRideId!)
        }
        return passengerRideId
    }
}
class PassengerJoinedRegularRideNotificationToPassengerDynamicData : NSObject,Mappable {
  var regularPassengerRideId : String?
  var userId : String?
  var userGender : String?
  
  required init?(map: Map) {
    
  }
  
  func mapping(map: Map) {
    regularPassengerRideId <- map[Ride.FLD_ID]
    userId <- map["phone"]
    userGender <- map["gender"]
  }
    public override var description: String {
        return "regularPassengerRideId: \(String(describing: self.regularPassengerRideId))," + "userId: \(String(describing: self.userId))," + "userGender: \(String(describing: self.userGender)),"
    }
}
