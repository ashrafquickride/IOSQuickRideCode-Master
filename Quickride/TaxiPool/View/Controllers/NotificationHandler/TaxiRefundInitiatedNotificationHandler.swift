//
//  TaxiRefundInitiatedNotificationHandler.swift
//  Quickride
//
//  Created by Rajesab on 03/06/22.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class TaxiRefundInitiatedNotificationHandler: NotificationHandler{
    override func setNotificationIcon(clientNotification: UserNotification, imageView: UIImageView) {
        if let iconURI = clientNotification.iconUri{
            ImageCache.getInstance().setImageToView(imageView: imageView, imageUrl: iconURI, placeHolderImg: UIImage(named : "taxi_notification_icon"),imageSize: ImageCache.DIMENTION_TINY)
        }else{
            imageView.image = UIImage(named: "taxi_notification_icon")
        }
    }
    
    override func displayNotification(clientNotification: UserNotification) {
        super.displayNotification(clientNotification: clientNotification)
    }
}

