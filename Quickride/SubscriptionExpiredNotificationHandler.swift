//
//  SubscriptionExpiredNotificationHandler.swift
//  Quickride
//
//  Created by rakesh on 5/25/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class SubscriptionExpiredNotificationHandler : NotificationHandler {
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        
    }

    override func handlePositiveAction(userNotification: UserNotification, viewController: UIViewController?) {
        let account = UserDataCache.getInstance()!.userAccount
        
        let subscriptionAmount = Double(ConfigurationCache.getObjectClientConfiguration().subscriptionAmount)
        
        if account != nil && (account!.balance! - account!.reserved!) < subscriptionAmount {
            let paymentViewController = UIStoryboard(name: StoryBoardIdentifiers.account_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.paymentViewController) as! PaymentViewController
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: paymentViewController, animated: false)
        }else{
            QuickRideProgressSpinner.startSpinner()
            UserRestClient.subscribeToCashTransaction(userId: QRSessionManager.getInstance()!.getUserId(), status: User.SUBS_STATUS_ADVANCE,viewController: viewController, handler: { (responseObject, error) in
                QuickRideProgressSpinner.stopSpinner()
                if responseObject != nil &&  responseObject!["result"] as! String == "SUCCESS"{
                    super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
                    UserDataCache.SUBSCRIPTION_STATUS = false
                    UserDataCache.getInstance()?.refreshAccountInformationInCache()
                    UIApplication.shared.keyWindow?.makeToast( Strings.subscription_success_msg)
                    
                    
                }else{
                    UserDataCache.SUBSCRIPTION_STATUS = true
                }
            })
        }
        
    }
    
    override func handleNegativeAction(userNotification: UserNotification, viewController: UIViewController?) {
        let queryItems = URLQueryItem(name: "&isMobile", value: "true")
        var urlcomps = URLComponents(string :  AppConfiguration.subscription_url)
        urlcomps?.queryItems = [queryItems]
        if urlcomps?.url != nil{
            let webViewController = UIStoryboard(name: StoryBoardIdentifiers.common_storyboard, bundle: nil).instantiateViewController(withIdentifier: "WebViewController") as! WebViewController
            webViewController.initializeDataBeforePresenting(titleString: Strings.quickride, url: urlcomps!.url!, actionComplitionHandler: nil)
            ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: webViewController, animated: false)
        }else{
            UIApplication.shared.keyWindow?.makeToast( Strings.cant_open_this_web_page)
        }
    }
    
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.subscribe
    }
    
    override func getNegativeActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.info
    }
    
    
    
}
