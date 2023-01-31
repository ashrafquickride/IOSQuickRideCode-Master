//
//  ProfileVerificationCancellationNotificationHandler.swift
//  Quickride
//
//  Created by Vinutha on 9/22/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
class ProfileVerificationCancellationNotificationHandler : NotificationHandler {
    
    override func handleTap(userNotification: UserNotification,viewController :UIViewController?) {
        AppDelegate.getAppDelegate().log.debug("\(userNotification)")
        let profileEditingViewController = UIStoryboard(name : StoryBoardIdentifiers.profile_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.profileEditingViewController) as! ProfileEditingViewController
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: profileEditingViewController, animated: false)
    }
    
}
