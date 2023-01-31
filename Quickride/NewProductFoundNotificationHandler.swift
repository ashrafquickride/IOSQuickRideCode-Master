//
//  NewProductFoundNotificationHandler.swift
//  Quickride
//
//  Created by QR Mac 1 on 02/12/20.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class NewProductFoundNotificationHandler: NotificationHandler {
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
        QuickShareNotificationHandler().showProduct(viewController: viewController, userNotification: userNotification)
    }
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: UIImage(named: "bazaary_notification_icon"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = UIImage(named: "bazaary_notification_icon")
        }
    }
}
