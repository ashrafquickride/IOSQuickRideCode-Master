//
//  UserCustomNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 19/11/15.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

public class UserCustomNotificationHandler : NotificationHandler{
    
    override func handleTap(userNotification: UserNotification,viewController :UIViewController?) {
      AppDelegate.getAppDelegate().log.debug("handleTap()")
        super.handleTap(userNotification: userNotification, viewController: viewController)
        let containerTabBarViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController)
        ViewControllerUtils.presentViewController(currentViewController: viewController, viewControllerToBeDisplayed: containerTabBarViewController, animated: false, completion: nil)
    }
}
