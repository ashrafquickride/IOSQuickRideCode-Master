//
//  RideInstanceCreationNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 05/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper


class RideInstanceCreationNotificationHandler : NotificationHandler {
  var userNotification : UserNotification?
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            self.userNotification = clientNotification
            guard let _ = self.getRide() else {
                return handler(false)
            }
            guard let status = SharedPreferenceHelper.getNewUserInfoUpdateStatus(key: SharedPreferenceHelper.NEW_USER_PROFILE_PIC_UPLOAD), !status else {
                return handler(false)
            }
            return handler(true)
        }
    }
    
  override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handleTap()")
    super.handleTap(userNotification: userNotification, viewController: viewController)
    self.userNotification = userNotification
    moveToLiveRide(viewController: viewController)
  }
    private func moveToLiveRide(viewController: UIViewController?){
        let ride = getRide()
        if ride == nil{
            UIApplication.shared.keyWindow?.makeToast( Strings.ride_is_not_available_try_after_sometime)
            return
        }
        let mainContentVC = UIStoryboard(name: "LiveRideView", bundle: nil).instantiateViewController(withIdentifier: "LiveRideMapViewController") as! LiveRideMapViewController
        mainContentVC.initializeDataBeforePresenting(riderRideId: 0, rideObj: ride, isFromRideCreation: false, isFreezeRideRequired: false, isFromSignupFlow: false,relaySecondLegRide: nil,requiredToShowRelayRide: "")
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: mainContentVC, animated: true)
    }
    
  func getRide() -> Ride?{
    AppDelegate.getAppDelegate().log.debug("getRide()")
    return nil
  }
    
  func getRideId() -> Double{
    AppDelegate.getAppDelegate().log.debug("getRideId()")
    let dynamicData : RideInstanceCreationNotificationDynamicData = Mapper<RideInstanceCreationNotificationDynamicData>().map(JSONString: (userNotification?.msgObjectJson)!)!
    return Double(dynamicData.rideId!)!
  }
  override func handleNeutralAction(userNotification: UserNotification, viewController: UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handleNeutralAction()")
    self.userNotification = userNotification
    moveToLiveRide(viewController: viewController)
  }
    
  override func getNeutralActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    AppDelegate.getAppDelegate().log.debug("getNeutralActionNameWhenApplicable()")
    return Strings.VIEW
  }
}
public class RideInstanceCreationNotificationDynamicData : Mappable {
  var rideId: String?
  
  required public init?(map:Map){
    
  }
  
  public func mapping(map: Map) {
    rideId <- map[Ride.FLD_ID]
  }
  
}
