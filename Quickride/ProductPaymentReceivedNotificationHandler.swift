//
//  ProductPaymentReceivedNotificationHandler.swift
//  Quickride
//
//  Created by QR Mac 1 on 25/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ProductPaymentReceivedNotificationHandler: NotificationHandler {
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        moveToQuickMarketPage(viewController: viewController)
    }
    private func moveToQuickMarketPage(viewController: UIViewController?) {
        let routeTabBar = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        ContainerTabBarViewController.indexToSelect = 2
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: routeTabBar, animated: false)
    }
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: UIImage(named : "bazaary_notification_icon"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = UIImage(named: "bazaary_notification_icon")
        }
    }
}
