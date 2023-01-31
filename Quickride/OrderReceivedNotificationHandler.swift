//
//  OrderReceivedNotificationHandler.swift
//  Quickride
//
//  Created by QR Mac 1 on 24/11/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class OrderReceivedNotificationHandler: NotificationHandler{
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: UIImage(named : "bazaary_notification_icon"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = UIImage(named: "bazaary_notification_icon")
        }
    }
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        moveToQuickMarketPage(userNotification: userNotification, viewController: viewController)
    }
    private func moveToQuickMarketPage(userNotification: UserNotification,viewController: UIViewController?) {
        getMyOrder(userNotification: userNotification, viewController: viewController)
        let routeTabBar = UIStoryboard(name: StoryBoardIdentifiers.mapview_storyboard, bundle: nil).instantiateViewController(withIdentifier: ViewControllerIdentifiers.containerTabBarViewController) as! ContainerTabBarViewController
        ContainerTabBarViewController.indexToSelect = 2
        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: routeTabBar, animated: false)
    }
    
    private func getMyOrder(userNotification: UserNotification,viewController: UIViewController?){
        guard let msgObjectJson = userNotification.msgObjectJson else { return }
        let productNotification = Mapper<ProductNotification>().map(JSONString: msgObjectJson)
        if let notification = productNotification,let listingId = notification.listingId,let orderId = notification.orderId{
            QuickShareSpinner.start()
            QuickShareRestClient.getParticularOrder(listingId: listingId, userId: UserDataCache.getInstance()?.userId ?? "", orderId: orderId){ (responseObject, error) in
                QuickShareSpinner.stop()
                if responseObject != nil && responseObject!["result"] as! String == "SUCCESS" {
                    if let order = Mapper<Order>().map(JSONObject: responseObject!["resultData"]){
                        let requestDetailsViewController = UIStoryboard(name: StoryBoardIdentifiers.quickShare_storyboard, bundle: nil).instantiateViewController(withIdentifier: "RequestDetailsViewController") as! RequestDetailsViewController
                        requestDetailsViewController.initialiseReceivedOrder(order: order)
                        ViewControllerUtils.displayViewController(currentViewController: viewController, viewControllerToBeDisplayed: requestDetailsViewController, animated: false)
                    }
                }else{
                    ErrorProcessUtils.handleError(responseObject: responseObject, error: error, viewController: viewController, handler: nil)
                }
            }
        }
    }
    
}
