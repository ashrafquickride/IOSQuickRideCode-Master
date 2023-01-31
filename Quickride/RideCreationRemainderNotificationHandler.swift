//
//  RideCreationRemainderNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 25/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class RideCreationRemainderNotificationHandler: NotificationHandler {
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let rideCount = MyActiveRidesCache.getRidesCacheInstance()?.getUsersActiveRidesCount() else {
                return handler(true)
            }
            return handler(rideCount == 0)
        }
    }
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("handleTap()")
        handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
       AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        let containerTabBarViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController)
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: containerTabBarViewController, animated: false)
    }
  override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
    return Strings.yes
  }
    
}
