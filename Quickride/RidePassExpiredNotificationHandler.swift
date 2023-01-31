//
//  RidePassExpiredNotificationHandler.swift
//  Quickride
//
//  Created by Admin on 05/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RidePassExpiredNotificationHandler : NotificationHandler{
   
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        
        super.handleTap(userNotification: userNotification, viewController: viewController)
        let paymentViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.paymentViewController) as! PaymentViewController
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: paymentViewController, animated: false)
    
    }
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.renew_pass
    }
    
    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        let paymentViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.paymentViewController) as! PaymentViewController
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: paymentViewController, animated: false)
    }
}
