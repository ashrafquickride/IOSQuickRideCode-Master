//
//  offerExpiredNotificationHandler.swift
//  Quickride
//
//  Created by Admin on 03/04/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class offerExpiredNotificationHandler : NotificationHandler{
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        let containerTabBarViewController = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        ViewControllerUtils.displayViewController(currentViewController: nil, viewControllerToBeDisplayed: containerTabBarViewController, animated: false)
    }
}
