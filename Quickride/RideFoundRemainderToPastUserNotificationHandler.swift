//
//  RideFoundRemainderToPastUserNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 25/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class RideFoundRemainderToPastUserNotificationHandler: NotificationHandler {
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("handleTap()")
       handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("(handlePositiveAction)")
        let routeTabBar = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        let ride = Mapper<Ride>().map(JSONString: userNotification.msgObjectJson!)
      if ride!.startTime == 0{
        let timeData = Mapper<TimeData>().map(JSONString: userNotification.msgObjectJson!)
        let startTime = AppUtil.createNSDate(dateString: timeData?.startTime)
        if startTime != nil{
          ride!.startTime = startTime!.getTimeStamp()
        }
      }
        ContainerTabBarViewController.data = ride
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: routeTabBar, animated: false)
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
       AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
        return Strings.VIEW
    }
}
