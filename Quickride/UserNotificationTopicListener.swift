//
//  UserNotificationTopicListener.swift
//  Quickride
//
//  Created by KNM Rao on 15/11/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class UserNotificationTopicListener: TopicListener {
   override func getMessageClassName() -> AnyClass {
    AppDelegate.getAppDelegate().log.debug("getMessageClassName()")
    return type(of: self)
  }
  
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("onMessageRecieved()")
        let userNotification = Mapper<UserNotification>().map(JSONString: messageObject as! String)
        if userNotification == nil{
            return
        }
        
        if (UserNotification.NOT_STATUS_UPDATE == userNotification!.groupName)
        {
            UserDataCache.getInstance()?.notifyUserLockedStatus()
        }
        NotificationHandlerFactory.getNotificationHandler(clientNotification: userNotification!)?.handleNewUserNotification(clientNotification: userNotification!)
    }
}
