//
//  CreateRideNotificaitonHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/01/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class CreateRideNotificaitonHandler : NotificationHandler {
  
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            
            guard let json = clientNotification.msgObjectJson, let ride = Mapper<Ride>().map(JSONString: json) else {
                return handler(false)
            }
            if let _ = MyActiveRidesCache.getRidesCacheInstance()?.checkForRedundancyOfRide(ride: ride){
                return  handler(false)
            }
            return handler(true)
            
        }
    }

  override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handleTap()")
    super.handleTap(userNotification: userNotification, viewController: viewController)
    let routeViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.routeViewController) as! BaseRouteViewController
    let ride = Mapper<Ride>().map(JSONString: userNotification.msgObjectJson!)
    let timeData = Mapper<TimeData>().map(JSONString: userNotification.msgObjectJson!)
    if timeData != nil && timeData?.startTime != nil{
        ride?.startTime = AppUtil.createNSDate(dateString: timeData?.startTime )!.getTimeStamp()
    }else{
      ride?.startTime = NSDate().timeIntervalSince1970*1000
    }
    if ride != nil{
        routeViewController.initializeDataBeforePresenting(ride: ride!)
    }
    
    ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: routeViewController, animated: false)
  }
  override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
    AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
    super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    let ride = Mapper<Ride>().map(JSONString: userNotification.msgObjectJson!)
    
    if ride?.rideType == Ride.RIDER_RIDE{
        let riderRide = Mapper<RiderRide>().map(JSONString: userNotification.msgObjectJson!)
        let timeData = Mapper<TimeData>().map(JSONString: userNotification.msgObjectJson!)
      if timeData != nil && timeData?.startTime != nil{
        riderRide?.startTime = AppUtil.createNSDate(dateString: timeData?.startTime )!.getTimeStamp()
      }else{
        riderRide?.startTime = NSDate().timeIntervalSince1970*1000
      }
//      let rideRoute :RideRoute = RideRoute(routeId: riderRide!.routeId!,overviewPolyline : riderRide!.routePathPolyline,distance : (riderRide?.distance)!,duration : 0, waypoints : riderRide!.waypoints)
      CreateRiderRideHandler(ride: riderRide!, rideRoute: nil, isFromInviteByContact: false, targetViewController: ViewControllerUtils.getCenterViewController()).createRiderRide(handler: { (riderRide, error) in
        RideManagementUtils.moveToRideViewViewController(ride: riderRide!)
      })
    }else if ride?.rideType == Ride.PASSENGER_RIDE{
        let passengerRide = Mapper<PassengerRide>().map(JSONString: userNotification.msgObjectJson!)
        let timeData = Mapper<TimeData>().map(JSONString: userNotification.msgObjectJson!)
      if timeData != nil && timeData?.startTime != nil{
        passengerRide?.startTime = AppUtil.createNSDate(dateString: timeData?.startTime )!.getTimeStamp()
      }else{
        passengerRide?.startTime = NSDate().timeIntervalSince1970*1000
      }
//      let rideRoute :RideRoute = RideRoute(routeId: passengerRide!.routeId!,overviewPolyline : passengerRide!.routePathPolyline,distance : passengerRide!.distance!,duration : 0, waypoints : passengerRide!.waypoints)
        CreatePassengerRideHandler(ride: passengerRide!, rideRoute: nil, isFromInviteByContact: false, targetViewController: ViewControllerUtils.getCenterViewController(), parentRideId: nil,relayLegSeq: nil).createPassengerRide(handler: { (passengerRide, error) in
        RideManagementUtils.moveToRideViewViewController(ride: passengerRide!)
      })
    }else{
      let containerTabBarViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController)
      ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: containerTabBarViewController, animated: false)
    }
  }
  override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    return Strings.create_ride
  }
}
