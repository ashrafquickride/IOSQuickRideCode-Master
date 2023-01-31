//
//  RiderToStartRideVoiceNotificationHandler.swift
//  Quickride
//
//  Created by QuickRideMac on 26/05/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation

class RiderToStartRideVoiceNotificationHandler: NotificationHandler {
    
    override func getNotificationAudioFilePath() -> String?{
      AppDelegate.getAppDelegate().log.debug("getNotificationAudioFilePath()")
        return Bundle.main.path(forResource: "startride", ofType: "mp3")
    }
    override func handleTap(userNotification: UserNotification, viewController: UIViewController?) {
        super.handleTap(userNotification: userNotification, viewController: viewController)
    }
    override func getPositiveActionNameWhenApplicable(userNotification: UserNotification) -> String? {
        return Strings.start_ride
    }
}
