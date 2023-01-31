//
//  ProfileVerificationReminderNotificationHandler.swift
//  Quickride
//
//  Created by Nagamalleswara Rao  Kuchipudi on 27/03/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class ProfileVerificationReminderNotificationHandler: UserProfileVerificationNotificationHandler {
    
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handleTap(userNotification: userNotification, viewController: viewController)
    }
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.verify_caps
    }
}
