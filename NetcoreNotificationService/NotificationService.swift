//
//  NotificationService.swift
//  NetcoreNotificationService
//
//  Created by Admin on 28/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import UserNotifications
import NetCorePush

class NotificationService: UNNotificationServiceExtension {

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        
    NetCoreNotificationService.sharedInstance().setUpAppGroup("group.com.disha.ios.quickride")
        NetCoreNotificationService.sharedInstance().didReceive(request) { (contentToDeliver:UNNotificationContent) in
            contentHandler(contentToDeliver)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        NetCoreNotificationService.sharedInstance().serviceExtensionTimeWillExpire()
    }

}
