//
//  QuickRideRemoteBackgroundNotificationHandler.swift
//  Quickride
//
//  Created by KNM Rao on 03/02/17.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
import UserNotifications

class QuickRideRemoteBackgroundNotificationHandler{
    
    static var remoteNotificationBeforeAppStart : [AnyHashable : Any]?
    
    func handleRemoteNotifications(userInfo: [AnyHashable : Any]){
        AppDelegate.getAppDelegate().log.debug("QuickRideRemoteBackgroundNotificationHandler:- \(userInfo)")
        if let aps = userInfo["aps"] as? [String: AnyObject] {
            if let msgClassName = userInfo[AnyHashable(UserNotification.MSG_CLASS_NAME)] as? String, msgClassName == QuickRideMessageEntity.QUICKRIDE_MESSAGE_ENTITY_CLASS_NAME{
                guard let topicName = userInfo[AnyHashable(UserNotification.MQTT_TOPIC_NAME)] as? String, let notificationInfo = userInfo[AnyHashable(UserNotification.MSG_OBJECT_JSON) as NSObject] as? String else {
                    return
                }
                if (!SessionManagerController.sharedInstance.isSessionManagerInitialized()) {
                    QuickRideRemoteBackgroundNotificationHandler.remoteNotificationBeforeAppStart = userInfo
                }else{
                    EventServiceProxyFactory.getEventServiceProxy(topicName: topicName)?.onNewMessageArrivedFromRemoteNotification(topicName: topicName, message: userInfo[AnyHashable(UserNotification.MSG_OBJECT_JSON) as NSObject])
                }
            }else{
                if let payload = userInfo["payload"] as? [String : AnyObject],let deeplink = payload["deeplink"]{
                    AppDelegate.getAppDelegate().log.debug("Deeplink :- \(deeplink)")
                    scheduleLocalNotification(userInfo: userInfo, aps: aps)
                }else{
                    handleNotificationFromFireBase(userInfo: userInfo, aps: aps)
                }
            }
        }
    }
    
    func handleNotificationFromFireBase(userInfo : [AnyHashable : Any],aps : [String: AnyObject]?){
        
        guard let alertBody = aps?["alert"],let title = alertBody.value(forKey: "title") as? String,let desc = alertBody.value(forKey: "body") as? String, let type = userInfo["google.c.a.c_l"] as? String,type == UserNotification.NOT_TYPE_FIREBASE_NOT else {
            return
        }
        
        let userNotification = UserNotification()
        userNotification.title = title
        userNotification.description = desc
        userNotification.type = type
        userNotification.uniqueID = String(NotificationHandler().getUniqueNotificationId())
        userNotification.groupName = "Message"
        userNotification.groupValue = QRSessionManager.getInstance()?.getUserId()
        
        FirebaseNotificationHandler().handleNewUserNotification(clientNotification: userNotification)
        
    }
    
    func scheduleLocalNotification(userInfo : [AnyHashable : Any],aps : [String: AnyObject]?){
        
        guard let alertBody = aps?["alert"],let title = alertBody.value(forKey: "title") as? String,let body = alertBody.value(forKey: "body") as? String else {
            return
        }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body =  body
        content.userInfo = userInfo
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest.init(identifier: "smartechPush", content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request)
    }
}
