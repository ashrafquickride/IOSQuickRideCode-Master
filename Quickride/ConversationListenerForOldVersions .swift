//
//  ConversationListenerForOldVersions .swift
//  Quickride
//
//  Created by QuickRideMac on 02/07/16.
//  Copyright © 2016 iDisha. All rights reserved.
//

import Foundation
import ObjectMapper
class ConversationListenerForOldVersions : TopicListener {
    static let CONVERSATION_TOPIC_NAME="chat/"
    
    override func onMessageRecieved(message: String?, messageObject: Any?) {
        AppDelegate.getAppDelegate().log.debug("\(String(describing: message))")
        let chatMessage  = Mapper<ConversationMessageBC>().map(JSONString: (messageObject as! NSString) as String)
        if UserDataCache.getInstance()!.isABlockedUserForCurrentUser(userId: chatMessage!.sourceId!)
        {
            AppDelegate.getAppDelegate().log.debug("Blocked User")
            return
        }

        if chatMessage != nil{
            EventServiceRestClient.updateEventStatus(uniqueId: chatMessage!.uniqueID!, eventStatus: EventUpdate.EVENT_STATUS_RECIEVED, viewController: nil) { (responseObject, error) in    
            }
            ConversationCache.getInstance().receiveNewConversationMessage(conversationMessage: ConversationListenerForOldVersions.getConversationMessageFromBCMessage(conversationMessageBC: chatMessage!))
        }
        
    }
    func subscribeToConversationTopic(){
        AppDelegate.getAppDelegate().log.debug("")
        let userId = QRSessionManager.getInstance()!.getUserId();
        let topic = ConversationListenerForOldVersions.CONVERSATION_TOPIC_NAME + userId
        EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.subscribe(topicName: topic,topicListener: self)
        
    }
    
    func unSubscribeToConversationTopic(){
        AppDelegate.getAppDelegate().log.debug("")
        let userId = QRSessionManager.getInstance()!.getUserId()
        let topic = ConversationListenerForOldVersions.CONVERSATION_TOPIC_NAME + userId
        EventServiceProxyFactory.getEventServiceProxy(topicName: topic)?.unSubscribe(topicName: ConversationListenerForOldVersions.CONVERSATION_TOPIC_NAME + userId, topicListener: self)
    }
  
    static func getConversationMessageFromBCMessage(conversationMessageBC :ConversationMessageBC) -> ConversationMessage
    {
        AppDelegate.getAppDelegate().log.debug("\(conversationMessageBC)")
    let conversationMessage = ConversationMessage()
    conversationMessage.sourceId = conversationMessageBC.sourceId
    conversationMessage.destId = Double(QRSessionManager.getInstance()!.getUserId())
    conversationMessage.message = conversationMessageBC.message
    conversationMessage.time = conversationMessageBC.chatTime
    conversationMessage.uniqueID = conversationMessageBC.uniqueID
    conversationMessage.msgStatus = ConversationMessage.MSG_STATUS_NEW
    conversationMessage.msgType = ConversationMessage.MSG_TYPE_NEW
    return conversationMessage
    }
}
