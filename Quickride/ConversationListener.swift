//
//  ConversationListener.swift
//  Quickride
//
//  Created by QuickRideMac on 07/04/16.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class ConversationListener: TopicListener {
    
    static let CONVERSATION_TOPIC_NAME="conversation/";
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: message))")
        let conversationMessage  = Mapper<ConversationMessage>().map(JSONString: (messageObject as! NSString) as String)
        
        if UserDataCache.getInstance() != nil && UserDataCache.getInstance()!.isABlockedUserForCurrentUser(userId: conversationMessage!.sourceId!)
        {
            AppDelegate.getAppDelegate().log.debug("Blocked User")
            return
        }
        self.checkRideStatusAndSpeakMessageForPersonalChat(conversationMessage: conversationMessage!)
      if ((Double)(QRSessionManager.getInstance()!.getUserId()) != conversationMessage!.sourceId)
      {
        let messageAckSenderTask  : MessageAckSenderTask = MessageAckSenderTask(conversationMessage: conversationMessage!,status: ConversationMessage.MSG_STATUS_DELIVERED)
        messageAckSenderTask.publishMessage()
      }
        ConversationCache.getInstance().receiveNewConversationMessage(conversationMessage: conversationMessage!)
  
  
  }

    func subscribeToConversationTopic(){
        AppDelegate.getAppDelegate().log.debug("")
        let userId = QRSessionManager.getInstance()!.getUserId()
        let topicName = TopicUtils.addPrefixForTopic(appName : AppConfiguration.APP_NAME,  topic : ConversationListener.CONVERSATION_TOPIC_NAME + userId)
        EventServiceProxyFactory.getEventServiceProxy(topicName : topicName)?.subscribe(topicName : topicName,topicListener: self)
        
    }
    
    func unSubscribeToConversationTopic(){
        AppDelegate.getAppDelegate().log.debug("")
        let userId = QRSessionManager.getInstance()!.getUserId()
        let topicName = TopicUtils.addPrefixForTopic(appName : AppConfiguration.APP_NAME,  topic : ConversationListener.CONVERSATION_TOPIC_NAME + userId)
        EventServiceProxyFactory.getEventServiceProxy(topicName : topicName)?.unSubscribe(topicName : topicName, topicListener: self)
    }
    
    func checkRideStatusAndSpeakMessageForPersonalChat(conversationMessage: ConversationMessage){
        if conversationMessage.sourceName != nil && conversationMessage.message != nil{
            let state = UIApplication.shared.applicationState
            if state == .background  || state == .inactive{
                let riderRide = MyActiveRidesCache.getRidesCacheInstance()?.getActiveStatedRiderRide()
                if riderRide != nil {
                    let text = conversationMessage.sourceName! + " says " + conversationMessage.message!
                    ConversationCache.speakTextIfRideStarted(msgText: text)
                }
            }
        }
    }
    
    
    
}
