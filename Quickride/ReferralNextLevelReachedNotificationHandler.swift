//
//  ReferralNextLevelReachedNotificationHandler.swift
//  Quickride
//
//  Created by Halesh on 14/05/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ReferralNextLevelReachedNotificationHandler: NotificationHandler{
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        let myReferralsViewController = UIStoryboard(name: StoryBoardIdentifiers.shareandearn_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.myReferralsViewController) as! MyReferralsViewController
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: myReferralsViewController, animated: false)
    }
}
