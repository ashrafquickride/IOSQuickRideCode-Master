//
//  FirebaseNotificationHandler.swift
//  Quickride
//
//  Created by Admin on 10/01/19.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class FirebaseNotificationHandler : NotificationHandler{
  
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handlePositiveAction(userNotification: userNotification, viewController: viewController)
    }
  
}
