//
//  UserToCreateFirstRideNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 25/03/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class UserToCreateFirstRideNotificationHandler: NotificationHandler {
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let count = MyActiveRidesCache.getRidesCacheInstance()?.getUsersActiveRidesCount(), count <= 0 else {
                return handler(false)
            }
            return handler(true)
           
        }
        
    }

    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("handleTap()")

        handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
      AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
       return Strings.NEED_HELP
    }
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
        
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        
        let helpViewController = UIStoryboard(name: StoryBoardIdentifiers.help_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.helpViewController) as! HelpBaseViewController
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: helpViewController, animated: false)
    }
}
