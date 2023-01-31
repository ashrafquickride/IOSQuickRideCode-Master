//
//  LowBalanceNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 22/02/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class LowBalanceNotificationHandler : UserAccountNotificationHandler {
  
    override func isNotificationQualifiedToDisplay(clientNotification: UserNotification, handler: @escaping (_ valid: Bool) -> Void)
    {
        super.isNotificationQualifiedToDisplay(clientNotification: clientNotification) { valid in
            if !valid {
                return handler(valid)
            }
            guard let userAccount = UserDataCache.getInstance()?.userAccount else {
                return handler(false)
            }
            let clientConfigurtion = ConfigurationCache.getInstance()?.getClientConfiguration() ?? ClientConfigurtion()
            return handler(userAccount.balance! < clientConfigurtion.minBalanceToDisplayLowBalanceNotification)
        }
        
    }

  override func handlePositiveAction(userNotification:UserNotification, viewController  : UIViewController?){
    AppDelegate.getAppDelegate().log.debug("handlePositiveAction()")
    super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    let paymentViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.paymentViewController) as! PaymentViewController
    ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: paymentViewController, animated: false)
  }
  
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
      AppDelegate.getAppDelegate().log.debug("getPositiveActionNameWhenApplicable()")
    return Strings.recharge
  }
}
