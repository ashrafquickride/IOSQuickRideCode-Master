//
//  UserAccountNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 22/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class UserAccountNotificationHandler : NotificationHandler {
  
  override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handleTap(userNotification: userNotification, viewController: viewController)
    
    let transactionVC:TransactionViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: "TransactionViewController") as! TransactionViewController
      transactionVC.intialisingData(isFromRewardHistory: false)
    ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: transactionVC, animated: false)
    }
   
    override func getNotiifcationIcon() -> UIImage {
      AppDelegate.getAppDelegate().log.debug("getNotiifcationIcon()")
        return UIImage(named: "notification_rewards")!
    }
}
