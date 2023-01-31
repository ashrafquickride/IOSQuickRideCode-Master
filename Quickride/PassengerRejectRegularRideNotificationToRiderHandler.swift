//
//  PassengerRejectRegularRideNotificationToRiderHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 07/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class PassengerRejectRegularRideNotificationToRiderHandler: RideNotificationHandler {
  
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let riderRideId = self.getRegularRiderRideId(userNotification: clientNotification) else{
                return handler(false)
            }
            if let  _ = MyRegularRidesCache.getInstance().getRegularRiderRide(riderRideId: riderRideId) {
                return handler(true)
            }
            return handler(false)
        }
        
    }

  override func handlePositiveAction(userNotification:UserNotification, viewController : UIViewController?){
    AppDelegate.getAppDelegate().log.debug("\(userNotification)")
    super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    let riderRideId = self.getRegularRiderRideId(userNotification: userNotification)
    
    let regularRiderRide : RegularRiderRide? =  MyRegularRidesCache.getInstance().getRegularRiderRide(riderRideId: riderRideId!)
    if regularRiderRide == nil {
      return
    }
    let recurringRideViewController = UIStoryboard(name: StoryBoardIdentifiers.regularride_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.recurringRideViewController) as! RecurringRideViewController
    
    recurringRideViewController.initializeDataBeforePresentingView(ride: regularRiderRide!, isFromRecurringRideCreation: false)
    
    ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: recurringRideViewController, animated: false)
    
    
  }
  override func handleTap(userNotification: UserNotification, viewController :UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handleTap()")
    
    handlePositiveAction(userNotification: userNotification, viewController: viewController)
  }
   func getRegularRiderRideId (userNotification : UserNotification) -> Double? {
    AppDelegate.getAppDelegate().log.debug("getRegularRiderRideId()")
    var riderRideId: Double?
    let notificationDynamicParams : String? = userNotification.msgObjectJson
    if (notificationDynamicParams != nil) {
      let notificationDynamicDataObj = Mapper<PassengerJoinedRegularRideNotificationToRiderDynamicData>().map(JSONString: notificationDynamicParams!)! as PassengerJoinedRegularRideNotificationToRiderDynamicData
      riderRideId = Double(notificationDynamicDataObj.regularRiderRideId!)
    }
    return riderRideId
  }
}
 class PassengerRejectRegularRideNotificationToRiderDynamicData : NSObject,Mappable {
  var regularRiderRideId : String?
  var userId : String?
  var userGender : String?
  
  public required init?(map: Map) {
    
  }
  
   func mapping(map: Map) {
    regularRiderRideId <- map[Ride.FLD_ID]
    userId <- map["phone"]
    userGender <- map["gender"]
  }
    public override var description: String {
        return "regularRiderRideId: \(String(describing: self.regularRiderRideId))," + "userId: \(String(describing: self.userId))," + "userGender: \(String(describing: self.userGender)),"
    }
}
