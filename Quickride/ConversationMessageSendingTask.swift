//
//  ConversationMessageSendingTask.swift
//  Quickride
//
//  Created by QuickRideMac on 02/07/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper
class ConversationMessageSendingTask {
    var viewController : UIViewController?
    var conversationMessage : ConversationMessage?
    var userAppVersion : AppVersion?
    
    init(viewController : UIViewController?, conversationMessage : ConversationMessage){
        self.viewController = viewController
        self.conversationMessage = conversationMessage
    }
    func publishMessage(){
        conversationMessage!.uniqueID = QuickRideMessageEntity.CHAT_ENTITY + "_" + StringUtils.getStringFromDouble(decimalNumber: conversationMessage!.sourceId) + "_" + conversationMessage!.uniqueID!
        if MessageUtils.isMessageAllowedToDisplay(message: conversationMessage!.message!, latitude: conversationMessage!.latitude, longitude: conversationMessage!.longitude) {
            publishConversationMessage(conversationMessage: conversationMessage!)
        }
        self.updateMessageToServer()
        conversationMessage!.msgStatus = ConversationMessage.MSG_STATUS_SENT
        ConversationCache.getInstance().updateConversationMessageStatus(conversationMessage: conversationMessage!)
        let messageStatusTracker = MessageStatusTracker.getMessageStatusTrackerInstance();
        messageStatusTracker.startStatusTracker()
    }
    
    func publishConversationMessage(conversationMessage : ConversationMessage)
    {
        AppDelegate.getAppDelegate().log.debug("\(conversationMessage)")
        conversationMessage.msgObjType = QuickRideMessageEntity.CHAT_ENTITY
        let jsondata : String = Mapper().toJSONString(conversationMessage , prettyPrint: true)!
        ConversationCache.getInstance().getAppVersion(userId: conversationMessage.destId!, handler: { (appVersion) in
            self.userAppVersion = appVersion
            if appVersion == nil {
                AppDelegate.getAppDelegate().log.debug("App version is nil")
                let topic = TopicUtils.addPrefixForTopic(appName: AppConfiguration.APP_NAME,  topic : UserMessageTopicListener.USER_MSG_TOPIC + StringUtils.getStringFromDouble(decimalNumber : conversationMessage.destId))
                
                EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.publishMessage(topicName: topic, mqttMessage: jsondata)
                
            }else if (self.userAppVersion?.appName != nil && !(User.APP_NAME_QUICKRIDE == (self.userAppVersion?.appName))) {
                // WeRide or GTechRide
                AppDelegate.getAppDelegate().log.debug("Not QuickRide User")
                let topic = TopicUtils.addPrefixForTopic(appName: AppConfiguration.APP_NAME,  topic : UserMessageTopicListener.USER_MSG_TOPIC + StringUtils.getStringFromDouble(decimalNumber : conversationMessage.destId))
                
                EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.publishMessage(topicName: topic, mqttMessage: jsondata)
                
            }
                //Todo Mig
            else if((self.userAppVersion?.androidAppVersion != 0 && Double((self.userAppVersion?.androidAppVersion)!) >= Double(AppConfiguration.MIN_ANDROID_APP_VERSION_REQUIRED_FOR_CONVERSATION_STATUS)) ||
                (self.userAppVersion?.iosAppVersion != 0 && self.userAppVersion!.iosAppVersion! >= AppConfiguration.MIN_IOS_APP_VERSION_REQUIRED_FOR_CONVERSATION_STATUS))
            {
                if(Double((self.userAppVersion?.androidAppVersion)!) >= Double(AppConfiguration.MIN_ANDROID_APP_VERSION_REQUIRED_FOR_CONVERSATION_STATUS_USING_USER_STATIC_TOPIC) ||
                    Double(self.userAppVersion!.iosAppVersion!) >= Double(AppConfiguration.MIN_IOS_APP_VERSION_REQUIRED_FOR_CONVERSATION_STATUS_USING_USER_STATIC_TOPIC))
                {
                    let topic = TopicUtils.addPrefixForTopic(appName: AppConfiguration.APP_NAME,  topic : UserMessageTopicListener.USER_MSG_TOPIC + StringUtils.getStringFromDouble(decimalNumber : conversationMessage.destId))
                    
                    EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.publishMessage(topicName: topic, mqttMessage: jsondata)
                }
                else
                {
                    let topic = TopicUtils.addPrefixForTopic(appName: AppConfiguration.APP_NAME,  topic : ConversationListener.CONVERSATION_TOPIC_NAME + StringUtils.getStringFromDouble(decimalNumber : conversationMessage.destId))
                    EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.publishMessage(topicName: topic, mqttMessage: jsondata)
                    
                }
            }
        })
    }
    
    func updateMessageToServer(){
        ChatRestClient.notifyConversationMessageToServer(conversationMessage: conversationMessage!, viewController: nil, handler: { (responseObject, error) in
            
        })
    }
}
