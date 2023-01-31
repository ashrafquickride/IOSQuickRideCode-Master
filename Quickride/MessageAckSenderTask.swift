//
//  :
//  Quickride
//
//  Created by KNM Rao on 15/06/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class MessageAckSenderTask {
  var conversationMessage : ConversationMessage
  var status : Int
  var userAppVersion : AppVersion?
  
  init( conversationMessage : ConversationMessage, status : Int ){
    self.conversationMessage = conversationMessage
    self.status = status
  }
  func publishMessage(){
    
    let statusMessage : ConversationMessage = ConversationMessage()
    statusMessage.actualMessageId = conversationMessage.uniqueID
    statusMessage.msgType = ConversationMessage.MSG_TYPE_STATUS
    statusMessage.sourceId = conversationMessage.sourceId
    statusMessage.destId = conversationMessage.destId
    statusMessage.time = NSDate().timeIntervalSince1970*1000
    statusMessage.msgStatus = status
    statusMessage.msgObjType = QuickRideMessageEntity.CHAT_ENTITY
    let message = Mapper().toJSONString(statusMessage)
    
    ConversationCache.getInstance().getAppVersion(userId: conversationMessage.sourceId!, handler: { (appVersion) in
      self.userAppVersion = appVersion
      
      if appVersion == nil {
        AppDelegate.getAppDelegate().log.debug("App Version is nil")
        let topic = TopicUtils.addPrefixForTopic(appName: AppConfiguration.APP_NAME,  topic : UserMessageTopicListener.USER_MSG_TOPIC+StringUtils.getStringFromDouble(decimalNumber : self.conversationMessage.sourceId))
        
        EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.publishMessage(topicName: topic,mqttMessage: message!)
        
      }else if (self.userAppVersion?.appName != nil && !(User.APP_NAME_QUICKRIDE == (self.userAppVersion?.appName))) {
        // WeRide or GTechRide
        AppDelegate.getAppDelegate().log.debug("Not QuickRide User")
        let topic = TopicUtils.addPrefixForTopic(appName: AppConfiguration.APP_NAME,  topic : UserMessageTopicListener.USER_MSG_TOPIC + StringUtils.getStringFromDouble(decimalNumber : self.conversationMessage.sourceId))
        
        EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.publishMessage(topicName: topic, mqttMessage: message!)
        
      }else if(( Double((self.userAppVersion?.androidAppVersion)!) >= Double(AppConfiguration.MIN_ANDROID_APP_VERSION_REQUIRED_FOR_CONVERSATION_STATUS_USING_USER_STATIC_TOPIC)) ||
        (Double(self.userAppVersion!.iosAppVersion!) >= (AppConfiguration.MIN_IOS_APP_VERSION_REQUIRED_FOR_CONVERSATION_STATUS_USING_USER_STATIC_TOPIC)))
      {
        let topic = TopicUtils.addPrefixForTopic(appName: AppConfiguration.APP_NAME,  topic : UserMessageTopicListener.USER_MSG_TOPIC+StringUtils.getStringFromDouble(decimalNumber : self.conversationMessage.sourceId))
        
        EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.publishMessage(topicName: topic,mqttMessage: message!)
      }
      else{
        let topic = TopicUtils.addPrefixForTopic(appName: AppConfiguration.APP_NAME,  topic : ConversationListener.CONVERSATION_TOPIC_NAME+StringUtils.getStringFromDouble(decimalNumber : self.conversationMessage.sourceId))
        EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.publishMessage(topicName: topic,mqttMessage: message!)
      }

    })
    
    ChatRestClient.notifyConversationMessageAckToServer(conversationMessage: statusMessage, phone: StringUtils.getStringFromDouble(decimalNumber: conversationMessage.destId), viewController: nil, handler: { (responseObject, error) in
    })
    ConversationCache.getInstance().updateConversationStatusInCacheAndPersistance(conversationMessage: statusMessage)
  }
}
