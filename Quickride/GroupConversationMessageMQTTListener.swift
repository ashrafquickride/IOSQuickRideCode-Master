//
//  GroupConversationMessageMQTTListener.swift
//  Quickride
//
//  Created by QuickRideMac on 3/19/18.
//  Copyright © 2014-2020. Quick Ride (www.quickride.in). All rights reserved.
//  iDisha Info Labs Pvt Ltd. proprietary.
//

import Foundation
import ObjectMapper

class GroupConversationMessageMQTTListener : TopicListener{
    
    static let USER_GROUP_CHAT_TOPIC = "usergroup/chat/"
    
    func subscribeToGroup(groupId : Double){
        AppDelegate.getAppDelegate().log.debug("groupId: \(groupId)")
        let topicName = GroupConversationMessageMQTTListener.USER_GROUP_CHAT_TOPIC + StringUtils.getStringFromDouble(decimalNumber: groupId)
        EventServiceProxyFactory.getEventServiceProxy(topicName : topicName)?.subscribe(topicName : topicName, topicListener: self)
    }
    
    func unSubscribeToGroup(groupId : Double){
        AppDelegate.getAppDelegate().log.debug("groupId: \(groupId)")
        let topicName = GroupConversationMessageMQTTListener.USER_GROUP_CHAT_TOPIC + StringUtils.getStringFromDouble(decimalNumber: groupId)
        EventServiceProxyFactory.getEventServiceProxy(topicName : topicName)?.unSubscribe(topicName : topicName, topicListener: self)
    }
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        
        AppDelegate.getAppDelegate().log.debug("\(String(describing: message))")
        if messageObject != nil{
            let message  = Mapper<GroupConversationMessage>().map(JSONString: (messageObject as! NSString) as String)!
            UserGroupChatCache.getInstance()?.receiveNewMessage(newMessage: message)
        }
    }
}
