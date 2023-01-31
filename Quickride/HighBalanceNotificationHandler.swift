//
//  HighBalanceNotificationHandler.swift
//  Quickride
//
//  Created by iDisha on 10/05/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class HighBalanceNotificationHandler: UserAccountNotificationHandler {
    
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            let userAccount = UserDataCache.getInstance()?.userAccount
            if userAccount == nil
            {
                return handler(false)
            }
            var clientConfigurtion = ConfigurationCache.getInstance()?.getClientConfiguration()
            if clientConfigurtion == nil{
                clientConfigurtion = ClientConfigurtion()
            }
            if Int(userAccount!.earnedPoints) > clientConfigurtion!.higherThresoldBalance
            {
                return handler(true)
            }
            return handler(false)
        }
        
    }
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handleTap(userNotification: userNotification, viewController: viewController)
        let paymentViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.paymentViewController) as! PaymentViewController
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: paymentViewController, animated: false)
    }
}
