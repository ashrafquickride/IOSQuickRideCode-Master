//
//  AppRetainedStatusUpdateNotificationHandler.swift
//  Quickride
//
//  Created by Vinutha on 30/03/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class AppRetainedStatusUpdateNotificationHandler: NotificationHandler{
    
    override func displayNotification(clientNotification : UserNotification){
        AppDelegate.getAppDelegate().log.debug("\(String(describing: clientNotification.msgObjectJson))")
    }
}
